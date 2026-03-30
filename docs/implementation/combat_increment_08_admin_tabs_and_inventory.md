# 전투 8차 작업 체크리스트 - 관리자 탭 구조와 장비 지급

상태: 사용 중  
최종 갱신: 2026-03-29  
섹션: 구현 기준

## 목표

이 문서는 [전투 우선 구현 계획](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/combat_first_build_plan.md)의 다음 대형 작업을 Claude가 바로 이어받을 수 있도록 잘게 쪼갠 체크리스트다.

이번 증분의 핵심은 `한 화면형 관리자 메뉴를 유지보수 가능한 구조로 분리하고, 장비 프리셋 중심 샌드박스를 지급/장착 중심 샌드박스로 확장하는 것`이다.
추가로, 최종 장비/인벤토리 목표는 텍스트 목록이 아니라 메이플스토리나 마비노기처럼 슬롯, 아이콘, 점유 크기, 위치 이동이 보이는 그래픽 GUI다. 이 요구사항은 이번 문서 갱신에서 추가되었고 아직 미구현이다.

## 이번 증분의 에셋 기준

- 장비 패널 기본 스킨은 [Equipment.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Equipment.png) 를 우선 사용한다.
- 인벤토리 패널 기본 스킨은 [Inventory.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Inventory.png) 를 우선 사용한다.
- 버튼과 소형 슬롯 상태는 [Buttons.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Buttons.png) 를 우선 사용한다.
- 이 에셋 기준은 이번 문서 갱신에서 추가된 것이며, 아직 최종 장비 GUI로 구현되지 않았다.

## 지금 상태 요약

- 현재 [admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)에서는 경량 4탭 `핫바 / 자원 / 장비 / 소환` 구조가 이미 들어가 있으며, 핫바 편집, 무한 HP, 무한 MP, 쿨타임 무시, 적 소환, 쿨타임 리셋, 장비 프리셋, 개별 장비 슬롯 교체가 동작한다.
- 현재 구조만으로도 전투 실험은 가능하지만, 기능이 늘수록 입력 충돌과 가독성 문제가 커질 가능성이 높다.
- 장비는 이제 최소 인벤토리 배열과 `지급 -> 인벤토리 등록 -> 장착 / 해제` 루프까지는 들어갔지만, 별도 장비 목록 탭이나 정렬된 인벤토리 UI는 아직 없다.
- 현재 장비 표현은 여전히 텍스트 기반에 가깝고, 그래픽 인벤토리 슬롯/아이콘/드래그 이동 GUI는 아직 없다.
- 장비의 `최대 HP`, `최대 MP`, `MP 재생`, `기본 피해 감소`는 이미 실제 전투 수치에 연결되어 있다. 따라서 다음 단계는 수치 연결보다 `관리 흐름`과 `UI 구조` 쪽이 중심이다.

## 왜 지금 바로 전부 구현하지 않는가

- 탭형 관리자 UI와 인벤토리형 장비 흐름은 화면 구조, 입력 방식, 상태 저장, 테스트 범위가 한꺼번에 커진다.
- 이 작업을 한 번에 밀면 전투 샌드박스 안정성이 깨질 가능성이 높다.
- 그래서 Claude는 아래 순서를 그대로 따라 작은 단계로 끊어 구현하는 것이 안전하다.

## Claude 작업 순서

1. `Equipment / Inventory / Buttons` PNG를 실제 장비 GUI 컨테이너에 먼저 연결한다.
2. 장비 인벤토리 최소 구조를 그래픽 슬롯 좌표와 점유 크기까지 수용 가능한 형태로 보강한다.
3. 현재 `지급 -> 인벤토리 등록 -> 장착 / 해제` 루프를 그래픽 슬롯 UI로 옮긴다.
4. 아이템 아이콘, 점유 크기, 위치 표시를 실제 패널 안에 그린다.
5. 드래그 앤 드롭 또는 동등한 위치 이동 조작을 붙인다.
6. 텍스트 목록/비교 출력은 디버그 fallback 으로만 남기고, 실제 장비 조작은 GUI를 기준으로 삼는다.
7. 헤드리스 검증과 GUT를 다시 통과시킨다.

## 이번 증분의 포함 범위

- 관리자 메뉴 탭 분리
- 탭별 입력 처리 분리
- 인벤토리 최소 데이터 구조
- 장비 지급 함수
- 장비 장착/해제와 인벤토리 이동
- 탭 구조 관련 GUT 테스트
- 그래픽 인벤토리 GUI로 가기 위한 데이터/상태 구조 정리

## 이번 증분의 제외 범위

- 완성형 드래그 앤 드롭 인벤토리 UI 구현 자체
- 장비 희귀도 정렬
- 랜덤 드롭 시스템
- 실제 몬스터 드롭 테이블
- 상점, 강화, 제작

단, `최종 목표에서 제외`가 아니라 `이번 증분에서만 제외`다. 그래픽 인벤토리와 위치 이동 GUI는 이후 반드시 구현해야 하는 목표로 유지한다.

## 권장 구현 파일

