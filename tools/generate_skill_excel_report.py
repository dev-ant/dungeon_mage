#!/usr/bin/env python3
"""Generate an Excel report for Dungeon Mage skill/circle/asset status.

This script intentionally uses only the Python standard library so it can run
in a clean environment without openpyxl/xlsxwriter/pandas.
"""

from __future__ import annotations

import argparse
import json
import re
import zipfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
from xml.sax.saxutils import escape


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate an XLSX report for skill implementation/circle/asset status."
    )
    parser.add_argument(
        "--project-root",
        default=".",
        help="Dungeon Mage project root. Defaults to current directory.",
    )
    parser.add_argument(
        "--output",
        default="",
        help="Output .xlsx path. Defaults to skill_circle_asset_report_<UTC-date>.xlsx in project root.",
    )
    return parser.parse_args()


def parse_md_table_after_heading(text: str, heading: str) -> list[dict[str, str]]:
    lines = text.splitlines()
    start = None
    for index, line in enumerate(lines):
        if line.strip() == heading:
            start = index + 1
            break
    if start is None:
        return []

    table_lines: list[str] = []
    started = False
    for line in lines[start:]:
        if line.startswith("## ") and started:
            break
        if line.strip().startswith("|"):
            table_lines.append(line)
            started = True
        elif started and not line.strip():
            break

    if len(table_lines) < 2:
        return []

    header = [cell.strip() for cell in table_lines[0].strip().strip("|").split("|")]
    rows: list[dict[str, str]] = []
    for line in table_lines[2:]:
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) != len(header):
            if len(cells) < len(header):
                cells += [""] * (len(header) - len(cells))
            else:
                cells = cells[: len(header) - 1] + [" | ".join(cells[len(header) - 1 :])]
        rows.append(
            {header[idx]: cells[idx].replace("`", "") for idx in range(len(header))}
        )
    return rows


def build_design_circle_map(design_text: str) -> dict[str, int]:
    design_circle_by_name: dict[str, int] = {}
    current_circle: int | None = None

    for raw_line in design_text.splitlines():
        line = raw_line.strip()
        match = re.match(r"^###\s+(\d+)서클$", line)
        if match:
            current_circle = int(match.group(1))
            continue
        if line.startswith("### "):
            current_circle = None
        if not line.startswith("|"):
            continue

        cells = [cell.strip().replace("`", "") for cell in line.strip().strip("|").split("|")]
        if len(cells) < 2:
            continue
        if cells[0] in {"라인", "서클", "---"}:
            continue

        if current_circle is not None:
            name = cells[1]
            if name and name != "이름":
                design_circle_by_name[name] = current_circle
        elif cells[0].isdigit():
            name = cells[1]
            if name and name != "이름":
                design_circle_by_name[name] = int(cells[0])

    return design_circle_by_name


def yes_no(value: bool) -> str:
    return "Y" if value else "N"


def as_int(text: str) -> int | None:
    stripped = str(text).strip()
    return int(stripped) if stripped.isdigit() else None


def col_letter(index: int) -> str:
    result = ""
    while index > 0:
        index, remainder = divmod(index - 1, 26)
        result = chr(65 + remainder) + result
    return result


def make_sheet_xml(
    rows: list[dict[str, Any]],
    headers: list[str],
    *,
    autofilter: bool = True,
    freeze_header: bool = True,
) -> str:
    row_xml: list[str] = []
    max_widths = [len(str(header)) for header in headers]
    all_rows: list[list[Any]] = [headers] + [[row.get(header, "") for header in headers] for row in rows]

    for row in all_rows:
        for idx, value in enumerate(row):
            max_widths[idx] = max(max_widths[idx], len(str(value)))

    cols_xml = ["<cols>"]
    for idx, width in enumerate(max_widths, start=1):
        excel_width = min(max(width + 2, 10), 60)
        cols_xml.append(
            f'<col min="{idx}" max="{idx}" width="{excel_width}" customWidth="1"/>'
        )
    cols_xml.append("</cols>")

    for row_index, row in enumerate(all_rows, start=1):
        cell_xml: list[str] = []
        for col_index, value in enumerate(row, start=1):
            cell_ref = f"{col_letter(col_index)}{row_index}"
            if value is None:
                value = ""
            if isinstance(value, (int, float)) and not isinstance(value, bool):
                cell_xml.append(f'<c r="{cell_ref}"><v>{value}</v></c>')
            else:
                text = escape(str(value))
                cell_xml.append(
                    f'<c r="{cell_ref}" t="inlineStr"><is><t xml:space="preserve">{text}</t></is></c>'
                )
        row_xml.append(f'<row r="{row_index}">{"".join(cell_xml)}</row>')

    dimension_ref = f"A1:{col_letter(len(headers))}{len(all_rows)}"
    if freeze_header:
        sheet_views_xml = (
            '<sheetViews><sheetView workbookViewId="0">'
            '<pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/>'
            "</sheetView></sheetViews>"
        )
    else:
        sheet_views_xml = '<sheetViews><sheetView workbookViewId="0"/></sheetViews>'

    autofilter_xml = (
        f'<autoFilter ref="A1:{col_letter(len(headers))}{len(all_rows)}"/>'
        if autofilter
        else ""
    )

    return (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
        f'<dimension ref="{dimension_ref}"/>'
        f"{sheet_views_xml}"
        f'{"".join(cols_xml)}'
        f'<sheetData>{"".join(row_xml)}</sheetData>'
        f"{autofilter_xml}"
        "</worksheet>"
    )


