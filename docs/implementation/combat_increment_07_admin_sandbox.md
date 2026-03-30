# 전투 7차 작업 체크리스트 - 관리자 샌드박스

상태: 완료
최종 갱신: 2026-03-29  
섹션: 구현 기준

## 목표

이 문서는 [전투 우선 구현 계획](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/combat_first_build_plan.md)의 관리자 샌드박스 구간을 Claude가 바로 이어받을 수 있도록 정리한 체크리스트다.

핵심 목표는 `전투 실험에 필요한 조작을 게임 안에서 즉시 재현할 수 있게 하는 것`이다.

추가로, 관리자 UI는 현재의 키보드 탐색 구조를 유지하면서도 메이플스토리처럼 마우스로 탭, 슬롯, 목록을 직접 클릭 가능한 형태를 목표로 한다. 이 요구사항은 이번 문서 갱신에서 새로 명시되었고 아직 구현 완료 상태가 아니다.
또한 관리자 UI 역시 텍스트 본문 출력이 아니라 그래픽 탭, 버튼, 슬롯, 아이콘, 패널 프레임을 가진 GUI가 최종 목표다.

## 이번 증분의 에셋 기준

- 관리자 버튼과 탭은 [Buttons.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Buttons.png) 를 우선 사용한다.
- 장비창/장비 패널은 [Equipment.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Equipment.png) 를 우선 사용한다.
- 인벤토리/보유 장비 패널은 [Inventory.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Inventory.png) 를 우선 사용한다.
- 설정/보조 패널은 [Settings.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Settings.png) 를 우선 사용한다.
- 이 에셋 기준은 이번 문서 갱신에서 추가된 것이며 아직 완성형 GUI로 구현되지 않았다.

## 현재 구현 상태

### 완료

- [admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd) 추가
- `Escape`로 관리자 메뉴 열기/닫기
- 경량 4탭 구조 `핫바 / 자원 / 장비 / 소환` 추가
- 슬롯 선택
- 슬롯 스킬 교체
- 슬롯 비우기
- 프리셋 적용
- 무한 HP 토글
- 쿨타임 리셋 신호
- 적 소환 신호
- 즉시 회복 신호
- 테스트용 더미 적 소환
- HUD 관리자 상태 표시
- HUD 관리자 상태를 `Resources / Combat / Gear` 영역으로 구조화
- 장비 프리셋 적용
- 개별 장비 슬롯 교체
- 장비 지급 후보 순환, 인벤토리 등록, 인벤토리 장착의 최소 루프 추가
- 무한 MP 토글
- 쿨타임 무시 토글
- 버프 슬롯 제한 무시 토글
- 선택 핫바 스킬 레벨 직접 증감
- 선택 핫바 스킬의 `Lv / XP / Circle` 상세 표시
- 현재 선택 스킬 기준의 `Skill Library` 미리보기 표시
- `Skill Library` 포커스로 현재 슬롯에 선택 스킬 장착 가능
- `Library Focus` 상태에서는 라이브러리 선택 스킬 자체를 레벨 조정 가능
- 현재 탭 상태를 HUD와 같은 분류로 추적 가능
- 탭별 렌더링이 함수 단위로 분리되어 다음 Claude 작업에서 확장하기 쉬운 구조로 정리됨
- MP 수치 UI 반영
- 설치/토글 실험용 핫바 프리셋 추가
- `Ashen Rite` 실험용 핫바 프리셋 추가
- 상위 토글형 실험용 `ApexToggles` 프리셋 추가
- 상위 토글형이 마나 고갈 시 자동 해제되는 런타임 검증 가능
- 상위 토글형의 유지 마나 소모가 스킬 데이터별로 다르게 적용됨
- `Glacial Dominion` 둔화와 `Tempest Crown` 관통 증가를 샌드박스에서 바로 검증 가능

### 현재 연결 완료

