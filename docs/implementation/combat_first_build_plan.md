# 전투 우선 구현 계획

상태: 사용 중  
최종 갱신: 2026-03-29  
섹션: 구현 기준

## 목표

이 문서는 `스토리`, `NPC`, `배경 연출`, `퀘스트`를 모두 제외한 상태에서 전투 중심 2D 횡스크롤 액션 RPG를 먼저 완성하기 위한 기준 구현 계획입니다.

이번 단계의 목표는 아래 두 가지입니다.

- 플레이어, 몬스터, 스킬, 전투 UI, 성장 수치, 장비, 입력 시스템만으로 충분히 반복 플레이 가능한 전투 샌드박스를 만든다.
- 이후 배경, 스토리, NPC, 미궁 구조를 얹을 수 있도록 전투 관련 런타임 구조를 먼저 고정한다.

이 문서는 [CLAUDE.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/CLAUDE.md)의 필수 규칙을 전제로 작성한다.

## 플레이 경험 목표

- 키보드만으로 빠르고 시원한 마법 액션을 굴릴 수 있어야 한다.
- 전투 HUD와 메뉴형 UI는 키보드만이 아니라 마우스로도 직접 상호작용할 수 있어야 한다.
- UI 상호작용 감각은 메이플스토리에 최대한 가깝게 맞추며, `단축키 조작`과 `마우스 클릭 조작`이 같은 기능에 대해 함께 성립해야 한다.
- 스킬을 눌렀을 때 즉시 반응하고, 연계와 캔슬, 버프 폭발 구간에서 뽕맛이 느껴져야 한다.
- 관리자 모드에서 몬스터, 스킬, 장비, 자원, UI 상태를 즉시 조작하며 전투를 반복 테스트할 수 있어야 한다.
- 밸런스 조정과 시스템 검증이 스토리 없이도 가능해야 한다.

## 구현 원칙

- 카메라는 반드시 `Phantom Camera`를 사용한다.
- 플레이어와 적 상태 흐름은 반드시 `Godot State Charts`를 사용한다.
- 새 전투 동작에는 반드시 `GUT` 테스트를 추가한다.
- 새로운 시스템은 `문서 규칙 -> 데이터 구조 -> 로더 -> 런타임 연결 -> UI 반영 -> 테스트` 순서로 붙인다.
- `asset_sample/`에 들어온 에셋은 `임시 참고자료`가 아니라 실제 빌드에 붙일 후보로 취급하며, GUI/캐릭터 체감에 직접 연결되는 에셋은 늦추지 않는다.
- UI는 `키보드 전용`으로 끝내지 않고, 동일 기능에 대한 `키보드 단축키 + 마우스 클릭` 경로를 함께 설계한다.
- UI 포커스, hover, 선택, 드래그 가능 영역, 더블클릭 장착/사용 같은 상호작용 규칙은 메이플스토리식 UX를 기준선으로 삼는다.
- 모든 검증은 헤드리스 환경에서 통과해야 한다.
- 스토리성 오브젝트와 임시 연출은 이번 범위에 넣지 않는다.

## 이번 범위

### 포함

- 플레이어 조작
- 플레이어 전투 상태
- 마나, 쿨타임, 피격, 사망
- 스킬 15종 사용 구조
- 스킬 레벨과 마스터리 반영
- 버프 중첩, 버프 조합, 필살 버프 리스크
- 장비 장착 및 전투 능력치 반영
- 몬스터 AI 최소 세트
- 전투 전용 HUD
- 데미지 숫자, 피격 반응, 카메라 반응
- 관리자 샌드박스 맵
- 관리자 메뉴
- 몬스터 소환, 아이템 지급, 스킬 설정, 무한 자원 토글

### 제외

- 스토리 이벤트
- NPC
- 퀘스트
- 본편 맵 구조
- 컷신
- 대사 시스템
- 저장 슬롯 UI
- 상점, 제작, 채집