def create_xlsx(sheets: list[tuple[str, list[dict[str, Any]], list[str]]], output_path: Path) -> None:
    content_types = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
%s
</Types>""" % "\n".join(
        f'  <Override PartName="/xl/worksheets/sheet{idx}.xml" '
        'ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
        for idx in range(1, len(sheets) + 1)
    )

    rels = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>"""

    sheet_entries = "\n".join(
        f'    <sheet name="{escape(name)}" sheetId="{idx}" r:id="rId{idx}"/>'
        for idx, (name, _, _) in enumerate(sheets, start=1)
    )
    workbook_xml = f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <bookViews><workbookView xWindow="0" yWindow="0" windowWidth="24000" windowHeight="12000"/></bookViews>
  <sheets>
{sheet_entries}
  </sheets>
</workbook>"""

    workbook_rels = (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">\n'
        + "\n".join(
            f'  <Relationship Id="rId{idx}" '
            'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" '
            f'Target="worksheets/sheet{idx}.xml"/>'
            for idx in range(1, len(sheets) + 1)
        )
        + "\n</Relationships>"
    )

    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    core_xml = f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>Dungeon Mage Skill Circle Asset Report</dc:title>
  <dc:creator>Codex</dc:creator>
  <cp:lastModifiedBy>Codex</cp:lastModifiedBy>
  <dcterms:created xsi:type="dcterms:W3CDTF">{now_iso}</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">{now_iso}</dcterms:modified>
</cp:coreProperties>"""

    app_xml = f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
  <Application>Codex</Application>
  <TitlesOfParts>
    <vt:vector size="{len(sheets)}" baseType="lpstr">
      {"".join(f"<vt:lpstr>{escape(name)}</vt:lpstr>" for name, _, _ in sheets)}
    </vt:vector>
  </TitlesOfParts>
