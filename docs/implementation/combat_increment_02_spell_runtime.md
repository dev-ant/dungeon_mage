# 전투 2차 작업 체크리스트 - 스킬 런타임 구조

상태: 사용 중  
최종 갱신: 2026-03-28  
섹션: 구현 기준

## 목표

이 문서는 [전투 우선 구현 계획](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/combat_first_build_plan.md)의 두 번째 증분인 `스킬 런타임 구조 정리`를 Claude가 바로 구현할 수 있도록 쪼갠 작업 체크리스트다.

이번 증분의 핵심은 `문서와 JSON에 있는 스킬 정의를 실제 전투 슬롯과 시전 흐름에 연결하는 것`이다.

## 진행 상태

### 현재 완료

- [spell_manager.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_manager.gd) 추가
- 플레이어 시전 책임 일부를 `spell_manager`로 분리
- 기본 3개 전투 스킬의 쿨타임 시작과 재시전 제한을 매니저로 이동
- `Z/C/V + Q/R/F` 기준 6슬롯 1차 구조 추가
- 버프 3종을 `spell_manager`를 통해 같은 슬롯 흐름에서 시전 가능하게 정리
- HUD에 현재 핫바 요약 표시 추가
- 핫바 슬롯 구성을 `GameState` 저장 데이터로 분리
- 슬롯 교체 결과가 저장 구조에 반영되도록 연결
- 기본 시전 실패 이유를 메시지로 노출
- 설치형 스킬 1종 `Stone Spire` 런타임 편입
- 온앤오프 스킬 1종 `Grave Echo` 런타임 편입
- `Escape` 기반 관리자 메뉴 최소 버전 추가
- 관리자 메뉴에서 슬롯 선택, 스킬 교체, 프리셋 적용 가능
- 마나 자원 추가
- 마나 부족 시 시전 실패와 메시지 노출 추가
- 관리자 `무한 MP`, `쿨타임 무시` 플래그 추가
- 시전 피드백을 HUD 고정 영역에 노출
- 설치형/토글형 실험용 핫바 프리셋 추가
- 상위 토글형 `Glacial Dominion`, `Tempest Crown`, `Soul Dominion` 샌드박스 프리셋 추가
- 토글형 스킬의 지속 마나 소모와 마나 고갈 시 자동 해제 추가
- 토글형별 유지 마나 소모를 `skills.json` 데이터 기반으로 분기
- `spell_manager` 관련 GUT 테스트 추가

### 아직 남은 작업

- 관리자 메뉴에 자원/몬스터/아이템 기능 확장
- 마나 회복 연출 또는 소비 피드백 강화
- 토글형 지속 피해/특수효과를 스킬별로 더 분기
- `Soul Dominion` 전용 리스크와 후유증은 별도 증분으로 분리

## 현재 기준

- 스킬 데이터는 [skills.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/skills/skills.json)에 존재한다.
- 버프 조합 데이터는 [buff_combos.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/skills/buff_combos.json)에 존재한다.
- 데이터 로더는 [game_database.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd)에 있다.
- 스킬 성장과 버프 일부 런타임은 [game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)에 이미 일부 연결되어 있다.
- 플레이어 시전 입력은 [player.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/player.gd)에 분산되어 있으므로, 이번 작업에서는 시전 책임을 별도 매니저로 정리하는 것이 우선이다.

## 플레이 경험 목표

- 스킬을 누르면 즉시 발동한다.
- 슬롯별 스킬 교체가 쉬워야 한다.
- 마나 부족, 쿨타임, 시전 불가 상황이 명확하게 느껴져야 한다.
- 액티브, 버프, 설치, 온앤오프 스킬이 같은 런타임 체계 안에서 처리되어야 한다.
- 이후 관리자 메뉴에서 스킬 레벨과 슬롯을 즉시 바꿔도 구조가 흔들리지 않아야 한다.

## 이번 범위

### 포함