## 전투 샌드박스 빌드 개요

이번 빌드는 `admin_map.tscn` 하나를 중심으로 움직인다.

- 평지 전투 구간
- 공중 발판 구간
- 낙하 테스트 구간
- 로프 또는 사다리 테스트 구간
- 보스 테스트 구간
- 관리자 메뉴 호출 구간

스토리 대신 `전투 상황을 빠르게 재현하는 테스트 동선`이 핵심이다.

## 진행 현황

| 증분 | 상태 | 메모 |
| --- | --- | --- |
| 1. 플레이어 컨트롤러 고정 | 완료 | 더블점프, 대시, 피격/사망 입력 잠금, `State Charts` 연결, 로프 상호작용(grab/climb/exit) 모두 구현 완료. 259개 GUT 통과 |
| 2. 스킬 런타임 구조 정리 | 진행 중 | `spell_manager` 추가, 6슬롯 1차 구조, 버프 3종 핫바 통합, 설치형/토글형 런타임, 마나 자원, `무한 MP/쿨타임 무시`, `Glacial Dominion` 둔화, `Tempest Crown` 관통, `Soul Dominion` 리스크(MP 재생 차단, 피해 배수, 후유증, HUD) 완료. 7서클 스킬 구현은 별도 계획 중 |
| 3. 버프 중심 액션 루프 구축 | 진행 중 | Prismatic Guard(배리어), Time Collapse(할인 시전 3회), Ashen Rite(스택·폭발·종료 페널티: 마나 소진·방어 약화 10초·재시전 봉인 6초), Overclock Circuit(번개 연계·활성화 메시지), Funeral Bloom(배치킬 감지·ICD·corruption_burst 폭발) 모두 런타임 구현 완료. notify_deploy_kill() 연결 완료(main.gd, player.gd). 관리자 버프 강제 발동 탭은 남아 있음 |
| 4. 몬스터 전투 세트 구축 | 완료 | `enemy_base.gd`에 10종 구현 완료. `enemies.json` 분리·JSON 기반 수치 로드, `has_super_armor_attack` 플래그(JSON `super_armor_tags` 연결), leaper 착지 예고 마커 완료. admin spawn 탭 자동 표시. `EnemyBase.tscn` 씬 파일 생성 및 `main.gd`가 씬 기반 인스턴스화로 전환 완료 |
| 5. 장비 시스템 최소 버전 | 진행 중 | 장비 데이터, 프리셋, 런타임 반영, HUD/관리자 연결 완료. 지급→인벤토리→장착/해제 루프, 정렬/필터/페이지, `Candidate Detail/Selection/Nav/List` 구조, 비교 섹션, 후보 패널 페이지 구조 전환(EQUIPMENT_PAGE_SIZE 통일) 완료 |
| 6. 전투 UI 구축 | 진행 중 | HP/MP 그래픽 바(빨강/파랑) + 수치 레이블, 핫바 스킨(`Buttons.png`/`Action_panel.png`), 마우스 클릭 핫바, 부유 데미지 숫자(`DamageLabel`), 플레이어 스프라이트(male_hero, scale=1.4), 버섯 적 스프라이트(Mushroom), 카메라 흔들림, 히트스탑(0.06s). 313개 GUT 통과 (2026-03-30) |
| 7. 관리자 모드 구축 | 완료 | 5탭 구조(hotbar/resources/equipment/spawn/buffs), 장비 탭 2패널 side-by-side 완성, buffs 탭 조합 요건 `[v]`/`[ ]` 표시. 탭/장비 슬롯/핫바 슬롯/owned 목록 아이템/candidate 목록 아이템/소환 타입/자원 토글/버프 항목/프리셋/스킬 라이브러리 항목/장착-해제 액션 모두 마우스 클릭 버튼 추가(2026-03-29). 306개 GUT 통과 |
| 9. Soul Dominion 리스크 | 완료 | MP 재생 차단, 피해 배수 증가, 종료 후 후유증, HUD 표시 모두 구현 완료 |