- [main.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/main/main.gd)에서 적 소환 연결
- [main.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/main/main.gd)에서 관리자 보스 소환 시 `Phantom Camera` 이벤트 포커스 연결
- [player.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/player.gd)에서 쿨타임 리셋 연결
- [game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)에서 무한 HP, 무한 MP, 쿨타임 무시 상태 관리
- [spell_manager.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_manager.gd)에서 마나 부족, 관리자 쿨타임 무시 반영

### 완료 추가 (2026-03-28)

- **버프 강제 발동 탭**: `ADMIN_TABS`에 `"buffs"` 추가 (5번째 탭)
  - `buff_catalog`: `GameDatabase.get_all_skills()`에서 `skill_type == "buff"` 필터링
  - `selected_buff_catalog_index`: 탭 내 선택 커서
  - `_get_buff_tab_lines()`: 버프 목록(페이지 8개) + 활성 버프 목록 + combo summary 표시
  - `_force_activate_selected_buff()`: admin_ignore_buff_slot_limit + admin_ignore_cooldowns 임시 활성화 후 시전 (ritual_recast_lock는 여전히 차단)
  - `_clear_active_buffs()`: 전체 active_buffs 클리어
  - 입력: Up/Down 선택 이동, E(interact) 강제 활성화, Q(buff_guard) 전체 클리어
  - debug 메서드 3개: `debug_cycle_buff_selection`, `debug_force_activate_selected_buff`, `debug_clear_active_buffs`
  - GUT 3개 추가: 탭 접근, 강제 활성화, 전체 클리어

### 완료 추가 (2026-03-28) — Resources 탭 circle/HP/MP 현황

- `admin_menu.gd _get_resource_tab_lines()`: Circle/Score/Buff Slots 현황 줄 + HP/MP 현재 수치 줄 추가
- 이전: HP Lock / MP Lock / Cooldown Lock / Buff Limit Lock + 회복 안내만 표시
- 이후: `Circle: 4  Score: 1.0  Buff Slots: 2` + `HP: 100/100  MP: 180/180` 줄이 선두에 추가됨
- GUT 3개 추가: Circle/Buff Slots 표시, HP/MP 값 표시, 버프슬롯 수치 GameState 일치 확인
- 전체 200/200 통과

### 완료 추가 (2026-03-28) — plant_verdant_overflow BUFF_KEY_LOADOUT 추가

- `game_state.gd BUFF_KEY_LOADOUT`에 `plant_verdant_overflow` 추가
- Funeral Bloom 조합 (`dark_grave_pact` + `plant_verdant_overflow`)을 쿨타임 요약에서 추적 가능
- 어드민 버프 탭에서 `plant_verdant_overflow`를 강제 발동하면 Funeral Bloom 조합이 즉시 발동 가능

### 아직 남은 작업

- 아이템/장비 지급 UI 확장
- 경량 탭 구조를 인벤토리형 관리자 UI로 확장
- 관리자 상태를 UI 탭 구조에 맞게 더 세분화
- 아이템 드롭/획득 시뮬레이션
- 탭, 버튼, 후보/보유 패널, 목록 항목에 대한 마우스 클릭 경로 추가
- 키보드 포커스와 마우스 선택 상태의 동기화 규칙 구현
- 메이플스토리식 장비/인벤토리 조작감에 맞는 클릭, 더블클릭, hover 정보 노출 구현
- 텍스트형 탭/목록 출력을 그래픽 탭/버튼/슬롯 GUI로 전환
- 스킬/버프/장비/admin tab 전부를 아이콘 기반 GUI로 정리
- 관리자 장비창과 인벤토리를 실제 슬롯 UI로 재구성

## 플레이 경험 목표

- 전투 실험을 위해 에디터를 다시 열 필요가 없어야 한다.
- 적, 스킬, 버프, 슬롯, 쿨타임, HP를 즉시 바꿀 수 있어야 한다.
- 설치/토글/버프 조합 같은 실험이 메뉴 몇 번 조작으로 바로 가능해야 한다.
- 같은 실험을 단축키뿐 아니라 마우스 클릭만으로도 수행할 수 있어야 한다.
- 탭, 패널, 슬롯 조작 감각은 메이플스토리식 UI처럼 직관적이어야 한다.
- 관리자 메뉴도 숫자/텍스트 나열이 아니라 그래픽 GUI처럼 보여야 한다.