- 스킬 슬롯 6칸 체계
- 스킬 데이터 로드와 슬롯 매핑
- 시전 가능 여부 판정
- 마나 차감
- 쿨타임 시작과 종료
- 액티브/버프/설치/온앤오프 타입 분기
- 공중 시전 허용
- 시전 실패 피드백
- 런타임 수치 계산
- 스킬 관련 GUT 테스트

### 제외

- 관리자 메뉴 슬롯 UI
- 장비 수치 최종 반영
- 적 AI 확장
- 신규 스킬 15종 전부의 완전한 연출 구현
- 보스 전용 스킬 로직

## Claude 작업 순서

1. 현재 [spell_manager.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_manager.gd)의 `6슬롯 1차 구조`를 읽는다.
2. 현재 저장 가능한 `skill_id` 장착 상태를 읽고, 관리자 메뉴가 바로 쓸 수 있는 API를 다듬는다.
3. 관리자 메뉴에 자원, 몬스터, 아이템 테스트 기능을 확장한다.
4. 설치/온앤오프 스킬을 빠르게 시험할 수 있는 샌드박스 프리셋을 보강한다.
5. 마나 회복, 마나 소비량, 무한 MP 상태를 전투 HUD에서 더 명확하게 보이게 한다.
6. `Soul Dominion` 전용 리스크는 [combat_increment_09_soul_dominion_risk.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/combat_increment_09_soul_dominion_risk.md) 기준으로 별도 진행한다.
7. GUT 테스트를 보강하고 헤드리스 검증을 다시 통과시킨다.

## 슬롯 구조

### 기본 슬롯

| 슬롯 | 기본 키 | 역할 |
| --- | --- | --- |
| 1 | `Z` | 주력 액티브 |
| 2 | `X` | 주력 액티브 |
| 3 | `C` | 이동 또는 제어기 |
| 4 | `A` | 버프 또는 설치 |
| 5 | `S` | 버프 또는 설치 |
| 6 | `D` | 필살 또는 상황 대응 |

### 요구사항

- 모든 슬롯은 `skill_id` 기반으로 관리한다.
- 스킬 장착 상태는 저장 가능한 구조여야 한다.
- 슬롯 비어 있음 상태를 허용한다.
- 이후 관리자 메뉴에서 즉시 교체 가능해야 한다.

## 런타임 책임 분리

### Player

- 입력 수집
- 이동/상태 처리
- 시전 요청 전달

### SpellManager

- 슬롯 관리
- 시전 가능 여부 판단
- 마나/쿨타임 처리
- 스킬 타입 분기
- 런타임 인스턴스 생성

### GameState

- 스킬 레벨
- 숙련도
- 버프 상태
- 자원 상태
- 최종 계산용 전역 보정

### GameDatabase

- JSON 로드
- 스킬 원본 데이터 제공

## 스킬 타입 처리 기준

### 액티브

- 투사체 또는 근접 판정 생성
- 방향은 플레이어 바라보는 방향 기준
- 마법 공격력, 스킬 레벨, 마스터리 보정을 반영

### 버프

- `GameState.active_buffs`에 등록
- 지속시간 시작
- 중첩과 중복 허용 규칙 반영
- 조합 재계산 호출

### 설치

- 월드에 오브젝트 생성
- 유지시간 후 자동 제거
- 설치 수 제한이 필요하면 스킬별 옵션으로 처리

### 온앤오프

- 누르면 켜지고 다시 누르면 꺼짐
- 유지 중 마나 소모는 스킬 데이터의 `sustain_mana_*` 필드로 분기
- 마나가 바닥나면 자동 해제됨

### 패시브

- 이번 증분에서는 직접 시전 대상이 아님
- 계산식에서 최종 보정으로만 반영

## 시전 가능 조건

다음 조건을 모두 만족해야 한다.

- 슬롯에 스킬이 장착되어 있음
- 플레이어가 `Dead` 상태가 아님
- 플레이어가 강제 경직 또는 불가 상태가 아님
- 마나가 충분함
- 쿨타임이 없음
- 특정 스킬이 공중 불가라면 지상에 있음

## 수치 계산 기준

기본 방향은 기존 문서를 따른다.