## 우선순위 재정렬 (2026-03-29)

이 프로젝트는 지금부터 `전투 코어 검증 중심` 우선순위에서 `에셋 적용 + 그래픽 GUI 전환` 우선순위로 옮긴다.

### 재정렬 이유

- 플레이어 조작, 기본 전투 루프, 관리자 샌드박스, 최소 장비/스킬 구조는 이미 충분히 검증됐다.
- 현재 병목은 전투 수식이 아니라 `게임처럼 보이는 출력`, `에셋 적용`, `그래픽 GUI 완성도`다.
- 따라서 다음 구현은 텍스트 보강보다 `실제 스프라이트`, `실제 UI 스킨`, `실제 슬롯 GUI`를 우선한다.

### 다음 구현 우선순위

1. 플레이어 스프라이트 적용
2. 전투 HUD 그래픽 GUI 전환
3. 관리자 메뉴 그래픽 GUI 전환
4. 장비/인벤토리 그래픽 GUI 전환
5. 이후 세부 전투 연출과 적/배경 에셋 확장

### 에셋 적용 기준

- 플레이어 기본 비주얼은 [male_hero-idle.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/Character/male_hero_free/individual_sheets/male_hero-idle.png) 및 동일 폴더의 `male_hero-*.png` 시트들을 사용한다.
- UI 기본 스킨은 아래 PNG를 우선 사용한다.
- [Equipment.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Equipment.png)
- [Buttons.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Buttons.png)
- [Action_panel.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Action_panel.png)
- [Inventory.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Inventory.png)
- [Settings.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Settings.png)

### 구현 상태 메모

- 위 에셋 적용 우선순위는 이번 문서 갱신에서 새로 고정한 작업 기준이다.
- 아직 빌드 전반에 일관되게 적용된 상태로 간주하지 않으며, 다음 Claude Code 구현에서 실제 씬과 UI에 붙여야 한다.

## 구현 단계

## 1. 플레이어 컨트롤러 고정

### 목표

전투 손맛의 기준이 되는 이동과 입력 반응을 먼저 고정한다.

### 세부 범위

- 좌우 이동
- 점프
- 더블 점프
- 대시
- 공중 시전
- 피격 경직
- 무적 프레임
- 사망 상태
- 로프 또는 사다리 상호작용

### 입력 기본안

| 액션 | 기본 키 |
| --- | --- |
| 이동 좌 | `Left` |
| 이동 우 | `Right` |
| 점프 | `Alt` |
| 대시 | `Shift` |
| 위 | `Up` |
| 아래 | `Down` |
| 스킬 1~6 | `Z`, `X`, `C`, `A`, `S`, `D` |
| 버프 1~6 | `Q`, `W`, `E`, `R`, `F`, `G` |
| 관리자 메뉴 | `Escape` |

### 상태 흐름

- `Idle`
- `Walk`
- `Jump`
- `DoubleJump`
- `Fall`
- `Dash`
- `OnRope`
- `Cast`
- `Hit`
- `Dead`

### 구현 대상 파일

- `scripts/player/player.gd`
- `scripts/player/player_state_chart.tres` 또는 대응 상태 차트 리소스
- `scenes/player/Player.tscn`
- `asset_sample/Character/male_hero_free/individual_sheets/male_hero-*.png`

### 완료 기준

- 키보드만으로 이동, 공중 이동, 시전, 피격, 사망이 모두 동작한다.
- 상태 전환은 `Godot State Charts` 이벤트를 통해 일어난다.
- 대시와 점프 타이밍이 전투 입력을 방해하지 않는다.

## 2. 스킬 런타임 구조 정리

### 목표

기존 스킬 데이터와 실제 전투 사용 구조를 분리하고, 슬롯 기반 시전 체계를 만든다.

### 세부 범위