- [admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
- [game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)
- [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)
- [test_admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_admin_menu.gd)
- 새 장비 인벤토리 테스트 파일 또는 [test_equipment_system.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_equipment_system.gd) 확장

## 세부 체크리스트

### 1. 탭 구조 추가

- 현재 들어간 `current_tab`, 탭 상수, 탭 렌더링 분기를 유지한다.
- 현재 정리된 렌더 함수 분리를 유지하면서, 인벤토리 흐름이 붙을 때만 하위 위젯 분리를 검토한다.
- 탭 전환 입력과 라이브러리 포커스 해제 규칙을 테스트로 고정한다.
- 각 탭은 자기 기능만 렌더링하는 현재 원칙을 유지한다.

### 2. 자원 탭 정리

- 무한 HP
- 무한 MP
- 쿨타임 무시
- 전체 쿨타임 리셋
- 즉시 회복

### 3. 장비 탭 정리

- 프리셋 적용 유지
- 슬롯 선택과 개별 교체 유지
- 현재 구현된 인벤토리 요약 표시 유지
- 현재 구현된 슬롯별 보유 장비 요약 표시 유지
- 현재 구현된 보유 장비 선택 인덱스와 `선택 장비 장착` 흐름 유지
- 현재 구현된 `Owned List` 미리보기 렌더를 유지하고, 장비명과 `희귀도 / 슬롯`, 선택 장비의 `설명 / 태그` 메타데이터, 정렬 모드 `rarity -> name` / `name`, 필터 모드 `all / tempo / ritual / burst / defense`, 상태 헤더 `Owned View`, 페이지 표시 `Owned Page`, 현재 범위 표시 `Items x-y/n`, 장비 탭 전용 페이지 이동 입력 `Y/H`를 다음 단계의 정렬형 인벤토리 UI 발판으로 사용한다.
- 현재 구현된 `Equipment Focus  candidate / owned`를 유지하고, `T`로 포커스를 전환한 뒤 `N/R`로 포커스된 대상을 순환하는 구조를 다음 단계의 목록 커서 / 패널 포커스 분리의 발판으로 사용한다.
- 현재 구현된 `Candidate Status / Owned Status` 상태 줄과 탭별 footer 안내를 유지하고, 이를 다음 단계의 패널 헤더 / 입력 가이드로 확장한다.
- 현재 구현된 `Candidate Selection / Candidate List` 미리보기를 유지하고, 이를 `Owned List`와 대칭적인 후보 목록 패널의 시작점으로 사용한다.
- 현재 구현된 `Candidate Window  Items x-y/n`을 유지하고, 이를 다음 단계의 후보 패널 스크롤 또는 페이지 이동 구조의 기초로 사용한다.
- 현재 구현된 `candidate` 패널의 `Y/H` 창 이동을 유지하고, 이를 `owned` 패널의 페이지 이동과 같은 레벨의 탐색 규칙으로 정리한다.
- 현재 구현된 `Candidate Detail` 설명/태그 메타데이터를 유지하고, 이를 `Owned Detail`과 대칭적인 패널 상세 영역으로 확장한다.
- 현재 구현된 `Candidate Compare` 한 줄을 유지하고, 이를 다음 단계의 장비 비교 패널 또는 패널 헤더 비교 정보의 기초로 사용한다.
- 현재 구현된 후보 목록의 `[Owned]` 표시를 유지하고, 이를 다음 단계의 후보/보유 관계 시각화 기준으로 사용한다.
- 현재 구현된 `Slot Stats` 한 줄 요약을 유지하고, 이를 다음 단계의 패널 헤더 또는 비교 패널의 기초 정보로 사용한다.
- 현재 구현된 선택 후보 지급 유지
- 지급 후 즉시 장착 또는 인벤토리 보관 선택을 목록형 UI로 확장
- 최종적으로는 장비/인벤토리를 텍스트 목록이 아니라 그래픽 슬롯 GUI로 전환
- 아이템 아이콘 표시
- 아이템 점유 크기(`가로 x 세로`) 표시
- 슬롯 내 위치와 배치 상태 시각화
- 드래그 앤 드롭 또는 동등한 그래픽 위치 이동 상호작용 목표 유지

### 4. 소환 탭 정리

- `dummy`
- `brute`
- `ranged`
- `boss`
- 이후 몬스터 증분에서 추가될 적 타입을 쉽게 확장할 수 있게 문자열 기반 구조 유지

### 5. 테스트 우선 항목

- 탭 전환
- 탭별 입력 충돌 없음
- 장비 지급 후 인벤토리 반영
- 장착 시 인벤토리 이동
- 기존 무한 HP / 무한 MP / 쿨타임 무시 기능 유지

## 수용 기준

- 관리자 메뉴가 한 화면 텍스트 덩어리가 아니라 탭 기준으로 나뉜다.
- 장비는 프리셋만이 아니라 지급 후 장착 흐름으로도 실험 가능하다.
- 기존 관리자 기능이 깨지지 않는다.
- GUT와 헤드리스 검증이 모두 통과한다.
- 장비/인벤토리 UI가 최종적으로 그래픽 슬롯, 아이콘, 점유 크기, 위치 이동을 갖는 GUI로 확장 가능한 구조를 가진다.
- 위 그래픽 GUI 목표는 현재 문서에서 새로 명시된 요구사항이며 아직 구현 완료가 아니다.

## 진행 메모

- 이 증분은 구현 난도가 높다.
- 화면 구조와 상태 이동이 커지므로, 한 번에 예쁘게 만들려고 하지 말고 먼저 `동작하는 탭형 텍스트 메뉴`를 중간 단계로 사용한다.
- 장비 인벤토리는 배열 기반 최소 구조로 시작하고, 슬롯별 중복 허용 여부는 다음 단계에서 다듬는다.
- 현재는 `candidate`와 `owned`의 포커스만 분리된 경량 상태다. Claude는 이 분리를 기반으로 `좌측 후보 패널 / 우측 보유 목록 패널` 같은 실제 UI 분리로 확장하면 된다.
- 현재는 텍스트 기반 패널 상태 줄과 footer 안내까지 분리된 상태다. Claude는 이 텍스트 구조를 유지한 채 하위 위젯 또는 실제 패널 레이아웃으로 옮기는 편이 안전하다.
- 현재 텍스트형 패널은 최종 형태가 아니라 그래픽 GUI로 가기 위한 임시 단계로 간주한다.

## 새로 확정된 기준 (2026-03-29, 아직 미구현)

- 장비창과 인벤토리는 텍스트 목록이 아니라 그래픽 슬롯 기반 GUI여야 한다.
- 각 아이템은 아이콘, 점유 크기(`가로 x 세로`), 현재 위치를 시각적으로 보여야 한다.
- 플레이어는 그래픽적으로 아이템 위치를 옮길 수 있어야 하며, 드래그 앤 드롭 또는 동등한 조작 경로를 제공해야 한다.
- 위 장비/인벤토리 GUI는 지정된 `Equipment / Inventory / Buttons` PNG 사용을 기본 전제로 구현한다.
- 이 기준은 현재 코드에 아직 구현되지 않았고, 이후 증분에서 반드시 구현해야 하는 목표다.

## Claude 즉시 작업 순서

### 1. 장비 패널 공통 구조 추출

- 대상 파일:
  - [admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
- 구현 의도:
  - 현재 `candidate`와 `owned` 패널이 거의 같은 정보를 가지므로, 헤더/상태/상세/목록 렌더 규칙을 공통 헬퍼로 정리해 이후 2패널 UI 확장을 쉽게 만든다.
- 예상 결과:
  - 패널 하나를 그리는 공통 함수 또는 공통 포맷 helper가 생긴다.
  - `candidate`와 `owned`의 정보 구조가 더 대칭적으로 보인다.
- 확인 방법:
  - 기존 장비 탭 텍스트가 유지된다.
  - [test_admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_admin_menu.gd) 회귀 통과

### 2. 좌우 2패널 텍스트 배치의 첫 단계

- 대상 파일:
  - [admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
  - [test_admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_admin_menu.gd)
- 구현 의도:
  - 아직 진짜 UI 위젯 분리는 하지 않더라도, 텍스트 출력상 `candidate`와 `owned`가 명확히 다른 패널처럼 보이도록 정렬/구분을 강화한다.
- 예상 결과:
  - 장비 탭에서 두 패널 경계가 지금보다 명확해진다.
  - `Focus / Slot / Target`을 기준으로 현재 조작 패널이 더 즉시 읽힌다.
  - `Slot Stats / Candidate Compare`를 이후 2패널 UI의 기준/차이 정보 묶음으로 자연스럽게 재배치할 수 있다.
- 확인 방법:
  - headless 실행 시 관리자 메뉴 본문에서 두 패널을 쉽게 구분할 수 있다.
  - GUT에 패널 정렬/구분 문자열 테스트 추가

### 3. 후보 지급 후 빠른 후속 선택 규칙 정리

- 대상 파일:
  - [admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
  - [game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd) 필요 시
  - [test_admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_admin_menu.gd)
- 구현 의도:
  - 후보 지급 직후 `owned` 패널에서 바로 확인 가능한 후속 선택 규칙을 만들면 실험 속도가 빨라진다.
- 예상 결과:
  - 지급한 장비가 즉시 `owned` 목록에서 읽히고, 필요하면 바로 장착 대상으로 이어진다.
- 확인 방법:
  - 지급 후 `owned` 목록 또는 요약에 새 장비가 즉시 보인다.
  - 관련 GUT 테스트 추가

### 4. HUD 요약과 관리자 메뉴의 중복 역할 정리

- 대상 파일:
  - [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)
  - [admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
  - [combat_increment_06_combat_ui.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/combat_increment_06_combat_ui.md)
- 구현 의도:
  - HUD는 상태 요약, 관리자 메뉴는 조작 상세라는 역할 분리를 더 분명히 한다.
- 예상 결과:
  - HUD는 `Focus / Slot / Target` 중심 요약을 유지하고, 상세 텍스트는 관리자 메뉴에 남는다.
- 확인 방법:
  - HUD 길이가 불필요하게 늘어나지 않는다.
  - 관리자 상태 요약 테스트 유지

## 9차 증분 완료 상태 (2026-03-28)

장비 탭 패널 분리 강화:
- 탭 헤더에 `[CANDIDATE panel active]` / `[OWNED panel active]` 형식으로 현재 포커스가 명확히 표시된다.
- `-- Candidate --` / `-- Owned --` 섹션 헤더가 포커스된 패널에 표시되고, 비포커스 패널은 `   Candidate` / `   Owned` 로 구분된다.
- 포커스된 패널에만 해당 패널 전용 컨트롤 힌트가 표시된다.
  - candidate 포커스: `N/R cycle candidate  E grant to inventory`
  - owned 포커스: `N/R cycle owned  E equip  B sort  J filter  Y/H page`
- 기존 테스트 60개 전체 통과, 새 테스트 3개 추가 (패널 헤더, 섹션 헤더, 컨트롤 힌트).

## 10차 증분 완료 상태 (2026-03-28)

후보 패널을 owned 패널과 대칭 구조로 확장:
- `_get_selected_candidate_meta_line()`: `Candidate Detail  설명  Tags:태그` 줄 추가. `Owned Detail` 과 동일한 포맷.
- `_get_candidate_selection_line()`: `Candidate Selection  [FOCUS]  index/total` 줄. 포커스 마커 포함.
- `_get_candidate_window_line()`: `Candidate Window  Items a-b/n` 줄. 현재 index 기준 앞뒤 ±1 범위 표시.
- `_get_candidate_preview_lines()`: `Candidate List` + 항목별 `> item [Rarity / slot]` 줄. 인벤토리 보유 시 `[Owned]` 마커 표시.
- `_get_candidate_list_entry_text()`: 목록 항목 포맷 helper. 비어 있으면 `(empty)`, 보유 시 `  [Owned]` 접미.
- `Y/H` 입력으로 candidate 창 앞뒤 이동 가능 (`_cycle_candidate_window`).
- 새 테스트 2개 추가: 후보 패널 전체 구조 확인, 후보 창 이동 확인.
- 전체 테스트 91/91 통과.

## 11차 증분 완료 상태 (2026-03-28)

후보와 현재 장착 장비의 수치 차이 표시:
- `_get_candidate_compare_line()`: 현재 후보와 현재 장착 장비를 비교해 `Candidate Compare` 한 줄을 렌더한다.
- 비교 대상은 `MATK`, `MaxHP`, `MaxMP`, `MPRegen`, `CDR`, `DR`다.
- 장착 기준이 없으면 `no equipped baseline`, 차이가 없으면 `sidegrade / utility`로 표시한다.
- 새 테스트 1개 추가: 장비 프리셋 기준으로 후보/장착 차이 문자열 확인.
- 이 정보는 다음 단계에서 `Slot Stats`와 함께 장비 비교 헤더 또는 중앙 비교 영역으로 승격하기 좋은 중간 구조다.

## 12차 증분 완료 상태 (2026-03-28)

장비 비교 헤더의 첫 단계:
- 선택 슬롯 구간에 `Compare Header  Equipped:...  Candidate:...` 줄이 추가되었다.
- `Slot Stats`와 `Candidate Compare`는 이제 이 비교 헤더 바로 아래에서 함께 읽히므로, 상단의 기준/차이 정보 묶음이 더 분명해졌다.
- 새 테스트 1개 추가: 비교 헤더 문자열 확인.
- 이 단계는 아직 완전한 2패널 비교 헤더는 아니지만, 다음 단계에서 `Status / Detail / Compare`를 공통 패널 구조로 묶는 발판이다.

## 13차 증분 완료 상태 (2026-03-28)

상단 비교 섹션 공통 helper 정리:
- `_get_equipment_compare_section_lines()`를 추가해 `Compare Header / Slot Stats / Candidate Compare`를 하나의 비교 섹션 단위로 묶었다.
- 장비 탭은 이제 이 helper를 통해 상단 비교 정보를 렌더하므로, 다음 단계에서 이 섹션을 `candidate / owned` 공통 패널 규칙으로 옮기기 쉬워졌다.
- 새 테스트 1개 추가: `Compare Header -> Slot Stats -> Candidate Compare` 순서가 유지되는지 확인.

## 14차 증분 완료 상태 (2026-03-28)

candidate / owned 패널 helper 추출 1차:
- `_get_candidate_panel_lines()`와 `_get_owned_panel_lines()`를 추가해 두 패널을 helper 기반으로 렌더하도록 정리했다.
- `_get_equipment_panel_header_line()`와 `_append_equipment_panel_control_hint()`를 통해 패널 헤더와 포커스된 패널 전용 컨트롤 힌트의 조립 규칙을 공통화했다.
- 화면 출력은 유지하면서도, 이제 두 패널이 같은 조립 흐름을 쓰므로 다음 단계의 공통 패널 helper 추출이 훨씬 쉬워졌다.
- 새 테스트 1개 추가: helper 추출 이후에도 candidate/owned 섹션이 함께 보이는지 확인.

## 15차 증분 완료 상태 (2026-03-28)

상위 공통 패널 wrapper 추출:
- `_build_equipment_panel_lines()`를 추가해 `헤더 -> 상태 -> 본문 -> 포커스 힌트` 순서의 상위 패널 조립 규칙을 공통화했다.
- `_get_candidate_panel_lines()`와 `_get_owned_panel_lines()`는 이제 패널별 body_lines만 만들고, 실제 조립은 공통 wrapper에 맡긴다.
- 이 단계로 다음 Claude 작업은 `본문 조각`인 `Detail / Compare / Selection / Window or Page / List`를 공통 패널 body 규칙으로 묶는 데 집중할 수 있게 되었다.
- 새 테스트 1개 추가: candidate/owned 양쪽 모두 `상태 줄 -> 본문` 순서가 유지되는지 확인.

## 16차 증분 완료 상태 (2026-03-28)

공통 body helper 추출:
- `_build_equipment_panel_body_lines()`를 추가해 패널 본문을 `primary -> detail -> section -> navigation -> list` 순서로 공통 조립하도록 정리했다.
- `_get_candidate_panel_lines()`와 `_get_owned_panel_lines()`는 이제 각 패널의 body source만 제공하고, 본문 조립 자체는 공통 helper가 맡는다.
- 이 단계로 다음 Claude 작업은 패널 간 차이를 본문 source 데이터로만 더 축소하거나, 실제 좌우 2패널 레이아웃으로 승격하는 데 집중할 수 있게 되었다.
- 새 테스트 1개 추가: candidate 본문에서 `Detail -> Selection -> Window` 순서가 유지되는지 확인.

## 17차 증분 완료 상태 (2026-03-28)

candidate body source 대칭화 1차:
- `Candidate View  State:...  Items x-y/n` 줄을 추가해 candidate 본문이 owned의 `Owned View`와 더 비슷한 구조를 갖도록 정리했다.
- `_build_equipment_panel_body_lines()`는 이제 `primary -> detail -> view -> section -> navigation -> list` 순서로 본문을 조립한다.
- 테스트를 갱신해 candidate 본문에서 `Detail -> View -> Selection -> Window` 순서가 유지되는지 확인한다.

## 18차 증분 완료 상태 (2026-03-28)

공통 body source 구조 추출:
- `_build_equipment_panel_body_source()`를 추가해 candidate/owned 패널이 같은 source key를 가진 구조를 먼저 만들고, `_build_equipment_panel_body_lines()`는 그 source를 받아 본문을 조립하도록 정리했다.
- 공통 key는 `primary_line`, `detail_line`, `view_line`, `selection_line`, `navigation_line`, `list_lines`다.
- 이 단계로 다음 Claude 작업은 패널 차이를 렌더 규칙이 아니라 source 값 수준에서만 더 줄이면 된다.
- 새 테스트 1개 추가: owned 쪽도 source 기반 조립 이후 `Owned View / Owned Page`가 그대로 유지되는지 확인.

## 19차 증분 완료 상태 (2026-03-28)

owned body source helper 대칭화 1차:
- `candidate` 쪽만 아니라 `owned` 쪽도 `_get_owned_primary_line()`, `_get_owned_view_line()`, `_get_owned_selection_line()`, `_get_owned_navigation_line()` helper를 통해 body source를 채우도록 정리했다.
- 현재 출력은 유지하고, `owned`는 `primary`에 현재 선택 장비를 두고 `selection`은 비워서 중복 줄이 생기지 않게 했다.
- 이 단계로 candidate/owned 양쪽이 모두 `helper -> body source -> common body builder -> common panel wrapper` 흐름을 가지게 되었고, 다음 Claude 작업은 helper 이름과 source 의미를 더 완전히 대칭화하는 데 집중할 수 있다.
- 새 테스트 1개 추가: owned helper 분리 이후에도 `Owned Selection` 줄이 한 번만 렌더되고 `Owned View / Owned Page`가 유지되는지 확인.

## 20차 증분 완료 상태 (2026-03-28)

패널별 body source 생성 helper 분리:
- `_get_candidate_panel_body_source()`와 `_get_owned_panel_body_source()`를 추가해, 각 패널이 자기 source를 먼저 만들고 그 뒤 공통 body builder에 넘기도록 정리했다.
- 이제 장비 탭 패널 구조는 `panel lines helper -> panel body source helper -> common body source builder -> common body lines builder -> common panel wrapper` 순서로 읽을 수 있다.
- 출력은 유지하면서, 다음 단계에서 `candidate / owned` body source 값을 더 대칭화하거나 실제 2패널 텍스트 UI로 승격할 때 수정 범위를 panel source helper 쪽으로 더 쉽게 한정할 수 있게 되었다.
- 새 테스트 1개 추가: body source helper 분리 이후에도 candidate/owned 양쪽 `View` 줄이 계속 렌더되는지 확인.

## 21차 증분 완료 상태 (2026-03-28)

후보 지급 후 빠른 후속 선택 규칙 추가:
- 후보 지급 성공 시 `_apply_post_grant_equipment_selection()`이 호출되어 `owned` 포커스로 자동 전환되고, `equipment_filter_mode`는 `all`로 맞춰지며, 방금 지급한 장비가 보유 목록의 선택 상태로 잡히도록 정리했다.
- 이 규칙은 `Q` 직접 지급 경로와 `candidate` 포커스 `E` 상호작용 경로, debug grant 경로에 공통으로 적용된다.
- 이 단계로 `후보 탐색 -> 지급 -> 보유 목록 즉시 확인 -> 장착` 흐름이 한 번에 이어지므로, 다음 Claude 작업은 지급 후 패널 배치와 장착 유도 텍스트를 더 강하게 다듬는 데 집중할 수 있다.
- 새 테스트 1개 추가: 후보 지급 직후 관리자 요약이 `Focus[owned]`, `Target[지급 장비]`로 바뀌고 `Owned Selection`이 새 장비를 가리키는지 확인.

## 22차 증분 완료 상태 (2026-03-28)

지급 직후 장착 유도 상태 추가:
- `recent_granted_slot_name`, `recent_granted_item_id`를 통해 방금 지급한 장비의 단기 컨텍스트를 추적하도록 정리했다.
- 보유 패널이 방금 지급한 장비를 선택하고 있는 동안 `Owned Status  Action:equip-now  State:fresh`가 표시되고, 장비 탭 footer도 `E equip new item`으로 바뀐다.
- 장착/해제 또는 수동 장비 변경이 발생하면 이 임시 상태는 정리된다.
- 이 단계로 후보 지급 이후의 다음 액션이 더 명확해졌고, 다음 Claude 작업은 이 신호를 실제 2패널 UI의 우측 패널 액션 강조 또는 장착 버튼 강조로 승격하기 쉬워졌다.
- 새 테스트 1개 추가: 후보 지급 직후 `Owned Status`와 footer가 장착 유도 텍스트로 바뀌는지 확인.

## 23차 증분 완료 상태 (2026-03-28)

fresh 장착 유도 상태의 해제 규칙 정리:
- `fresh` 상태는 이제 owned 목록 수동 순환, 페이지 이동, 정렬/필터 변경, 슬롯 이동, 포커스 전환 같은 수동 탐색이 들어오면 `_clear_recent_granted_selection()`으로 즉시 해제된다.
- 이 규칙으로 `지급 직후 바로 장착`이라는 의미가 탐색 행동과 섞이지 않게 되었고, footer와 `Owned Status`가 실제로 “지금 바로 E를 누르면 좋다”는 짧은 창구 역할만 하게 되었다.
- 다음 Claude 작업은 이 상태를 우측 패널의 일시적 액션 강조나 강조색/태그로 승격하더라도, 해제 타이밍을 새로 설계할 필요 없이 현재 규칙을 그대로 사용할 수 있다.
- 새 테스트 1개 추가: grant 직후 `Action:equip-now`가 보였다가 owned 수동 순환 후 일반 `Action:equip`으로 돌아오는지 확인.

## 24차 증분 완료 상태 (2026-03-28)

후보/보유 View 줄의 탐색 의미 공통화 1차:
- `Candidate View`는 이제 `Browse:Items x-y/n`, `Owned View`는 `Browse:p/q`를 함께 표시해 두 패널이 모두 “지금 무엇을 훑고 있는지”를 같은 `Browse:` 접두로 보여주도록 정리했다.
- 출력 자체는 여전히 candidate는 후보 창 범위, owned는 보유 페이지 요약을 보여주지만, 시각 언어는 더 가까워졌으므로 다음 Claude 작업은 `selection / navigation`과 함께 `Browse` 층까지 공통화하기 쉬워졌다.
- 새 테스트 1개 추가: candidate/owned 양쪽 `View` 줄이 각각 `Browse:` 요약을 포함하는지 확인.

## 25차 증분 완료 상태 (2026-03-28)

navigation 줄의 시각 용어 공통화 1차:
- 후보 패널의 `Candidate Window`, 보유 패널의 `Owned Page`를 각각 `Candidate Nav`, `Owned Nav`로 정리해 두 패널이 모두 탐색/이동 정보를 같은 `Nav` 계층으로 보여주도록 맞췄다.
- 동작은 그대로 유지하면서, 이제 후보는 창 범위, 보유는 페이지 범위를 `Nav` 줄로 보여주므로 다음 Claude 작업은 `selection / navigation / browse`를 공통 패널 의미 체계로 더 쉽게 정리할 수 있다.
- 새 테스트 여러 건을 갱신해 `Candidate Nav`, `Owned Nav` 문구가 실제 출력과 순서에서 유지되는지 확인했다.

## 26차 증분 완료 상태 (2026-03-28)

관리자 HUD 요약의 navigation 용어 공통화:
- `get_admin_tab_summary()`도 이제 candidate의 `Window[...]`, owned의 `Page[...]` 대신 공통 `Nav[...]`를 사용한다.
- 이 변경으로 장비 탭 본문과 HUD 요약이 모두 `Selection / Nav / Browse` 축을 같은 용어로 쓰게 되었고, 다음 Claude 작업은 실제 2패널 UI 승격 시 용어 재정의를 거의 하지 않아도 된다.
- 관련 테스트를 갱신해 candidate/owned 요약 모두 `Nav[...]` 기준으로 유지되는지 확인했다.

## 27차 증분 완료 상태 (2026-03-28)

selection 줄의 정보 밀도 공통화 1차:
- `Candidate Selection`이 이제 현재 후보 이름과 `[index/total]`을 함께 보여주므로, `Owned Selection`과 더 비슷한 문법으로 읽히게 되었다.
- 이 단계로 candidate/owned 양쪽이 모두 `Selection = 현재 대상 이름 + 현재 위치` 형태를 가지게 되었고, 다음 Claude 작업은 `selection / nav / browse`를 거의 동일한 패널 의미 슬롯으로 다루기 쉬워졌다.
- 관련 테스트를 갱신해 후보 선택 줄이 `(empty)`, `Ember Staff`, `Tempest Rod` 같은 현재 대상을 함께 표시하는지 확인했다.

## 28차 증분 완료 상태 (2026-03-28)

selection 줄 조립 helper 공통화:
- `_build_equipment_selection_line()`를 추가해 `Candidate Selection`, `Owned Selection`을 같은 조립 규칙으로 렌더하도록 정리했다.
- 출력은 유지하면서, 이제 두 패널의 `Selection` 줄은 이름/포커스/인덱스 포맷을 같은 helper에 의존하므로 다음 Claude 작업은 `Selection / Nav / Browse`를 실제 공통 패널 슬롯으로 더 쉽게 승격할 수 있다.
- 새 테스트 1개 추가: candidate/owned 양쪽 selection 줄이 같은 이름+인덱스 형식을 유지하는지 확인.

## 29차 증분 완료 상태 (2026-03-28)

view 줄 조립 helper 공통화:
- `_build_equipment_view_line()`를 추가해 `Candidate View`, `Owned View`를 같은 조립 규칙으로 렌더하도록 정리했다.
- 출력은 유지하면서, 이제 `Selection`에 이어 `View`도 공통 helper에 의존하므로 다음 Claude 작업은 `Selection / Nav / Browse`를 묶은 공통 패널 body 슬롯으로 승격하기 쉬워졌다.
- 새 테스트 1개 추가: candidate/owned 양쪽 view 줄이 같은 접두와 `Browse:` 정보를 유지하는지 확인.

## 30차 증분 완료 상태 (2026-03-28)

nav 줄 조립 helper 공통화:
- `_build_equipment_nav_line()`를 추가해 `Candidate Nav`, `Owned Nav`를 같은 조립 규칙으로 렌더하도록 정리했다.
- 출력은 유지하면서, 이제 `Selection`, `View`, `Nav`가 모두 공통 helper에 의존하므로 다음 Claude 작업은 이 세 줄을 실제 공통 패널 body 슬롯으로 묶는 데 집중할 수 있다.
- 새 테스트 1개 추가: candidate/owned 양쪽 nav 줄이 같은 접두와 탐색 정보를 유지하는지 확인.

## 31차 증분 완료 상태 (2026-03-28)

selection / view / nav 묶음 조립 helper 추가:
- `_build_equipment_navigation_section_lines()`를 추가해 `View -> Selection -> Nav` 세 줄을 하나의 공통 body 묶음으로 조립하도록 정리했다.
- 출력은 유지하면서, 이제 장비 패널 본문은 `primary -> detail -> navigation-section -> list` 구조로 읽을 수 있다.
- 이 단계로 다음 Claude 작업은 이 navigation section 묶음을 실제 `좌측 후보 / 우측 보유` 2패널 body 슬롯으로 승격하는 데 바로 들어갈 수 있다.
- 새 테스트 1개 추가: candidate 패널에서 `View -> Selection -> Nav -> List` 순서가 하나의 탐색 묶음처럼 유지되는지 확인.

## 32차 증분 완료 상태 (2026-03-28)

candidate body order를 owned와 완전히 대칭화:
- `_get_candidate_panel_body_source()`의 `primary_line`을 `_get_candidate_selection_line()`으로 교체해 `Candidate Selection  [FOCUS]  이름  [i/n]`이 패널 본문의 첫 줄이 되도록 정리했다.
- 분리된 `Grant Candidate  [FOCUS]  이름  [owned/not-owned]` primary 줄을 제거했다. 소유 상태 정보는 바로 아래 `Candidate View  State:owned/not-owned` 줄에 여전히 표시된다.
- `selection_line` 슬롯은 이제 `""` (빈 값)으로, owned 패널과 동일하게 primary 하나로 이름+위치를 표현한다.
- candidate/owned 양쪽 body 순서가 `Selection → Detail → View → Nav → List`로 완전히 일치한다.
- `ownership_text` 파라미터를 `_get_candidate_panel_lines()`, `_get_candidate_panel_body_source()`, 호출부에서 제거했다 (view 줄이 내부에서 직접 계산).
- 테스트 5곳 갱신: `Grant Candidate` 참조 3건 → `Candidate Selection` 참조, 순서 검증 테스트 2건 → `selection < detail < view < nav` 순서로 변경.
- 전체 테스트 126/126 통과.

## 33차 증분 완료 상태 (2026-03-28)

navigation section source 구조 추출:
- `_build_equipment_navigation_section_source()`를 추가해 `View / Selection / Nav` 3줄을 body source 단계에서도 하나의 `navigation_section` 블록으로 다루도록 정리했다.
- `_build_equipment_panel_body_source()`는 이제 `view_line`, `selection_line`, `navigation_line` 개별 key 대신 `navigation_section` dictionary를 받는다.
- `_build_equipment_panel_body_lines()`는 이 block을 읽어 `View -> Selection -> Nav`를 렌더하므로, 다음 Claude 작업은 panel body 차이를 줄 단위가 아니라 section 단위로 다룰 수 있다.
- 쓰이지 않던 `Grant Candidate ...` primary helper는 제거했고, candidate/owned 모두 `Selection`이 body 첫 줄인 상태를 유지한다.
- 새 테스트 1개 추가: owned 패널에서도 `View -> Nav -> List` 순서가 navigation section 구조를 따라 유지되는지 확인.

## 34차 증분 완료 상태 (2026-03-28)

content section source 구조 추출:
- `_build_equipment_panel_content_section_source()`를 추가해 `Detail + NavigationSection + List`를 body source 단계에서도 하나의 `content_section` block으로 다루도록 정리했다.
- `_build_equipment_panel_body_source()`는 이제 `primary_line`과 `content_section`만 받는다.
- `_build_equipment_panel_body_lines()`는 `primary -> content_section` 구조를 읽어 렌더하므로, 다음 Claude 작업은 panel body를 줄 묶음이 아니라 `primary / content` 두 큰 슬롯으로 다룰 수 있다.
- 이 단계로 `candidate / owned` 패널은 모두 `panel -> body source -> content section -> navigation section` 구조를 갖게 되었고, 2패널 텍스트 UI 승격 시 입력 단위가 더 명확해졌다.
- 새 테스트 1개 추가: candidate 패널에서도 `Detail -> View -> Nav -> List`가 content section 구조를 따라 유지되는지 확인.

## 35차 증분 완료 상태 (2026-03-28)

content section 렌더 helper 추출:
- `_build_equipment_panel_content_section_lines()`를 추가해 `Detail + NavigationSection + List`를 실제 렌더 단계에서도 하나의 `content_section` helper로 조립하도록 정리했다.
- `_build_equipment_panel_body_lines()`는 이제 `primary_line`을 붙인 뒤 `content_section` 전체를 helper에 위임한다.
- 이 단계로 panel body는 코드상으로도 `primary / content` 두 큰 슬롯으로 더 명확하게 나뉘었고, 다음 Claude 작업은 이 두 슬롯을 바로 좌우 2패널 텍스트 배치 helper의 입력으로 사용할 수 있다.
- 새 테스트 1개 추가: owned 패널에서도 `Detail -> View -> Nav -> List`가 content section helper 구조를 따라 유지되는지 확인.

## 36차 증분 완료 상태 (2026-03-28)

candidate / owned 상단 동시 요약 추가:
- 장비 탭 비교 섹션 아래에 `Panel Summary`, `Panel Flow` 두 줄을 추가해 후보/보유 패널의 현재 대상, 액션, 탐색 범위를 한 번에 읽을 수 있도록 정리했다.
- `Panel Summary`는 `Candidate:...  Owned:...`를 보여주고, `Panel Flow`는 `Candidate:grant  Owned:equip/equip-now  Browse:후보범위 | 보유페이지`를 보여준다.
- 이 줄은 실제 좌우 2패널 배치 전의 bridge 역할을 한다. 즉, 아직 본문은 stacked 상태지만 상단에서는 이미 좌/우 패널의 핵심 상태를 동시에 읽을 수 있다.
- 새 테스트 2개 추가: 기본 장비 탭에서 dual-panel preview가 보이는지, grant 직후 `Owned:equip-now`로 승격되는지 확인.

## 37차 증분 완료 상태 (2026-03-28)

dual-panel preview source/helper 추출:
- `_build_equipment_dual_panel_preview_source()`와 `_build_equipment_dual_panel_preview_lines_from_source()`를 추가해 `Panel Summary / Panel Flow`도 source 기반 helper 구조로 정리했다.
- 이 단계로 장비 탭 상단 bridge 영역은 `candidate_name / owned_name / candidate_action / owned_action / candidate_browse / owned_browse`를 입력으로 받는 독립 블록이 되었고, 다음 Claude 작업은 이 블록을 실제 좌우 2패널 헤더나 비교 헤더로 그대로 승격할 수 있다.
- 새 테스트 1개 추가: `Panel Summary -> Panel Flow -> Candidate 패널` 순서가 유지되는지 확인.

## 38차 증분 완료 상태 (2026-03-28)

상단 overview section helper 추가:
- `_get_equipment_overview_section_lines()`를 추가해 `Compare Header / Slot Stats / Candidate Compare`와 `Panel Summary / Panel Flow`를 하나의 상단 overview 섹션으로 묶었다.
- 출력은 유지하면서, 이제 장비 탭 상단은 `overview section -> panel bodies` 구조로 읽을 수 있다.
- 이 단계로 다음 Claude 작업은 상단 overview section을 실제 2패널 헤더/비교 헤더로, 하단 `primary / content_section`을 2패널 본문으로 나누는 작업에 바로 들어갈 수 있다.
- 새 테스트 1개 추가: `Compare Header -> Panel Summary -> Panel Flow` 순서가 유지되는지 확인.

## 39차 증분 완료 상태 (2026-03-28)

overview section source/helper 추출:
- `_build_equipment_overview_section_source()`와 `_build_equipment_overview_section_lines_from_source()`를 추가해 상단 overview도 source 기반 helper 구조로 정리했다.
- 이 단계로 장비 탭 상단은 `compare_lines + dual_panel_preview_lines`를 입력으로 받는 독립 block이 되었고, 다음 Claude 작업은 이 block 전체를 실제 2패널 헤더 영역으로 그대로 승격할 수 있다.
- 새 테스트 1개 추가: `Panel Flow`가 `Equipment Focus`보다 먼저 나와 상단 overview block이 focus 라인보다 위에 유지되는지 확인.

## 40차 증분 완료 상태 (2026-03-28)

최상위 equipment layout helper 추가:
- `_build_equipment_tab_layout_lines()`를 추가해 장비 탭의 최상위 조립을 `overview section -> focus line -> candidate panel -> owned panel` 규칙으로 고정했다.
- 현재 출력은 stacked 상태 그대로 유지하지만, 이제 다음 Claude 작업은 이 helper 내부만 바꿔 실제 좌우 2패널 텍스트 배치로 승격할 수 있다.
- 이 단계로 장비 탭 구조는 `overview section`과 `panel bodies`를 모두 독립 helper로 가진 상태가 되었고, 2패널 전환 시 수정 범위를 최상위 레이아웃 helper 하나로 더 강하게 한정할 수 있다.
- 새 테스트 1개 추가: candidate 패널이 owned 패널보다 먼저 배치되는 최상위 순서를 확인.

## 41차 증분 완료 상태 (2026-03-28)

focus line을 최상위 layout helper 안으로 재정렬:
- `_build_equipment_tab_layout_lines()`는 이제 `overview section -> focus line -> candidate panel -> owned panel` 순서를 실제 출력에서도 보장한다.
- 이 정리로 상단 overview block이 온전히 유지되고, `Equipment Focus`는 상단 요약과 패널 본문 사이의 얇은 상태 라인으로 자리 잡았다.
- 다음 Claude 작업은 이 helper 내부만 바꿔 `overview / focus / left panel / right panel` 형태의 실제 2패널 텍스트 배치로 바로 승격할 수 있다.
- 기존 순서 검증 테스트는 그대로 유지하고, `Panel Flow`가 `Equipment Focus`보다 먼저 오는 현재 동작을 계속 보장한다.

## 42차 증분 완료 상태 (2026-03-28)

최상위 layout source/helper 추출:
- `_build_equipment_tab_layout_source()`와 `_build_equipment_tab_layout_lines_from_source()`를 추가해 최상위 장비 탭 레이아웃도 source 기반 helper 구조로 정리했다.
- 이 단계로 장비 탭 전체는 `overview_lines / focus_line / candidate_lines / owned_lines`를 입력으로 받는 독립 layout block이 되었고, 다음 Claude 작업은 이 source를 그대로 사용해 실제 좌우 2패널 텍스트 배치 helper로 승격할 수 있다.
- 새 테스트 1개 추가: `overview -> focus -> candidate -> owned` 최상위 순서가 유지되는지 확인.

## 43차 증분 완료 상태 (2026-03-28)

최상위 layout helper에 2패널 bridge 줄 추가:
- `_build_equipment_two_panel_bridge_lines()`를 추가해 최상위 장비 탭 레이아웃 안에 `Panel Columns  Left:Candidate  Right:Owned`, `Panel Mode  stacked bridge (2-panel ready)` 두 줄을 넣었다.
- 이 줄은 아직 실제 좌우 렌더는 아니지만, 현재 stacked 출력이 이미 `후보 패널 / 보유 패널` 2패널 승격 직전 상태라는 점을 본문에서 직접 드러낸다.
- 최상위 순서는 이제 `overview -> focus -> two-panel bridge -> candidate -> owned`로 더 명확해졌고, 다음 Claude 작업은 이 bridge 영역을 실제 좌우 텍스트 배치 helper로 교체하면 된다.
- 새 테스트 2개 추가: bridge 줄이 실제로 표시되는지, 그리고 `focus -> bridge -> candidate -> owned` 순서가 유지되는지 확인.

## 44차 증분 완료 상태 (2026-03-28)

최상위 layout helper에 left/right panel slot wrapper 추가:
- `_build_equipment_panel_slot_lines()`를 추가해 `candidate_lines`, `owned_lines`를 각각 `Left Panel Slot  Candidate`, `Right Panel Slot  Owned` 아래에 감싸도록 정리했다.
- 아직 실제 side-by-side 텍스트 렌더는 아니지만, 최상위 layout helper가 이제 단순 stacked append가 아니라 `left slot / right slot` 개념을 직접 가진다.
- 이 단계로 다음 Claude 작업은 `_build_equipment_panel_slot_lines()`를 실제 좌우 column renderer로 교체하거나, 그 위에 side-by-side helper를 얹는 방식으로 더 안전하게 2패널 UI 승격을 진행할 수 있다.
- 새 테스트 2개 갱신: `overview -> focus -> bridge -> left slot -> candidate -> right slot -> owned` 순서와 slot 라벨 표시를 확인.

## 45차 증분 완료 상태 (2026-03-28)

left/right panel slot section source/helper 추출:
- `_build_equipment_panel_slot_section_source()`와 `_build_equipment_panel_slot_section_lines_from_source()`를 추가해 최상위 layout helper가 더 이상 `candidate_lines / owned_lines`를 직접 이어붙이지 않도록 정리했다.
- 이제 최상위 layout은 `overview_lines / focus_line / panel_slot_section`을 다루고, `panel_slot_section` 내부가 `left_slot_lines / right_slot_lines`를 가진다.
- 이 단계로 다음 Claude 작업은 최상위 layout helper 전체를 건드리기보다 `panel_slot_section` 렌더 helper를 실제 좌우 column renderer로 교체하는 데 집중할 수 있다.
- 새 테스트 1개 추가: left slot과 right slot이 같은 slot section 안에서 순서와 간격을 유지하는지 확인.

## 46차 증분 완료 상태 (2026-03-28)

panel slot section renderer에 layout_mode 추가:
- `panel_slot_section` source는 이제 `layout_mode: stacked_fallback`까지 가진다.
- `_build_equipment_panel_slot_section_lines_from_source()`는 이제 `layout_mode`를 읽어 stacked fallback renderer를 호출하므로, 다음 Claude 작업은 이 함수 내부에 `side_by_side` 분기만 추가하면 된다.
- `_build_equipment_panel_slot_section_stacked_lines()`를 별도 helper로 분리해 현재 fallback 출력 경로를 고정했다.
- 새 테스트 1개 추가: 현재 장비 탭이 bridge 아래에서 stacked fallback slot section renderer를 계속 사용하고 있음을 확인.

## 47차 증분 완료 상태 (2026-03-28)

side_by_side renderer 분기와 helper 시그니처 추가:
- `_build_equipment_panel_slot_section_lines_from_source()`는 이제 `layout_mode == "side_by_side"` 분기를 실제로 가진다.
- `_build_equipment_panel_slot_section_side_by_side_lines()` helper도 추가해, 다음 단계에서 실제 좌우 텍스트 배치를 이 함수 안에 구현할 수 있게 준비했다.
- 현재 `side_by_side` helper 본문은 아직 stacked fallback을 그대로 재사용한다. 즉, 구조만 먼저 열어두고 출력 변화는 의도적으로 막았다.
- 새 테스트 1개 추가: renderer 분기 준비 이후에도 현재 stacked bridge 출력과 slot 라벨이 그대로 유지되는지 확인.

## 48차 증분 완료 상태 (2026-03-28)

side_by_side helper에 실제 column formatter 추가:
- `_build_equipment_panel_slot_section_side_by_side_lines()`는 이제 좌우 배열 길이를 맞춰 순회하고, `_get_equipment_panel_column_width()`, `_build_equipment_side_by_side_row()`를 이용해 실제 두 컬럼 문자열을 조립한다.
- 아직 `layout_mode`는 `stacked_fallback`이므로 실제 장비 탭 출력은 바뀌지 않는다. 하지만 다음 단계에서 `side_by_side`를 켜면 최소 column renderer는 이미 동작하는 상태다.
- 컬럼 폭은 현재 좌우 패널 줄 중 가장 긴 길이와 `EQUIPMENT_PANEL_COLUMN_MIN_WIDTH`를 기준으로 계산한다.
- 새 테스트 1개 추가: `side_by_side` helper가 sample slot section을 받아 같은 줄에 좌우 패널 텍스트를 함께 배치하는지 확인.

## 49차 증분 완료 상태 (2026-03-28)

side_by_side renderer 설정값을 slot section source로 승격:
- `_build_equipment_panel_slot_section_source()`는 이제 `column_width`, `column_separator`도 함께 가진다.
- `_build_equipment_panel_slot_section_side_by_side_lines()`는 source에서 `column_width`, `column_separator`를 읽고, 없을 때만 기본 계산값을 사용한다.
- 이 단계로 다음 Claude 작업은 `layout_mode`만 `side_by_side`로 전환한 뒤, 필요하면 source 단계의 폭/구분자만 조정해 출력 가독성을 다듬을 수 있다.
- 새 테스트 1개 추가: source가 준 `column_separator`가 실제 side-by-side helper 출력에 반영되는지 확인.

## 50차 증분 완료 상태 (2026-03-28)

layout_mode 결정 지점 단일화:
- `_get_equipment_panel_slot_layout_mode()`를 추가해 `panel_slot_section` source와 상단 bridge 문구가 같은 mode 결정 함수를 사용하도록 정리했다.
- `_get_equipment_panel_layout_mode_label()`를 추가해 bridge 줄의 `Panel Mode ...` 문구도 layout_mode에서 파생되도록 맞췄다.
- 현재 helper는 계속 `stacked_fallback`을 반환하므로 출력 변화는 없다. 하지만 다음 Claude 작업은 이 helper 하나만 바꿔 bridge 문구와 slot section renderer 전환을 같이 움직일 수 있다.
- 이 단계로 `layout_mode` 전환 지점이 한 군데로 줄었고, 실제 2패널 승격의 변경 범위도 더 명확해졌다.

## 51차 증분 완료 상태 (2026-03-28)

debug용 side_by_side 모드 전환 경로 추가:
- `equipment_panel_layout_mode_override`와 `debug_set_equipment_panel_layout_mode()`를 추가해 테스트나 디버그에서 실제 장비 탭을 `side_by_side` 모드로 전환할 수 있게 했다.
- 당시 기본값은 여전히 `stacked_fallback`이었으므로 실제 플레이 기본 출력은 바뀌지 않았다.
- 새 테스트 1개 추가: debug 전환 시 `Panel Mode  side-by-side`가 표시되고, `Left Panel Slot  Candidate`와 `Right Panel Slot  Owned`가 같은 줄에 나타나는지 확인.
- 이 단계로 다음 Claude 작업은 “조건부로 side_by_side를 켠다”는 실제 적용 문제만 다루면 되고, renderer 자체의 동작 검증은 이미 테스트로 고정된 상태가 되었다.

## 52차 증분 완료 상태 (2026-03-28)

side_by_side를 장비 탭 기본 출력으로 승격:
- `_get_equipment_panel_slot_layout_mode()`의 기본 반환값을 `side_by_side`로 올려, 장비 탭 기본 출력이 이제 실제 좌우 2패널 텍스트 slot section renderer를 사용하게 됐다.
- `equipment_panel_layout_mode_override`는 그대로 유지되므로, 테스트/디버그에서는 여전히 `stacked_fallback`과 `side_by_side`를 명시적으로 오갈 수 있다.
- bridge 줄도 이제 기본적으로 `Panel Mode  side-by-side`를 표시하므로, 상단 overview와 하단 slot section renderer가 같은 모드를 가리킨다.
- 새 테스트/갱신:
  - 기본 출력이 `side-by-side` 모드를 쓰는지 확인
  - `stacked_fallback` override 시 예전 fallback 출력이 유지되는지 확인
  - debug로 `side_by_side`를 다시 강제해도 현재 출력이 안정적인지 확인
- 이 단계로 장비 탭은 더 이상 “2패널 직전”이 아니라, 최소 텍스트 기반 2패널 출력이 실제 기본값으로 올라온 상태다.

## 53차 증분 완료 상태 (2026-03-28)

side_by_side 기본 출력 가독성 개선 1차:
- `EQUIPMENT_PANEL_COLUMN_SEPARATOR`를 `"    "` (공백 4칸)에서 `"  |  "` (파이프 구분자)로 변경해 두 패널 경계가 텍스트에서 즉시 보이도록 했다.
- `_get_equipment_panel_column_width()`를 좌측 패널 줄만 사용해 폭을 계산하도록 수정했다. 이전에는 좌우 모두의 max를 썼으므로, 우측 패널에 긴 줄이 있으면 좌측 column이 불필요하게 넓어지는 문제가 있었다.
- 새 테스트 2개 추가:
  - 기본 side_by_side 출력에서 combined slot line에 `|`가 포함되는지 확인
  - 우측 패널의 긴 줄이 좌측 column_width 계산에 영향을 주지 않는지 확인
- 전체 테스트 148/148 통과.

## 54차 증분 완료 상태 (2026-03-28)

좌측 컬럼 오버플로우 보호:
- `_build_equipment_side_by_side_row()`에 `clamped` 처리를 추가해, 좌측 줄이 `column_width`를 초과하면 `column_width - 1` 글자까지 자르고 `~`를 붙이도록 했다.
- 이 처리로 우측 컬럼 시작 위치(구분자 `|`)가 긴 좌측 줄에 밀리지 않고 항상 고정 위치에 나타난다.
- 새 테스트 1개 추가: 좌측 줄이 `column_width`를 초과하는 row에서 `|` 위치가 정확히 `column_width`에 고정되고 `~` 마커가 포함되는지 확인.

## 55차 증분 완료 상태 (2026-03-28)

fresh equip-now 상태 `[!]` 마커 추가:
- `_get_equipment_panel_status_line("owned")`의 fresh 분기에 `  [!]`를 붙여 `Action:equip-now  State:fresh  [!]`로 출력되도록 했다.
- side-by-side 우측 패널에서 fresh 상태가 `[!]`로 즉시 눈에 띄도록 한다. 기존 substring 기반 테스트는 그대로 통과한다.
- 새 테스트 1개 추가: grant 후 owned 패널 본문에 `[!]`가 포함되는지 확인.
- 전체 테스트 150/150 통과.

## 56차 증분 완료 상태 (2026-03-28)

패널 슬롯 헤더 단축 + 후보 패널 페이지 구조 전환:

- `_build_equipment_panel_slot_lines()` 헤더를 `"Left Panel Slot  Candidate"` → `"[Candidate]"`, `"Right Panel Slot  Owned"` → `"[Owned]"` 형태로 단축. combined side-by-side row가 더 컴팩트하게 읽힌다.
- 후보 패널의 탐색 구조를 sliding window(CANDIDATE_PREVIEW_RADIUS=1, 항목 3개 고정)에서 page-based(EQUIPMENT_PAGE_SIZE=5)로 전환:
  - `_get_candidate_window_line()`: radius 기반 범위 계산 → page 기반 `Items start-end/total` 계산
  - `_get_candidate_preview_lines()`: ±radius 범위 → page 기반 범위 렌더
  - `_cycle_candidate_window()`: `direction * (radius*2+1)` 이동 → `_cycle_owned_page()`와 동일한 페이지 단위 이동, `_clear_recent_granted_selection()` 호출 추가
  - push_message "window" → "page" 문구 통일
- 테스트 갱신:
  - `"Left Panel Slot  Candidate"` / `"Right Panel Slot  Owned"` → `"[Candidate]"` / `"[Owned]"` (replace_all)
  - `"Items 1-2/3"` → `"Items 1-3/3"` (replace_all, 3 items ≤ page size → single page shows all)
  - `test_admin_menu_can_cycle_candidate_window_when_candidate_panel_is_focused`: 단일 페이지에서 cycling이 제자리를 유지하는 것을 검증하도록 재작성
  - `test_admin_menu_can_toggle_owned_filter_mode`: `body.contains("Ash Tome")` → `_get_owned_equipment_preview_lines()` 직접 호출로 owned-list-specific 검증
- 전체 159/159 통과

다음 안전한 단계:
- Owned Detail 줄을 패널 내 스크롤로 확장 (설명이 길 때 잘림 방지)
- 관리자 버프 탭 강제 발동 (Increment 3 미완료 항목)
- `notify_deploy_kill()` 호출 연결 (enemy_base.gd / 배치형 스킬 처치 시 호출)

## 58차 증분 완료 상태 (2026-03-28)

버프 탭 조합 요건 per-requirement 상태 표시:
- `_get_buff_tab_lines()`의 콤보 섹션에서 각 required_buff마다 `[v]` (현재 활성) 또는 `[ ]` (비활성) 체크를 요건 이름 앞에 추가.
- 이 단계로 관리자가 한 화면에서 어떤 버프를 추가로 켜야 조합이 발동하는지 즉시 확인할 수 있다.
- 새 테스트 1개 추가: Ashen Rite 요건 중 하나만 활성 시 `[v]`와 `[ ]`가 같은 줄에 함께 표시되는지 확인.
- 전체 209/209 통과.

## 69차 증분 완료 상태 (2026-03-29)

장비 탭 장착/해제 액션 버튼 추가:
- `_equipment_action_button_bar: HBoxContainer`, `_equipment_interact_button: Button` 변수 추가
- `_build_ui()`에서 `_candidate_item_button_bar` 아래에 버튼 바 추가. "Interact" 버튼 1개. 초기값 `visible = false`
- `_get_equipment_interact_label()`: candidate 모드+항목 선택 시 "Grant", owned 모드+인벤토리 항목 선택 시 "Equip", owned 모드+장착 중+인벤토리 없음 시 "Unequip", 그 외 "Interact" 반환
- `_refresh_equipment_action_buttons()`: equipment 탭 활성 시 표시, `_equipment_interact_button.text` 동적 업데이트. `_refresh()`에서 호출
- `_on_equipment_interact_button_pressed()`: `_handle_equipment_interact()` → refresh
- `debug_click_equipment_interact()` 추가
- GUT 6개 추가: 비장비 탭 숨김, 장비 탭 표시+버튼 존재, 후보 모드+항목 선택 시 "Grant", 인벤토리 보유 시 "Equip", 장착+인벤토리 없음 시 "Unequip", 클릭 시 실제 grant 실행
- 전체 306/306 통과

### 마우스 클릭 경로 완료 요약 (2026-03-29)

Increment 7 목표였던 관리자 메뉴 전체 마우스 클릭 경로가 완료됨:
- 탭 전환 버튼 (`_tab_button_nodes`)
- 장비 슬롯 버튼 (`_slot_button_nodes`)
- 핫바 슬롯 버튼 (`_hotbar_slot_button_nodes`)
- 보유 장비 목록 버튼 (`_owned_item_button_nodes`)
- 후보 장비 목록 버튼 (`_candidate_item_button_nodes`)
- 장비 상호작용 버튼 (`_equipment_interact_button`, 동적 Grant/Equip/Unequip)
- 소환 타입 버튼 + Clear/Freeze 버튼 (`_spawn_button_nodes`, `_spawn_action_button_bar`)
- 자원 토글 버튼 (`_resource_hp/mp/cd/buff_button`, Heal, Reset CD)
- 버프 항목 버튼 + Prev/Next/Activate/Clear (`_buff_item_button_nodes`, `_buff_action_button_bar`)
- 핫바 프리셋 버튼 (`_preset_button_nodes`)
- 스킬 라이브러리 항목 버튼 + LibFocus 토글 (`_library_item_button_nodes`, `_library_focus_button`)

다음 추천 작업: 전투 HUD 마우스 클릭 경로 추가 (Increment 6 확장) 또는 관리자 메뉴 그래픽 GUI 변환 (텍스트 본문 → 패널/버튼/아이콘).

## 68차 증분 완료 상태 (2026-03-29)

핫바 탭 스킬 라이브러리 항목 클릭 버튼 추가:
- `_library_item_button_bar: HBoxContainer`, `_library_item_button_nodes: Array[Button]` (5개), `_library_focus_button: Button` 변수 추가
- `_build_ui()`에서 `_preset_button_bar` 아래에 라이브러리 버튼 바 추가. 5개 아이템 버튼 + LibFocus 토글 버튼. 초기값 `visible = false`
- `_refresh_library_buttons()`: hotbar 탭 활성 시 표시. `selected_library_index` 기준 슬라이딩 윈도우(start=max(sel-2,0), end=min(sel+3,size)) 계산. 윈도우 범위 내 버튼 스킬명 표시+`flat=(item_index != selected_index)`, 범위 밖은 `---`+disabled. `_library_focus_button.flat = not library_focus`. `_refresh()`에서 호출
- `_on_library_item_button_pressed(window_position)`: 윈도우 시작 인덱스+위치로 절대 인덱스 계산. 범위 밖이면 무시. `selected_library_index = target_index` → refresh
- `_on_library_focus_button_pressed()`: `library_focus` 토글 → push_message → refresh
- `debug_click_library_item(window_position)`, `debug_click_library_focus_toggle()` 추가
- GUT 6개 추가: hotbar 외 탭에서 숨김, hotbar 탭에서 표시+노드 수, 클릭 시 선택 인덱스 변경, 포커스 토글, 포커스 버튼 flat 상태, 선택 아이템 flat=false
- 전체 300/300 통과

## 60차 증분 완료 상태 (2026-03-29)

관리자 메뉴 장비 슬롯 마우스 클릭 버튼 추가:
- `EQUIPMENT_SLOT_LABELS` 상수 추가 (weapon→Weapon, offhand→Offhand 등 7종 표시명)
- `_slot_button_bar: HBoxContainer`, `_slot_button_nodes: Array[Button]` 변수 추가
- `_build_ui()`에서 footer_label 바로 위에 `HBoxContainer` 슬롯 바 추가. `equipment_slot_order` 순서대로 7개 Button 생성, `pressed.connect(_on_equipment_slot_button_pressed.bind(i))` 연결. 초기값 `visible = false`
- `_on_equipment_slot_button_pressed(slot_index)`: `_clear_recent_granted_selection()` → `selected_equipment_slot = slot_index` → `_refresh()`
- `_refresh_slot_buttons()`: 장비 탭 활성 시 슬롯 바 표시 + 선택 슬롯 `flat=false`, 나머지 `flat=true`. 타 탭 시 숨김
- `_refresh()`에서 `_refresh_slot_buttons()` 호출 추가
- `debug_click_equipment_slot(slot_index)`: 테스트용 클릭 시뮬레이션
- GUT 4개 추가: 비장비 탭에서 슬롯 바 숨김, 장비 탭에서 슬롯 바 표시+노드 수, 클릭 시 슬롯 변경, 활성/비활성 flat 상태
- 전체 266/266 통과

## 67차 증분 완료 상태 (2026-03-29)

핫바 탭 프리셋 마우스 클릭 버튼 추가:
- `_preset_button_bar: HBoxContainer`, `_preset_button_nodes: Dictionary` 변수 추가
- `_build_ui()`에서 `_buff_action_button_bar` 아래에 `HOTBAR_PRESET_IDS` 순서대로 7개 프리셋 버튼 생성. 초기값 `visible = false`
- `_refresh_preset_buttons()`: hotbar 탭 활성 시 표시. `current_hotbar_preset_id`와 일치하는 버튼 `flat=false`, 나머지 `flat=true`. `_refresh()`에서 호출
- `_on_preset_button_pressed(preset_id)`: `preset_index` 업데이트 → `_apply_hotbar_preset(preset_id)` → refresh
- `debug_click_preset(preset_id)`: 테스트용 시뮬레이션
- GUT 4개 추가: 비핫바 탭 숨김, 핫바 탭 표시+노드 수, 클릭 시 프리셋 적용, 활성/비활성 flat 상태
- 전체 294/294 통과

## 66차 증분 완료 상태 (2026-03-29)

버프 탭 버프 항목 마우스 클릭 버튼 추가:
- `BUFF_PAGE_SIZE := 8` 상수 추가
- `_buff_item_button_bar: HBoxContainer`, `_buff_item_button_nodes: Array[Button]` 변수 추가
- `_buff_action_button_bar: HBoxContainer`, `_buff_prev_page_button`, `_buff_next_page_button: Button` 변수 추가
- `_build_ui()`에서 `_resource_button_bar` 아래에 버프 항목 바(8개) + 액션 바(< Prev, Next >, Activate, Clear All) 생성
- `_get_buff_page_start()`: 현재 선택 인덱스 기준 페이지 시작점 계산 helper
- `_refresh_buff_buttons()`: buffs 탭 활성 시 표시. 페이지별 항목 텍스트(8자 truncate), 선택 항목 `flat=false`, Prev/Next 범위 밖 시 disabled. `_refresh()`에서 호출
- `_on_buff_item_button_pressed(page_position)`: 현재 페이지 기준 항목 선택
- `_on_buff_prev/next_page_pressed()`: BUFF_PAGE_SIZE 단위 페이지 이동
- `_on_buff_activate/clear_button_pressed()`: 기존 `_force_activate_selected_buff()` / `_clear_active_buffs()` 호출
- `debug_click_buff_item/activate/clear/buff_next_page()` 추가
- GUT 4개 추가: 비버프 탭 숨김, 버프 탭 표시+노드 수, 클릭 시 선택+flat 상태, Clear 버튼 동작
- 전체 290/290 통과

## 65차 증분 완료 상태 (2026-03-29)

자원 탭 토글/액션 마우스 클릭 버튼 추가:
- `_resource_button_bar: HBoxContainer`, `_resource_hp_button / _resource_mp_button / _resource_cd_button / _resource_buff_button: Button` 변수 추가
- `_build_ui()`에서 `_spawn_action_button_bar` 아래에 자원 버튼 바 생성 (Inf HP, Inf MP, No CD, Free Buff, Heal, Rst CD). 초기값 `visible = false`
- `_refresh_resource_buttons()`: resources 탭 활성 시 표시. 각 토글 버튼은 `flat = not <toggle_state>`로 활성 상태 표시. `_refresh()`에서 호출
- `_on_resource_hp/mp/cd/buff_button_pressed()`: 해당 GameState 토글 → push_message → refresh
- `_on_resource_heal/reset_cd_button_pressed()`: 각 신호 방출
- `debug_click_resource_hp/mp/cd/buff()`: 테스트용 시뮬레이션
- GUT 4개 추가: 비자원 탭 숨김, 자원 탭 표시+버튼 존재, HP 토글 상태+flat, CD 토글 상태+flat
- 전체 286/286 통과

## 64차 증분 완료 상태 (2026-03-29)

소환 탭 적 타입 마우스 클릭 버튼 추가:
- `SPAWN_BUTTON_LABELS`, `SPAWN_ENEMY_ORDER` 상수 추가 (10종 적 표시명/순서 정의)
- `_spawn_button_bar: HBoxContainer`, `_spawn_button_nodes: Dictionary` 변수 추가
- `_spawn_action_button_bar: HBoxContainer`, `_spawn_freeze_button: Button` 변수 추가
- `_build_ui()`에서 `_candidate_item_button_bar` 아래에 소환 버튼 바(10종) + 액션 버튼 바(Clear All, Freeze AI) 생성. 초기값 `visible = false`
- `_refresh_spawn_buttons()`: spawn 탭 활성 시 두 버튼 바 표시. Freeze AI 버튼은 `flat = not admin_freeze_ai`로 상태 표시. `_refresh()`에서 호출
- `_on_spawn_enemy_button_pressed(enemy_type)`: `spawn_enemy_requested` 신호 방출
- `_on_spawn_clear_button_pressed()`: `clear_enemies_requested` 신호 방출
- `_on_spawn_freeze_button_pressed()`: AI 토글, 신호 방출, refresh
- `debug_click_spawn_enemy/clear/freeze()`: 테스트용 시뮬레이션
- GUT 4개 추가: 비소환 탭 숨김, 소환 탭 표시+노드 수, 소환 버튼 신호 검증(watch_signals), Freeze 토글 상태
- 전체 282/282 통과

## 63차 증분 완료 상태 (2026-03-29)

후보 장비 목록 아이템 마우스 클릭 버튼 추가:
- `_candidate_item_button_bar: HBoxContainer`, `_candidate_item_button_nodes: Array[Button]` 변수 추가
- `_build_ui()`에서 `_owned_item_button_bar` 아래에 `EQUIPMENT_PAGE_SIZE(5)`개 버튼 생성. 초기값 `visible = false`
- `_refresh_candidate_item_buttons()`: 장비 탭 활성 시 표시. `equipment_catalog_by_slot`의 현재 페이지 항목별로 버튼 텍스트 업데이트, 선택 항목 `flat=false`. `_refresh()`에서 호출
- `_on_candidate_item_button_pressed(page_position)`: 현재 페이지 기준 `page_start + page_position`으로 `equipment_candidate_index_by_slot` 업데이트 → `equipment_focus_mode = "candidate"` 전환 → refresh. 범위 밖 클릭은 무시
- `debug_click_candidate_item_button(page_position)`: 테스트용 시뮬레이션
- GUT 4개 추가: 비장비 탭 숨김, 장비 탭 표시+노드 수, 클릭 시 선택+포커스 전환, 범위 밖 클릭 무시
- 전체 278/278 통과

## 62차 증분 완료 상태 (2026-03-29)

보유 장비 목록 아이템 마우스 클릭 버튼 추가:
- `_owned_item_button_bar: HBoxContainer`, `_owned_item_button_nodes: Array[Button]` 변수 추가
- `_build_ui()`에서 `_hotbar_slot_button_bar` 아래에 `EQUIPMENT_PAGE_SIZE(5)`개 버튼 생성. 초기값 `visible = false`
- `_refresh_owned_item_buttons()`: 장비 탭 활성 시 표시. 현재 페이지 항목마다 `_display_name` 첫 10자로 버튼 텍스트 설정, 항목 없는 위치는 `---`으로 disabled. 선택 항목은 `flat=false`. `_refresh()`에서 호출
- `_on_owned_item_button_pressed(page_position)`: 현재 페이지 기준 `page_start + page_position`으로 `equipment_owned_index_by_slot` 업데이트 → `equipment_focus_mode = "owned"` 전환 → refresh. 범위 밖 클릭은 무시
- `debug_click_owned_item_button(page_position)`: 테스트용 시뮬레이션
- GUT 4개 추가: 비장비 탭 숨김, 장비 탭 표시+노드 수, 클릭 시 선택 변경+포커스 전환, 범위 밖 클릭 무시
- 전체 274/274 통과

## 61차 증분 완료 상태 (2026-03-29)

핫바 스킬 슬롯 마우스 클릭 버튼 추가:
- `HOTBAR_SLOT_COUNT := 6` 상수 추가
- `_hotbar_slot_button_bar: HBoxContainer`, `_hotbar_slot_button_nodes: Array[Button]` 변수 추가
- `_build_ui()`에서 `_slot_button_bar` 아래에 `HBoxContainer` 핫바 슬롯 바 추가. 슬롯 수(6)만큼 Button 생성, `text = str(i+1)`, `pressed.connect(_on_hotbar_slot_button_pressed.bind(i))` 연결. 초기값 `visible = false`
- `_refresh_hotbar_slot_buttons()`: 핫바 탭 활성 시 표시 + 선택 슬롯 `flat=false`, 나머지 `flat=true`. 타 탭 시 숨김. `_refresh()`에서 호출
- `_on_hotbar_slot_button_pressed(slot_index)`: `selected_slot` 업데이트 → `_sync_library_selection_to_slot()` → `_refresh()`
- `debug_click_hotbar_slot(slot_index)`: 테스트용 클릭 시뮬레이션 메서드
- GUT 4개 추가: 비핫바 탭에서 숨김, 핫바 탭에서 표시+노드 수, 클릭 시 슬롯 변경, 활성/비활성 flat 상태
- 전체 270/270 통과

## 59차 증분 완료 상태 (2026-03-29)

관리자 메뉴 탭 마우스 클릭 버튼 추가:
- `_tab_button_nodes: Dictionary` 변수 추가
- `_build_ui()`에서 title 아래에 `HBoxContainer` 탭 바 추가. `ADMIN_TABS` 순서대로 각 탭마다 `Button` 노드 생성, `pressed.connect(_on_tab_button_pressed.bind(tab_id))` 연결
- `_on_tab_button_pressed(tab_id)`: `_set_tab(tab_id)` → `_refresh()` 호출
- `_refresh_tab_buttons()`: 활성 탭은 `flat = false`, 비활성 탭은 `flat = true`로 시각 상태 동기화. `_refresh()` 시작 시 호출
- `debug_click_tab(tab_id)`: 테스트용 클릭 시뮬레이션 메서드
- GUT 3개 추가: 모든 탭에 버튼 존재 확인, 클릭 시 탭 전환 확인, 활성/비활성 `flat` 상태 확인
- 전체 262/262 통과

## 57차 증분 완료 상태 (2026-03-28)

side_by_side 우측 컬럼 오버플로우 보호:
- `_get_equipment_panel_column_width()`가 이제 좌/우 패널 줄 길이를 함께 보고 폭을 계산하되 `EQUIPMENT_PANEL_COLUMN_MAX_WIDTH`로 clamp 하므로, 한쪽 긴 줄 때문에 컬럼 폭이 끝없이 넓어지지 않는다.
- `_clamp_equipment_panel_column_text()`를 추가해 side_by_side 렌더 시 좌/우 컬럼 모두 `column_width`를 넘는 텍스트를 `~`로 잘라낸다.
- `_build_equipment_side_by_side_row()`는 이제 우측 컬럼도 같은 폭 규칙으로 잘라내므로, `Owned Detail` 같은 긴 줄이 후보 패널 정렬을 밀어내지 않는다.
- 새 테스트 1개 추가:
  - 긴 우측 컬럼 문자열이 실제 side_by_side helper에서 clamp 되고 원문 전체가 그대로 새어 나오지 않는지 확인
- 이 단계로 다음 Claude 작업은 실제 2패널 기본 출력에서 `fresh` 강조나 비교 정보 강조를 더 강하게 다듬되, 기본 컬럼 안정성은 이미 확보된 상태에서 시작할 수 있다.