- 피해: `마법 공격력 x 스킬 계수 + 고정 가산`
- 최종 보정: 마스터리, 버프, 장비, 조합 효과
- 마나: 스킬 레벨과 패시브/버프 보정 적용
- 쿨타임: 스킬 레벨과 패시브/버프 보정 적용

이번 증분에서는 아래까지 연결하면 충분하다.

- 스킬 레벨이 오르면 기본 피해 상승
- 스킬 레벨이 오르면 마나 소모 감소
- 스킬 레벨이 오르면 쿨타임 감소
- 해당 속성 마스터리가 최종 배수로 붙음

## 예상 구현 파일

- [game_database.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd)
- [game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)
- [player.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/player.gd)
- [spell_manager.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_manager.gd)
- 기존 [spell_projectile.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_projectile.gd)
- [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)
- [test_spell_manager.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_spell_manager.gd)
- 필요 시 [test_game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_game_state.gd) 확장

## 세부 작업 체크리스트

### 1. 슬롯 데이터 정리

- 기본 장착 슬롯 6개 정의
- `skill_id` 기반 저장 구조 확정
- 빈 슬롯 처리

### 2. 시전 매니저 생성

- 입력과 시전 책임 분리
- `request_cast(slot_index)` 형태의 인터페이스 제공
- 실패 시 원인 반환

### 3. 마나와 쿨타임 처리

- 시전 성공 시 마나 차감
- 시전 성공 시 쿨타임 시작
- 쿨타임 남은 시간 조회 가능

### 4. 타입별 실행

- 액티브는 투사체 또는 판정 생성
- 버프는 `GameState` 반영
- 설치는 월드 오브젝트 생성
- 온앤오프는 토글

### 5. UI 연결

- 슬롯별 쿨타임 표시용 데이터 제공
- 마나 부족 피드백 제공
- 슬롯 이름과 키 라벨 연동

### 6. 성장 수치 연결

- 스킬 레벨 반영
- 마스터리 최종 배수 반영
- 속성별 기본 계산 함수 확정

## 수용 기준

- 플레이어가 6개 슬롯 스킬을 시전할 수 있다.
- 마나 부족, 쿨타임, 상태 제한으로 시전 실패가 구분된다.
- 버프 스킬과 액티브 스킬이 같은 슬롯 구조 안에서 공존한다.
- 런타임 계산이 현재 문서 기준과 크게 어긋나지 않는다.
- 관리자 메뉴 없이도 기본 슬롯만으로 전투 테스트가 가능하다.

## 테스트 체크포인트

### GUT

- 슬롯 장착/해제
- 마나 부족 시 시전 실패
- 쿨타임 중 재시전 실패
- 관리자 쿨타임 무시 시 재시전 가능
- 스킬 레벨에 따른 피해/마나/쿨타임 변화
- 버프형 스킬 시전 시 활성 버프 등록
- 설치형 스킬 시전 시 노드 생성

### 헤드리스

- `godot --headless --path . --quit`
- `godot --headless --path . --quit-after 120`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`

## 비목표

- 모든 스킬의 전용 시각효과 완성
- 장비 UI
- 관리자 슬롯 편집 UI
- 보스 패턴용 특수 스킬 처리

## 다음 증분

이 작업이 끝나면 다음은 `버프 중심 액션 루프 구축`이다. 그때는 중첩, 조합, 서클 기반 슬롯 제한, 필살 버프 종료 페널티를 실제 전투 템포에 맞게 붙인다.

## Claude 바로 다음 작업

Claude는 다음 순서로 이어서 작업하면 된다.

1. 관리자 메뉴에 무한 HP/MP, 쿨타임 리셋 같은 자원 테스트 기능을 추가한다.
2. 관리자 메뉴에 적 소환 또는 슬롯 프리셋 기능을 더 붙인다.
3. 시전 실패 이유를 HUD나 관리자 패널에서 읽을 수 있는 형태로 고정 표시한다.
4. 그다음 버프 중심 액션 루프 문서에 맞춰 조합과 핫바가 자연스럽게 이어지도록 정리한다.