- `skills.json` 기반 스킬 로드
- 스킬 슬롯 장착
- 액티브, 버프, 설치, 온앤오프, 패시브 타입 분리
- 마나 소모
- 쿨타임
- 시전 실패 피드백
- 방향성 투사체/근거리 판정

### 구현 대상 파일

- `data/skills/skills.json`
- `scripts/autoload/game_database.gd`
- `scripts/player/spell_manager.gd`
- `scripts/player/spell_runtime.gd` 또는 타입별 런타임 스크립트
- `scripts/player/spell_projectile.gd`

### 완료 기준

- 6개 전투 슬롯에 스킬을 배치할 수 있다.
- 스킬 발동 시 마나와 쿨타임이 정확히 반영된다.
- 시전 가능 여부가 플레이어 상태와 자원 상태를 반영한다.

## 3. 버프 중심 액션 루프 구축

### 목표

이 게임의 차별점인 강력한 버프 중첩과 조합 폭발 구간을 전투 핵심으로 만든다.

### 세부 범위

- 버프 중첩
- 동일 버프 중복 허용
- 서클 기반 동시 유지 수 제한
- 버프 조합 감지
- 조합 효과 적용
- 필살 버프의 종료 페널티
- 조합 UI 반영

### 우선 구현 조합

- `Prismatic Guard`
- `Overclock Circuit`
- `Time Collapse`
- `Ashen Rite`

### 구현 대상 파일

- `scripts/autoload/game_state.gd`
- `data/skills/buff_combos.json`
- `scripts/ui/game_ui.gd`

### 완료 기준

- 버프 2중첩부터 시작해 서클 상승에 따라 슬롯이 늘어난다.
- 같은 버프를 중복 시전할 수 있다.
- 특정 조합이 실제 전투 수치와 히트 감각을 바꾼다.

## 4. 몬스터 전투 세트 구축

### 목표

플레이어의 스킬과 버프를 시험할 수 있는 최소 전투 생태계를 만든다.

### 최소 적 세트

- 근접 추격형 1종
- 원거리 견제형 1종
- 돌진 또는 점프 압박형 1종
- 엘리트 또는 준보스 1종

### 적 공통 기능

- HP
- 슈퍼아머 유무
- 피격 경직
- 넉백
- 상태이상 저항 태그
- 사망 처리
- 드롭 테이블 연결용 슬롯

### 상태 흐름

- `Idle`
- `Patrol`
- `Chase`
- `Attack`
- `Hit`
- `Stagger`
- `Dead`

### 구현 대상 파일

- `scripts/enemies/enemy_base.gd`
- `scripts/enemies/enemy_melee.gd`
- `scripts/enemies/enemy_ranged.gd`
- `scripts/enemies/enemy_elite.gd`
- 대응 씬 파일

### 완료 기준

- 적이 순찰, 감지, 추격, 공격, 피격, 사망을 정상 수행한다.
- 플레이어의 모든 기본 스킬 타입이 적에게 유효하게 반응한다.

## 5. 장비 시스템 최소 버전

### 목표

레벨 시스템이 없는 대신, 장비가 전투 수치와 운용 방식에 즉시 영향을 주도록 만든다.

### 장비 슬롯

- 무기
- 보조 마도구
- 머리
- 상의
- 하의
- 장신구 2칸

### 반영 수치

- 마법 공격력
- 최대 MP
- MP 회복 속도
- 쿨타임 감소
- 특정 속성 강화
- 버프 지속시간 증가
- 설치물 유지시간 증가

### 구현 방식

- 장비 데이터는 JSON으로 관리한다.
- 장비 장착 결과는 `GameState` 또는 전용 장비 매니저에서 계산한다.
- 스킬 계산식은 장비 수치와 마스터리 최종 배수를 모두 반영한다.

### 구현 대상 파일

- `data/items/equipment.json`
- `scripts/autoload/game_state.gd`
- `scripts/player/equipment_manager.gd`
- `scripts/ui/equipment_panel.gd`