## Claude 바로 다음 작업

1. `Buttons / Equipment / Inventory / Settings` PNG를 실제 관리자 GUI 씬에 먼저 붙인다.
2. 현재 경량 탭 구조를 유지하되, 본문 텍스트를 그래픽 패널/버튼/슬롯 위젯으로 치환한다.
3. 아이템 지급과 장착을 그래픽 인벤토리 패널 흐름으로 옮긴다.
4. 탭/목록/슬롯에 대한 마우스 클릭 경로를 유지하면서도 시각적 GUI 상태를 동기화한다.
5. 선택 스킬 레벨 편집과 버프 발동도 텍스트 본문이 아닌 GUI 컨트롤 안으로 옮긴다.
6. 텍스트 본문 출력은 디버그 fallback 으로만 남기고 플레이어 기준 출력에서는 후순위로 내린다.

## 새로 확정된 기준 (2026-03-29, 아직 미구현)

- 관리자 탭 전환은 키보드뿐 아니라 마우스 클릭으로도 가능해야 한다.
- 장비 후보/보유 목록은 마우스로 항목 선택, hover 상세 확인, 더블클릭 장착 또는 동등한 빠른 장착 경로를 제공해야 한다.
- 버튼성 액션은 단축키 힌트를 유지하되, 시각적으로 클릭 가능한 컨트롤로도 노출해야 한다.
- 현재의 텍스트 중심 관리자 메뉴는 디버그/중간 단계 구현으로 취급하며, 최종 목표는 그래픽 GUI다.
- 스킬창, 버프창, 장비창, admin tab 모두 그래픽 패널과 아이콘이 보이는 형태여야 한다.
- 위 그래픽 관리자 GUI는 지정된 `Buttons / Equipment / Inventory / Settings` PNG 사용을 기본 전제로 구현한다.
- 이 요구사항은 현재 구현 완료 목록에 포함되지 않으며, 후속 구현 작업에서 반드시 처리해야 한다.

## 진행 메모

