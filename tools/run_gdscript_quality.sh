#!/usr/bin/env bash
set -euo pipefail

if ! command -v gdformat >/dev/null 2>&1 || ! command -v gdlint >/dev/null 2>&1; then
  echo "gdformat and gdlint must be installed before running this script." >&2
  exit 1
fi

mode="${1:-all}"

gdscript_files=()
while IFS= read -r file; do
  gdscript_files+=("$file")
done < <(
  find scripts tests -type f -name '*.gd' \
    ! -path 'scripts/player/spell_manager.gd' \
    ! -path 'tests/test_spell_manager.gd' \
    | sort
)

if [ "${#gdscript_files[@]}" -eq 0 ]; then
  echo "No GDScript files matched the quality gate." >&2
  exit 1
fi

run_format() {
  gdformat --check "${gdscript_files[@]}"
}

run_lint() {
  gdlint "${gdscript_files[@]}"
}

case "$mode" in
  format)
    run_format
    ;;
  lint)
    run_lint
    ;;
  all)
    run_format
    run_lint
    ;;
  *)
    echo "Usage: $0 [format|lint|all]" >&2
    exit 1
    ;;
esac