### 완료 기준

- 관리자 메뉴에서 장비를 즉시 지급하고 장착할 수 있다.
- 장착 전후 스킬 피해, 마나, 쿨타임 차이가 실제로 발생한다.

## 6. 전투 UI 구축

### 목표

현재 전투 상태를 빠르게 읽을 수 있고, 테스트 중 조정 지점을 바로 파악할 수 있어야 한다.
전투 중 조작 가능한 UI는 키보드와 마우스 양쪽 경로를 모두 제공해야 하며, 핫바와 패널 상호작용 감각은 메이플스토리에 가깝게 정리해야 한다.
최종 목표는 숫자와 텍스트만 나열하는 HUD가 아니라, 메이플스토리나 마비노기처럼 그래픽 바, 슬롯, 아이콘, 패널 프레임이 실제로 보이는 GUI다.

### 필수 UI

- HP 바
- MP 바
- 스킬 슬롯 6칸
- 버프 아이콘 및 중첩 수
- 조합 효과 표시
- 현재 서클
- 주요 전투 스탯 요약
- 대상 몬스터 HP 바
- 데미지 숫자
- 관리자 모드 활성 표시
- 스킬/버프/장비 아이콘
- 그래픽 패널 프레임과 배경
- 툴팁 패널

### 상호작용 기준

- 스킬 슬롯, 버프 슬롯, 장비 슬롯, 탭 버튼은 마우스 hover / click / double-click 상호작용을 지원한다.
- 키보드 단축키로 수행 가능한 기능은 대응되는 마우스 조작 경로도 제공한다.
- 마우스로 슬롯 hover 시 이름, 쿨타임, 설명, 비용, 상태 변화가 즉시 읽혀야 한다.
- 핫바, 장비, 인벤토리, 관리자 탭의 선택 상태는 키보드 포커스와 마우스 선택이 서로 충돌 없이 동기화되어야 한다.
- HP/MP는 텍스트 수치만 단독 노출하는 방식이 아니라, 그래픽 바와 수치가 함께 보이는 형태를 기본 기준으로 삼는다.
- 장비창과 인벤토리는 텍스트 목록이 아니라 슬롯, 아이콘, 점유 크기, 위치 이동을 시각적으로 보여주는 GUI를 목표로 한다.
- 스킬, 버프, 장비, 관리자 탭도 텍스트 전용 디버그 패널이 아니라 그래픽 슬롯/버튼/패널 기반 GUI로 확장되어야 한다.
- 이 기준은 현재 구현 완료 항목이 아니라, 이번 계획 문서에서 새로 확정한 구현 목표다.

### 구현 대상 파일

- `scripts/ui/game_ui.gd`
- `scripts/ui/combat_hud.gd`
- `scripts/ui/damage_label.gd`
- `scenes/ui/CombatHUD.tscn`
- `asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Action_panel.png`
- `asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Buttons.png`
- `asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Settings.png`

### 완료 기준

- 플레이 중 필요한 전투 정보가 HUD에서 모두 보인다.
- 스킬 쿨타임과 버프 유지 시간이 직관적으로 확인된다.
- 키보드 단축키만으로도 조작 가능하고, 동일한 UI 기능이 마우스 클릭/hover로도 동작한다.
- 메이플스토리식 UI 사용감에 맞는 슬롯 선택, 툴팁, 패널 상호작용이 실제 런타임에 구현된다.
- 전투 정보와 조작 UI가 텍스트 위주가 아니라 그래픽 바, 아이콘, 패널 프레임이 보이는 GUI로 제공된다.
- HP/MP, 핫바, 버프, 장비, 관리자 UI가 모두 그래픽 기반으로 표시된다.
- 지정된 `Action_panel / Buttons / Settings` PNG가 HUD 스타일링의 기본 리소스로 실제 연결된다.
- 위 마우스 상호작용 기준은 현재 문서에만 추가되었고 아직 구현 완료로 간주하지 않는다.
- 위 그래픽 GUI 기준 역시 현재 문서에 새로 추가된 요구사항이며 아직 미구현이다.

