# 버프 조합 특수효과 목록

상태: 사용 중  
최종 갱신: 2026-03-27  
섹션: 성장 시스템

## 범위

이 문서는 버프 동시 사용으로 발생하는 특수효과의 기준 문서입니다. 버프 중첩 규칙과 동시 유지 규칙은 [buff_system.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/buff_system.md)에서, 개별 버프의 상세 스펙은 [buff_skill_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/buff_skill_catalog.md)에서 관리합니다.

## 설계 원칙

- 조합 효과는 단순 수치 합보다 전투 감각의 변화를 우선합니다.
- 조합은 플레이어가 직접 준비한 폭발 창구처럼 느껴져야 합니다.
- 기본은 `2버프 조합`, 상위는 `3버프 조합`으로 설계합니다.
- 조합 효과는 마스터리 최종 곱 이후에 적용하는 별도 효과로 다룹니다.
- 조합 효과는 같은 전투에서 반복 발동할 수 있지만, 개별 내부 쿨타임을 둘 수 있습니다.

## 공통 판정 규칙

- 조합은 필요한 버프가 동시에 활성 상태일 때만 성립합니다.
- 같은 이름의 버프를 여러 번 중첩해도 조합 판정은 `버프 종류 충족 여부` 기준으로만 확인합니다.
- 3버프 조합이 성립할 경우, 구성에 포함된 2버프 조합보다 우선 적용됩니다.
- 일부 조합은 발동 즉시 효과, 일부 조합은 유지형 효과, 일부 조합은 조건부 트리거 효과를 가집니다.

## 조합 표

| 조합 이름 | 구성 버프 | 조합 유형 | 전투 성격 | 내부 쿨타임 |
| --- | --- | --- | --- | --- |
| Prismatic Guard | Mana Veil + Crystal Aegis | 유지형 | 안정 돌파 / 탱킹 | 없음 |
| Overclock Circuit | Tempest Drive + Conductive Surge | 유지형 | 번개 연계 폭딜 | 없음 |
| Funeral Bloom | Grave Pact + Verdant Overflow | 조건부 트리거형 | 흑마법 설치 압박 | 1.5초 |
| Time Collapse | Astral Compression + World Hourglass | 유지형 | 범용 극딜 창구 | 없음 |
| Ashen Rite | Grave Pact + World Hourglass + Throne of Ash | 의식형 최종 조합 | 최종 필살 폭발 | 6초 |

## 상세 조합 스펙

### Prismatic Guard

- 구성:
- `Mana Veil`
- `Crystal Aegis`
- 유형: 유지형 방어 조합
- 효과:
- 피격 경직 대부분 무시
- 최대 체력 비례 보호막 생성
- 보호막 붕괴 시 주변에 짧은 충격파 발생
- 설계 의도:
- 공격적인 세팅이 아니어도 “버프를 올리면 몸이 완전히 달라진다”는 감각을 줍니다.

### Overclock Circuit

- 구성:
- `Tempest Drive`
- `Conductive Surge`
- 유형: 유지형 템포 조합
- 효과:
- 번개 계열 스킬 후딜 추가 12% 감소
- 번개 체인 수 +1
- 대시 직후 사용한 번개 스킬의 시전 속도 증가
- 설계 의도:
- 손이 빠른 플레이어일수록 체감이 크게 나는 속공형 조합입니다.

### Funeral Bloom

- 구성:
- `Grave Pact`
- `Verdant Overflow`
- 유형: 조건부 트리거형 설치 조합
- 효과:
- 설치형 흑마법 또는 식물 계열 스킬이 적 처치 시 부패 폭발 발생
- 폭발은 주변 적에게 흑마법 피해와 약한 속박 부여
- 설치물 유지 중 처치가 연속되면 폭발 반경이 최대 3회까지 커짐
- 내부 쿨타임:
- 1.5초
- 설계 의도:
- 필드 장악형 빌드가 방 하나를 통째로 연쇄 폭발시키는 맛을 노립니다.

### Time Collapse

- 구성:
- `Astral Compression`
- `World Hourglass`
- 유형: 유지형 범용 극딜 조합
- 효과:
- 직접 피해형 스킬 최종 피해 증가
- 캐스팅 속도 추가 증가
- 유지 시간 동안 첫 3회의 스킬은 쿨타임을 50%만 소비
- 설계 의도:
- 어떤 속성 빌드든 “지금이 폭딜 타이밍”이라고 느끼게 하는 범용 조합입니다.

### Ashen Rite

- 구성:
- `Grave Pact`
- `World Hourglass`
- `Throne of Ash`
- 유형: 의식형 최종 조합
- 효과:
- 화염과 흑마법 최종 피해 대폭 증가
- 적 처치 여부와 무관하게 일정 간격으로 잔재 폭발 발생
- 유지 중 스킬 적중 시 `재` 중첩이 쌓이며, 종료 시 중첩 수에 비례한 대폭발 발생
- 종료 페널티:
- 마나 완전 고갈
- 10초간 방어력 약화
- 6초간 동일 버프군 재사용 봉인
- 설계 의도:
- 하이리스크 하이리턴의 끝점으로, 보스 마무리용 의식에 가깝게 설계합니다.

## 구현용 데이터 필드 권장안

향후 실제 데이터 테이블 또는 JSON으로 옮길 때는 아래 필드를 권장합니다.

| 필드 | 설명 |
| --- | --- |
| combo_id | 내부 식별자 |
| display_name | UI 표시 이름 |
| required_buffs | 필요 버프 ID 배열 |
| priority | 동시 충족 시 우선순위 |
| combo_type | 유지형 / 즉발형 / 조건부 트리거형 |
| internal_cooldown | 내부 쿨타임 |
| effect_tags | 후딜 감소, 체인 증가, 보호막 생성 등 |
| penalty_tags | 종료 페널티 또는 반동 |
| vfx_hint | 연출 키워드 |

## 관리 메모

- 버프 종류 자체의 수치 조정은 [buff_skill_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/buff_skill_catalog.md)에서 합니다.
- 조합 발동 조건과 효과 조정은 이 문서에서 합니다.
- 조합 우선순위와 적용 순서는 [buff_system.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/buff_system.md)와 함께 봅니다.
- 실제 데이터 필드와 `combo_id`, `required_buffs` 규칙은 [buff_combo_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/buff_combo_data_schema.md)와 [skill_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/skill_data_schema.md)를 따릅니다.