- 현재는 한 화면형 관리자 메뉴다.
- 현재는 한 화면형 관리자 메뉴지만, `핫바 / 자원 / 장비 / 소환` 4탭으로 내용을 나눈 경량 구조가 이미 적용되어 있다.
- 현재 탭 콘텐츠는 `_get_hotbar_tab_lines`, `_get_resource_tab_lines`, `_get_equipment_tab_lines`, `_get_spawn_tab_lines` 식으로 분리되어 있어 Claude가 각 탭을 독립적으로 확장하기 좋다.
- `장비` 탭에서는 이제 `T`로 지급 후보를 순환하고 `Q`로 후보를 인벤토리에 지급한 뒤 `E`로 인벤토리 장착 또는 해제를 테스트할 수 있다.
- `장비` 탭은 현재 선택 슬롯 기준으로 `보유 장비 요약`과 전체 인벤토리 요약을 같이 보여주므로, Claude는 다음 단계에서 이 정보를 목록형 UI로 확장하면 된다.
- `장비` 탭은 현재 선택 슬롯 기준으로 `보유 장비 선택 인덱스`를 가지며, `N/R`로 선택 장비를 바꾸고 `E`로 그 장비를 바로 장착할 수 있다.
- `장비` 탭은 현재 선택 슬롯 기준으로 최대 5줄 `Owned List` 미리보기를 렌더하고, 각 줄에 장비명과 `희귀도 / 슬롯`, 선택 장비의 `설명 / 태그` 메타데이터, 정렬 모드 `rarity -> name` / `name`, 필터 모드 `all / tempo / ritual / burst / defense`, 상태 헤더 `Owned View`, 페이지 표시 `Owned Page`, 현재 범위 표시 `Items x-y/n`, 장비 탭 전용 페이지 이동 입력 `Y/H`까지 표시하므로, Claude는 다음 단계에서 이 리스트를 스크롤형 또는 정렬형 목록으로 확장하면 된다.
- `장비` 탭은 이제 `Equipment Focus  candidate / owned` 상태를 가지며, `T`로 포커스를 전환하고 `N/R`로 현재 포커스 대상을 순환한다. 현재는 `candidate` 포커스에서 `E`가 지급, `owned` 포커스에서 `E`가 장착/해제를 담당하므로, Claude는 이 구조를 실제 커서형 인벤토리 UI의 중간 단계로 사용하면 된다.
- `장비` 탭은 현재 `Candidate Status / Owned Status` 상태 줄과 탭별 footer 안내를 따로 가지므로, Claude는 이 텍스트 구조를 그대로 `좌측 후보 패널 / 우측 보유 패널`의 실제 UI 헤더로 승격하면 된다.
- `장비` 탭의 `candidate` 패널도 이제 `Candidate Selection`과 `Candidate List` 미리보기를 가지므로, Claude는 다음 단계에서 `candidate / owned` 양쪽을 대칭적인 목록 패널로 확장할 수 있다.
- `candidate` 패널은 이제 `Candidate Window  Items x-y/n`까지 표시하므로, Claude는 다음 단계에서 `candidate` 쪽에도 `owned`와 유사한 윈도우/페이지 개념을 붙이기 쉬운 상태다.
- `candidate` 패널은 이제 포커스된 상태에서 `Y/H`로 창 단위 이동도 가능하므로, Claude는 다음 단계에서 `candidate / owned` 양쪽을 거의 같은 탐색 규칙으로 묶을 수 있다.
- `candidate` 패널도 이제 `Candidate Detail`로 설명/태그 메타데이터를 표시하므로, Claude는 다음 단계에서 `candidate / owned` 양쪽을 더 쉽게 공통 패널 구조로 정리할 수 있다.
- `candidate` 패널도 이제 `Candidate Compare`로 현재 후보와 현재 장착 장비의 핵심 수치 차이를 바로 보여주므로, Claude는 다음 단계에서 비교 정보를 패널 헤더 또는 중간 비교 영역으로 쉽게 승격할 수 있다.
- 선택 슬롯 구간에는 이제 `Compare Header  Equipped:...  Candidate:...`가 함께 표시되므로, Claude는 기준 장비와 후보 장비를 비교하는 상단 묶음을 더 쉽게 공통 패널 구조로 올릴 수 있다.
- 선택 슬롯 구간의 비교 정보는 이제 공통 helper로 묶여 있으므로, Claude는 이 섹션을 `candidate / owned` 양쪽에서 재사용하는 방향으로 더 쉽게 확장할 수 있다.
- `candidate / owned` 패널도 이제 각각 전용 helper를 통해 같은 조립 규칙으로 렌더되므로, Claude는 다음 단계에서 이 helper들을 더 상위의 공통 패널 helper로 끌어올리는 작업에 바로 들어갈 수 있다.
- `candidate / owned` 패널은 이제 상위 wrapper helper를 통해 `헤더 -> 상태 -> 본문 -> 포커스 힌트` 순서로 조립되므로, Claude는 다음 단계에서 본문 조각까지 공통 패널 규칙으로 끌어올리는 데 집중하면 된다.
- `candidate / owned` 패널 본문도 이제 공통 body helper를 통해 `primary -> detail -> view -> section -> navigation -> list` 순서로 조립되므로, Claude는 다음 단계에서 패널별 차이를 body source 데이터 쪽으로만 더 좁힐 수 있다.
- `candidate` 패널에는 이제 `Candidate View` 줄이 추가되어 `owned`의 `Owned View`와 더 비슷한 본문 구조를 갖게 되었으므로, Claude는 다음 단계에서 양쪽 body source를 더 쉽게 대칭화할 수 있다.
- 본문 조립 전 단계로 `body source` 구조도 공통화되었으므로, Claude는 다음 단계에서 candidate/owned 차이를 source 값 수준으로만 줄이는 작업에 바로 들어갈 수 있다.
- `owned` 패널도 이제 `_get_owned_primary_line()`, `_get_owned_view_line()`, `_get_owned_selection_line()`, `_get_owned_navigation_line()` helper를 통해 body source를 채우므로, candidate/owned 양쪽이 같은 `helper -> source -> builder` 흐름을 가진다.
- `candidate / owned` 양쪽 모두 이제 패널별 body source 생성 helper를 따로 가진 뒤 공통 body builder로 넘어가므로, Claude는 다음 단계에서 panel source helper 내부의 의미 차이만 줄이는 식으로 더 안전하게 확장할 수 있다.
- 후보 지급 직후에는 이제 `owned` 포커스로 자동 전환되고, 필터가 `all`로 맞춰지며, 방금 지급한 장비가 선택 상태로 잡히므로 Claude는 다음 단계에서 `지급 -> 비교 -> 장착` 3단계를 하나의 명확한 패널 흐름으로 다듬기 쉬워졌다.
- 방금 지급한 장비가 선택된 직후에는 이제 `Owned Status  Action:equip-now  State:fresh`와 footer의 `E equip new item` 안내가 함께 표시되므로, Claude는 다음 단계에서 이 신호를 2패널 UI의 우측 패널 액션 강조로 자연스럽게 승격할 수 있다.
- `fresh` 장착 유도 상태는 이제 owned 목록 수동 순환, 페이지 이동, 정렬/필터 변경, 슬롯 이동, 포커스 전환 같은 탐색 행동이 들어오면 즉시 해제되므로, Claude는 다음 단계에서 이 상태를 일시적 CTA로 취급하고 더 강한 패널 강조로 올리기 쉽다.
- `Candidate View`와 `Owned View`는 이제 둘 다 `Browse:` 요약을 포함하므로, Claude는 다음 단계에서 후보/보유 패널의 탐색 상태를 더 공통된 시각 언어로 다듬기 쉬워졌다.
- `Candidate Window`와 `Owned Page`도 이제 각각 `Candidate Nav`, `Owned Nav`로 표시되므로, Claude는 다음 단계에서 `selection / navigation / browse` 층을 더 일관된 패널 용어로 다듬기 쉬워졌다.
- `Candidate Selection`도 이제 현재 후보 이름과 `[index/total]`을 함께 보여주므로, `Owned Selection`과 거의 같은 문법으로 읽힌다. Claude는 다음 단계에서 두 패널의 `Selection` 줄을 같은 의미 슬롯으로 다루기 쉬워졌다.
- `Candidate Selection`과 `Owned Selection`은 이제 같은 helper로 조립되므로, Claude는 다음 단계에서 `Selection / Nav / Browse`를 공통 패널 슬롯으로 다루는 데 집중할 수 있다.
- `Candidate View`와 `Owned View`도 이제 같은 helper로 조립되므로, Claude는 다음 단계에서 `Selection / Nav / Browse` 3줄을 묶은 공통 패널 body 슬롯을 더 쉽게 만들 수 있다.
- `Candidate Nav`와 `Owned Nav`도 이제 같은 helper로 조립되므로, Claude는 다음 단계에서 `Selection / View / Nav`를 실제 공통 패널 body 묶음으로 승격하는 데 집중할 수 있다.
- `Selection / View / Nav`는 이제 `_build_equipment_navigation_section_lines()`로 하나의 탐색 묶음처럼 조립되므로, Claude는 다음 단계에서 이 묶음을 실제 좌우 패널 body 슬롯으로 직접 승격하면 된다.
- `Selection / View / Nav`는 이제 `_build_equipment_navigation_section_source()`까지 통해 body source 단계에서도 하나의 block으로 다뤄지므로, Claude는 다음 단계에서 줄 단위가 아니라 section 단위로 좌우 패널 배치를 설계하면 된다.
- `Detail + NavigationSection + List`도 이제 `_build_equipment_panel_content_section_source()`를 통해 하나의 `content_section` block으로 다뤄지므로, Claude는 다음 단계에서 panel body를 `primary / content` 두 큰 슬롯 기준으로 좌우 배치하면 된다.
- `content_section`은 이제 `_build_equipment_panel_content_section_lines()`를 통해 실제 렌더 helper도 가지므로, Claude는 다음 단계에서 source와 render 양쪽 모두를 `primary / content` 두 슬롯 기준으로 2패널 배치 helper에 연결하면 된다.
- 장비 탭 상단에는 이제 `Panel Summary`, `Panel Flow` 두 줄이 추가되어 후보/보유 패널의 현재 대상, 액션, 탐색 범위를 stacked 본문에 들어가기 전 한 번에 확인할 수 있다. Claude는 다음 단계에서 이 상단 요약을 좌우 2패널 헤더 또는 비교 헤더로 자연스럽게 승격하면 된다.
- `Panel Summary / Panel Flow`도 이제 source/helper 구조로 정리되었으므로, Claude는 다음 단계에서 상단 bridge 영역을 그대로 좌우 2패널 헤더 입력으로 연결하면 된다.
- 상단 비교 영역은 이제 `overview section` helper로 묶였으므로, Claude는 다음 단계에서 상단은 `overview`, 하단은 `primary / content`로 나눠 실제 좌우 2패널 텍스트 배치 규칙을 설계하면 된다.
- `overview section`도 이제 source/helper 구조를 가지므로, Claude는 다음 단계에서 상단 전체를 하나의 header block으로 취급하고 하단 panel bodies와 분리해 2패널 배치를 설계하면 된다.
- 장비 탭 최상위도 이제 `_build_equipment_tab_layout_lines()`로 `overview -> candidate -> owned` 조립 규칙을 가진다. Claude는 다음 단계에서 이 helper 내부를 실제 좌우 2패널 텍스트 배치 규칙으로 바꾸면 된다.
- 장비 탭 최상위는 현재 `_build_equipment_tab_layout_lines()`로 `overview -> focus -> candidate -> owned` 순서를 보장하므로, Claude는 다음 단계에서 이 helper 내부를 `overview / focus / left panel / right panel` 배치 규칙으로 바꾸면 된다.
- 장비 탭 최상위도 이제 `_build_equipment_tab_layout_source()`와 `_build_equipment_tab_layout_lines_from_source()`를 가지므로, Claude는 다음 단계에서 source 구조는 유지하고 렌더 helper 내부만 2패널 배치 규칙으로 교체하면 된다.
- 장비 탭 최상위에는 이제 `Panel Columns  Left:Candidate  Right:Owned`, `Panel Mode  stacked bridge (2-panel ready)` bridge 줄도 들어가므로, Claude는 다음 단계에서 이 두 줄이 들어가는 위치를 실제 좌우 텍스트 패널 렌더로 바꾸면 된다.
- 장비 탭 최상위는 이제 `candidate_lines`, `owned_lines`를 각각 `Left Panel Slot  Candidate`, `Right Panel Slot  Owned` wrapper 아래에 두므로, Claude는 다음 단계에서 이 slot helper를 실제 좌우 column renderer로 바꾸면 된다.
- 장비 탭 최상위는 이제 `panel_slot_section` source/helper도 따로 가지므로, Claude는 다음 단계에서 최상위 layout 전체가 아니라 이 slot section renderer만 실제 좌우 텍스트 배치 규칙으로 교체하면 된다.
- `panel_slot_section`은 이제 `layout_mode: stacked_fallback`도 가지므로, Claude는 다음 단계에서 이 값을 `side_by_side`로 분기시키는 renderer만 추가하면 된다.
- `panel_slot_section` renderer는 이제 실제 `side_by_side` 분기와 전용 helper 시그니처도 가진다. Claude는 다음 단계에서 helper 본문만 채워 좌우 텍스트 배치 규칙을 구현하면 된다.
- `panel_slot_section`의 `side_by_side` helper는 이제 실제 두 컬럼 문자열 formatter도 가지므로, Claude는 다음 단계에서 `layout_mode`를 `side_by_side`로 바꾸는 조건과 실제 장비 탭 적용만 처리하면 된다.
- `panel_slot_section` source는 이제 `column_width`, `column_separator`도 가지므로, Claude는 다음 단계에서 renderer 폭과 구분자를 source 단계에서 바로 조정할 수 있다.
- `layout_mode` 결정도 이제 `_get_equipment_panel_slot_layout_mode()` 한 곳으로 모였으므로, Claude는 다음 단계에서 이 helper 하나만 바꿔 bridge 문구와 slot section renderer 전환을 함께 움직일 수 있다.
- debug 경로에서는 이제 실제 `side_by_side` 모드 전환도 가능하므로, Claude는 다음 단계에서 이 전환을 안전한 실제 조건으로 바꾸고 기본 출력에 적용하는 데 집중하면 된다.
- 장비 탭 기본 출력은 이제 실제 `side_by_side` slot section renderer를 사용하므로, Claude는 다음 단계에서 “전환 구현”보다 “현재 2패널 텍스트 출력의 가독성 보강”에 집중하면 된다.
- side_by_side renderer는 이제 좌/우 컬럼 모두 긴 줄을 `~`로 clamp 하고, 컬럼 폭도 최대값으로 제한하므로 `Owned Detail` 같은 긴 문자열이 다른 패널의 정렬을 무너뜨리지 않는다. Claude는 다음 단계에서 정렬 안정성보다 `fresh` 상태 강조나 비교 정보 배치 같은 가독성 디테일에 집중하면 된다.
- `candidate` 목록은 이제 이미 인벤토리에 있는 장비에 `[Owned]`를 붙여 표시하므로, Claude는 다음 단계에서 후보 목록과 보유 목록의 관계를 더 명확하게 연결할 수 있다.
- 관리자 탭 요약은 이제 `Focus / Slot / Nav / Target`까지 포함하므로, Claude는 HUD와 관리자 메뉴 사이의 상태 중복 없이 다음 UI 단계를 설계할 수 있다.
- 선택 슬롯에는 이제 `Slot Stats` 한 줄이 표시되므로, Claude는 다음 단계에서 후보/보유 비교 UI를 설계할 때 현재 장착 기준 수치를 그대로 활용할 수 있다.
- `무한 HP`, `무한 MP`, `쿨타임 무시`, `버프 슬롯 제한 무시`, `선택 스킬 레벨 편집`, `개별 장비 교체`까지는 현재 빌드에서 바로 실험 가능하다.
- 현재는 선택 핫바 스킬에 대해 `Lv / XP / Circle`, 주변 `Skill Library` 미리보기, 라이브러리 포커스를 통한 슬롯 장착과 선택 스킬 튜닝까지 가능하며, 전체 스킬 목록 전용 탭은 아직 없다.
- 핫바 프리셋은 이제 `Default`, `Ritual`, `Overclock`, `DeployLab`, `AshenRite`, `ApexToggles`까지 순환 가능하다.
- 탭형 UI의 첫 단계는 완료되었고, 인벤토리형 장비 지급과 전체 스킬 목록 탭은 범위가 커지므로 다음 Claude 작업에서 단계적으로 쪼개 구현하는 편이 안전하다.

## 구현 대상 파일

- [admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
- [main.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/main/main.gd)
- [game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)
- [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)

## 테스트 체크포인트

- 관리자 메뉴 토글
- 프리셋 적용
- 슬롯 교체
- 무한 HP 토글
- 무한 MP 토글
- 쿨타임 무시 토글
- 버프 슬롯 제한 무시 토글
- 선택 스킬 레벨 증감
- 탭 전환
- 적 소환 신호
- 쿨타임 리셋 신호
- 개별 장비 슬롯 교체

## 다음 증분

관리자 샌드박스가 더 다듬어지면, 다음은 [전투 3차 작업 체크리스트 - 버프 중심 액션 루프](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/combat_increment_03_buff_action_loop.md) 기준으로 버프 조합 체감과 관리자 프리셋을 연결하는 단계가 자연스럽다.