## 7. 관리자 모드 구축

### 목표

전투 샌드박스에서 밸런스와 시스템을 즉시 실험하는 개발자용 인터페이스를 만든다.
이 인터페이스는 기존 키보드 단축키 흐름을 유지하면서도, 메이플스토리식으로 탭과 목록과 슬롯을 마우스로 직접 클릭 가능한 상태까지 포함한다.
또한 관리자 UI도 최종적으로는 텍스트 본문이 아니라 그래픽 탭, 버튼, 슬롯, 인벤토리 패널로 구성된 GUI를 목표로 한다.

### 진입 방식

- `Escape`로 관리자 메뉴 토글
- 메뉴 활성화 시 게임 일시정지 여부를 옵션으로 제공
- 탭, 버튼, 슬롯, 목록 항목은 마우스로 직접 선택/실행 가능해야 한다.
- 키보드 탐색 포커스와 마우스 클릭 선택은 같은 상태를 공유해야 한다.
- 현재의 텍스트 중심 관리자 메뉴는 임시 구현으로 취급하고, 최종적으로는 그래픽 GUI로 대체한다.

### 탭 구성

#### 스킬 탭

- 전체 스킬 목록
- 현재 레벨 표시
- 레벨 강제 조정
- 슬롯 장착/해제
- 쿨타임 초기화
- 숙련도 직접 지급

#### 버프 탭

- 버프 수동 활성화
- 중첩 수 직접 지정
- 조합 강제 발동
- 조합 종료 페널티 테스트

#### 몬스터 탭

- 근접/원거리/엘리트/보스 소환
- 현재 커서 위치 소환
- 전체 제거
- AI 정지
- 무적 더미 소환

#### 아이템 탭

- 장비 지급
- 희귀도별 장비 랜덤 지급
- 즉시 장착
- 전 장비 해제
- 인벤토리 슬롯과 아이템 아이콘 표시
- 아이템 점유 크기(`가로 x 세로`) 표시
- 드래그 앤 드롭 또는 동등한 그래픽 위치 이동

#### 자원 탭

- 무한 HP
- 무한 MP
- 무한 쿨타임 해제
- 무적
- HP/MP 즉시 회복

#### UI 탭

- 데미지 숫자 표시 토글
- 히트스톱 표시 토글
- 디버그 패널 토글
- FPS 및 상태 표시 토글

### 구현 대상 파일

- `scripts/admin/admin_menu.gd`
- `scripts/admin/admin_state.gd`
- `scenes/admin/AdminMenu.tscn`
- `scenes/admin/AdminMap.tscn`
- `asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Buttons.png`
- `asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Inventory.png`
- `asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Equipment.png`
- `asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Settings.png`

### 완료 기준

- 관리자 메뉴만으로 전투 상황을 반복 재현할 수 있다.
- 스킬, 적, 장비, 자원, UI 테스트가 외부 편집 없이 가능하다.
- 관리자 메뉴의 핵심 기능은 단축키뿐 아니라 마우스 클릭으로도 접근 가능하다.
- 이 마우스 상호작용 목표는 2026-03-29 문서 갱신에서 추가된 요구사항이며, 현재 빌드에서 아직 구현되지 않은 작업으로 취급한다.
- 관리자 탭, 장비창, 스킬창, 버프창이 그래픽 패널과 아이콘을 가진 GUI로 제공된다.
- 장비/인벤토리 조작은 텍스트 목록이 아니라 실제 슬롯 기반 GUI에서 수행된다.
- 지정된 `Equipment / Inventory / Buttons / Settings` PNG가 관리자 GUI 스킨의 기본 리소스로 실제 연결된다.
- 이 그래픽 GUI 목표도 현재 문서에 새로 추가된 요구사항이며 아직 구현되지 않은 작업으로 취급한다.