</Properties>"""

    if output_path.exists():
        output_path.unlink()

    with zipfile.ZipFile(output_path, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        archive.writestr("[Content_Types].xml", content_types)
        archive.writestr("_rels/.rels", rels)
        archive.writestr("docProps/core.xml", core_xml)
        archive.writestr("docProps/app.xml", app_xml)
        archive.writestr("xl/workbook.xml", workbook_xml)
        archive.writestr("xl/_rels/workbook.xml.rels", workbook_rels)
        for sheet_index, (_, rows, headers) in enumerate(sheets, start=1):
            archive.writestr(
                f"xl/worksheets/sheet{sheet_index}.xml",
                make_sheet_xml(rows, headers),
            )


def main() -> int:
    args = parse_args()
    project_root = Path(args.project_root).resolve()
    output_path = (
        Path(args.output).resolve()
        if args.output
        else project_root
        / f"skill_circle_asset_report_{datetime.now(timezone.utc).strftime('%Y-%m-%d')}.xlsx"
    )

    tracker_path = project_root / "docs/progression/trackers/skill_implementation_tracker.md"
    design_path = project_root / "docs/progression/rules/skill_system_design.md"
    skills_path = project_root / "data/skills/skills.json"
    spells_path = project_root / "data/spells.json"
    asset_dir = project_root / "assets/effects"
    test_paths = [
        project_root / "tests/test_game_state.gd",
        project_root / "tests/test_spell_manager.gd",
        project_root / "tests/test_admin_menu.gd",
    ]

    tracker_text = tracker_path.read_text(encoding="utf-8")
    design_text = design_path.read_text(encoding="utf-8")
    skills = json.loads(skills_path.read_text(encoding="utf-8"))["skills"]
    spells = json.loads(spells_path.read_text(encoding="utf-8"))
    asset_dirs = sorted(path.name for path in asset_dir.iterdir() if path.is_dir())

    runtime_rows = parse_md_table_after_heading(tracker_text, "## 현재 runtime 과 직접 연결된 스킬")
    core_rows = parse_md_table_after_heading(tracker_text, "## 코어 라인업 설계 스킬")
    candidate_rows = parse_md_table_after_heading(tracker_text, "## 신규 에셋 기반 확장 후보")
    legacy_rows = parse_md_table_after_heading(tracker_text, "## 레거시 / 재분류 대기 스킬")
    design_circle_by_name = build_design_circle_map(design_text)

    skills_by_canonical = {
        str(skill.get("canonical_skill_id", "")): skill
        for skill in skills
        if skill.get("canonical_skill_id")
    }
    skills_by_skill_id = {
        str(skill.get("skill_id", "")): skill for skill in skills if skill.get("skill_id")
    }
    spells_by_id = {spell_id: spell for spell_id, spell in spells.items()}
    test_text = "\n".join(path.read_text(encoding="utf-8") for path in test_paths)

    special_asset_map = {
        "holy_mana_veil": ["holy_guard_activation", "holy_guard_overlay"],
        "holy_crystal_aegis": ["holy_guard_activation", "holy_guard_overlay"],
        "ice_frozen_domain": [
            "ice_frozen_domain_activation",
            "ice_frozen_domain_loop",
            "ice_frozen_domain_end",
        ],
        "ice_glacial_dominion": [
            "ice_frozen_domain_activation",
            "ice_frozen_domain_loop",
            "ice_frozen_domain_end",
        ],
    }

    def find_skill_data(canonical_id: str, runtime_ref: str) -> dict[str, Any] | None:
        if canonical_id in skills_by_canonical:
            return skills_by_canonical[canonical_id]
        if runtime_ref in skills_by_skill_id:
            return skills_by_skill_id[runtime_ref]
        if canonical_id in skills_by_skill_id:
            return skills_by_skill_id[canonical_id]
        return None

    def infer_asset_folders(canonical_id: str, runtime_ref: str, data_skill_id: str) -> str:
        seeds: list[str] = []
        for seed in [runtime_ref, canonical_id, data_skill_id]:
            if seed and seed != "-" and seed not in seeds:
                seeds.append(seed)
        found: set[str] = set()
        for folder in asset_dirs:
            for seed in seeds:
                if folder == seed or folder.startswith(seed + "_"):
                    found.add(folder)
        for key in [canonical_id, runtime_ref, data_skill_id]:
            for folder in special_asset_map.get(key, []):
                if folder in asset_dirs:
                    found.add(folder)
        return ", ".join(sorted(found))

    def has_test_reference(*ids: str) -> bool:
        for ident in ids:
            ident = str(ident or "").strip()
            if not ident or ident == "-":
                continue
            pattern = r"(?<![A-Za-z0-9_])%s(?![A-Za-z0-9_])" % re.escape(ident)
            if re.search(pattern, test_text):
                return True
        return False

    skill_rows: list[dict[str, Any]] = []
    for category, rows in [
        ("runtime_connected", runtime_rows),
        ("core_lineup", core_rows),
        ("asset_candidates", candidate_rows),
    ]:
        for row in rows:
            canonical_id = row.get("canonical skill_id", "")
            display_name = row.get("이름", "")
            runtime_ref = row.get("현재 runtime 참조", "")
            skill_data = find_skill_data(canonical_id, runtime_ref)
            data_skill_id = str(skill_data.get("skill_id", "")) if skill_data else ""
            data_circle = skill_data.get("circle", "") if skill_data else ""
            data_school = str(skill_data.get("school", "")) if skill_data else ""
            data_element = str(skill_data.get("element", "")) if skill_data else ""

            runtime_spell_id = ""
            if runtime_ref in spells_by_id:
                runtime_spell_id = runtime_ref
            elif data_skill_id in spells_by_id:
                runtime_spell_id = data_skill_id

            tracker_circle = as_int(row.get("서클", ""))
            skill_rows.append(
                {
                    "category": category,
                    "canonical_skill_id": canonical_id,
                    "display_name": display_name,
                    "design_circle": design_circle_by_name.get(display_name, ""),
                    "tracker_circle": tracker_circle,
                    "data_circle": data_circle,
                    "circle_match_tracker_vs_data": (
                        yes_no(tracker_circle == data_circle)
                        if data_circle != "" and tracker_circle is not None
                        else ""
                    ),
                    "attribute": row.get("속성", ""),
                    "type": row.get("타입", ""),
                    "runtime_reference": runtime_ref,
                    "runtime_spell_id": runtime_spell_id,
                    "data_skill_id": data_skill_id,
                    "implementation_status": row.get("구현", ""),
                    "asset_status": row.get("asset", ""),
                    "attack_effect_status": row.get("attack effect", ""),
                    "hit_effect_status": row.get("hit effect", ""),
                    "level_scaling_status": row.get("레벨 스케일", ""),
                    "data_school": data_school,
                    "data_element": data_element,
                    "asset_folders": infer_asset_folders(
                        canonical_id, runtime_ref, data_skill_id
                    ),
                    "test_reference": yes_no(
                        has_test_reference(canonical_id, runtime_ref, data_skill_id)
                    ),
                    "note": row.get("비고", ""),
                }
            )

    legacy_sheet_rows: list[dict[str, Any]] = []
    for row in legacy_rows:
        runtime_ref = row.get("현재 runtime 참조", "")
        legacy_sheet_rows.append(
            {
                "name": row.get("이름", ""),
                "runtime_reference": runtime_ref,
                "status": row.get("현재 상태", ""),
                "asset_folders": infer_asset_folders("", runtime_ref, ""),
                "test_reference": yes_no(has_test_reference(runtime_ref, row.get("이름", ""))),
                "note": row.get("메모", ""),
            }
        )

    summary_rows: list[dict[str, Any]] = []
    for circle in range(1, 11):
        tracker_skill_rows = [
            row for row in skill_rows if row.get("tracker_circle") == circle
        ]
        data_skill_rows = [skill for skill in skills if skill.get("circle") == circle]
        runtime_or_proto_rows = [
            row
            for row in tracker_skill_rows
            if row.get("implementation_status") in {"runtime", "verified", "prototype"}
        ]
        asset_connected_rows = [
            row
            for row in tracker_skill_rows
            if row.get("asset_status") in {"applied", "verified"}
        ]
        highlights = [
            row["display_name"]
            for row in tracker_skill_rows
            if row.get("implementation_status") in {"runtime", "verified"}
        ][:8]
        mismatch_count = sum(
            1
            for row in tracker_skill_rows
            if row.get("circle_match_tracker_vs_data") == "N"
        )
        summary_rows.append(
            {
                "circle": circle,
                "tracker_skill_count": len(tracker_skill_rows),
                "skills_json_count": len(data_skill_rows),
                "runtime_or_proto_count": len(runtime_or_proto_rows),
                "asset_connected_count": len(asset_connected_rows),
                "highlights": ", ".join(highlights),
                "circle_mismatch_count": mismatch_count,
            }
        )

    mismatch_rows: list[dict[str, Any]] = []
    for row in skill_rows:
        design_circle = row.get("design_circle", "")
        tracker_circle = row.get("tracker_circle", "")
        data_circle = row.get("data_circle", "")
        mismatch_types: list[str] = []
        if design_circle != "" and tracker_circle not in ("", None) and design_circle != tracker_circle:
            mismatch_types.append("design_vs_tracker")
        if tracker_circle not in ("", None) and data_circle != "" and tracker_circle != data_circle:
            mismatch_types.append("tracker_vs_data")
        if design_circle != "" and data_circle != "" and design_circle != data_circle:
            mismatch_types.append("design_vs_data")
        if mismatch_types:
            mismatch_rows.append(
                {
                    "canonical_skill_id": row["canonical_skill_id"],
                    "display_name": row["display_name"],
                    "design_circle": design_circle,
                    "tracker_circle": tracker_circle,
                    "data_circle": data_circle,
                    "mismatch_types": ", ".join(mismatch_types),
                    "runtime_reference": row["runtime_reference"],
                    "implementation_status": row["implementation_status"],
                    "note": row["note"],
                }
            )

    sheets = [
        (
            "Overview",
            summary_rows,
            [
                "circle",
                "tracker_skill_count",
                "skills_json_count",
                "runtime_or_proto_count",
                "asset_connected_count",
                "highlights",
                "circle_mismatch_count",
            ],
        ),
        (
            "Skill_Details",
            skill_rows,
            [
                "category",
                "canonical_skill_id",
                "display_name",
                "design_circle",
                "tracker_circle",
                "data_circle",
                "circle_match_tracker_vs_data",
                "attribute",
                "type",
                "runtime_reference",
                "runtime_spell_id",
                "data_skill_id",
                "implementation_status",
                "asset_status",
                "attack_effect_status",
                "hit_effect_status",
                "level_scaling_status",
                "data_school",
                "data_element",
                "asset_folders",
                "test_reference",
                "note",
            ],
        ),
        (
            "Circle_Mismatch",
            mismatch_rows,
            [
                "canonical_skill_id",
                "display_name",
                "design_circle",
                "tracker_circle",
                "data_circle",
                "mismatch_types",
                "runtime_reference",
                "implementation_status",
                "note",
            ],
        ),
        (
            "Legacy_Candidates",
            legacy_sheet_rows,
            [
                "name",
                "runtime_reference",
                "status",
                "asset_folders",
                "test_reference",
                "note",
            ],
        ),
    ]

    create_xlsx(sheets, output_path)
    print(output_path)
    print(
        "Generated sheets=%d skill_rows=%d mismatch_rows=%d legacy_rows=%d"
        % (len(sheets), len(skill_rows), len(mismatch_rows), len(legacy_sheet_rows))
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