## 8. 전투 수치와 데이터 정비

### 목표

실행 코드와 데이터가 분리된 상태에서 튜닝이 가능해야 한다.

### 데이터 우선 대상

- 스킬
- 버프 조합
- 장비
- 적 스탯
- 드롭 테이블
- 관리자 기본 프리셋

### 권장 데이터 파일

- `data/skills/skills.json`
- `data/skills/buff_combos.json`
- `data/items/equipment.json`
- `data/enemies/enemies.json`
- `data/admin/loadouts.json`

### 완료 기준

- 핵심 전투 수치는 JSON 수정만으로 조정 가능하다.
- 로더는 타입 오류 없이 헤드리스에서 안전하게 파싱된다.

## 9. 테스트와 검증 계획

### 헤드리스 필수 검증

- `godot --headless --path . --quit`
- `godot --headless --path . --quit-after 120`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`

### GUT 우선 테스트

- 플레이어 점프, 더블점프, 대시 상태 전환
- 스킬 마나 소모와 쿨타임
- 스킬 레벨 반영 계산
- 버프 중첩과 조합 발동
- 장비 장착 시 최종 스탯 계산
- 적 피격과 사망
- 관리자 토글과 핵심 명령 처리

### 수동 확인 체크리스트

- 입력 반응성이 즉각적인가
- 스킬 연계 시 막히는 후딜이 없는가
- 버프 조합의 순간 폭발력이 체감되는가
- 관리자 메뉴에서 재현이 쉬운가
- HUD 정보가 과하지 않으면서 충분한가

## Claude 구현 순서 제안

`CLAUDE.md` 규칙을 기준으로 Claude는 아래 순서로 작업하는 것이 가장 안전하다.

1. `spec-to-godot` 기준으로 이 문서를 작업 단위로 분해한다.
2. `godot-combat` 규칙에 따라 플레이어 상태와 스킬 매니저부터 만든다.
3. 적 최소 세트를 붙인다.
4. HUD를 붙인다.
5. 관리자 메뉴를 붙인다.
6. 장비 시스템 최소 버전을 붙인다.
7. 모든 단계마다 `GUT` 테스트와 헤드리스 검증을 통과시킨다.

## 구현 핸드오프

### 목표

스토리 없는 전투 샌드박스 빌드를 먼저 완성한다.

### 플레이 감각 목표

- 메이플식 횡스크롤 가독성
- 빠른 마법 연계
- 강한 버프 중첩 폭발력
- 테스트하기 쉬운 관리자 모드

### 이번 증분 범위

- 플레이어
- 스킬 슬롯
- 버프 조합
- 적 최소 세트
- 전투 HUD
- 관리자 메뉴
- 장비 최소 버전

### 예상 주요 파일

- `scripts/player/player.gd`
- `scripts/player/spell_manager.gd`
- `scripts/enemies/enemy_base.gd`
- `scripts/ui/game_ui.gd`
- `scripts/admin/admin_menu.gd`
- `scripts/autoload/game_state.gd`
- `scripts/autoload/game_database.gd`
- `data/skills/skills.json`
- `data/skills/buff_combos.json`
- `data/items/equipment.json`
- `data/enemies/enemies.json`

### 인수 기준

- 전투 샌드박스 맵에서 모든 전투 기능을 테스트할 수 있다.
- 관리자 메뉴에서 스킬, 적, 장비, 자원을 즉시 조작할 수 있다.
- 헤드리스 실행과 GUT 테스트가 모두 통과한다.

### 비목표

- 스토리 진행
- 본편 맵 구조
- NPC 상호작용
- 연출 중심 컷신

### 다음 증분

전투 샌드박스가 완성되면, 그 다음에는 이 전투 시스템 위에 지역 구조, 탐색 동선, 스토리 단서, NPC, 미궁 연출을 얹는다.
