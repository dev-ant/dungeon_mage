---
title: 버프 스킬 목록
doc_type: catalog
status: active
section: progression
owner: design
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/buff_system.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md
update_when:
  - rule_changed
  - status_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 버프 스킬 목록

상태: 사용 중  
최종 갱신: 2026-04-02  
섹션: 성장 시스템

## 범위

이 문서는 실제 버프 스킬의 기준 문서입니다. 버프 시스템 규칙은 [buff_system.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/buff_system.md)에서, 최신 스킬 이름/서클/속성 기준은 [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md)에서 관리합니다. 구현/asset/effect 적용 상태는 [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md)를 우선합니다.

## 버프 스킬 표

| 이름 | 서클 | 계열 | 지속시간 | 쿨타임 | 중첩 | 핵심 효과 | 부작용 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Mana Veil | 2 | 백마법 | 4초 | 24초 | 가능 | 피해 감소, 경직 안정화 | 없음 |
| Pyre Heart | 4 | 원소마법 / 화염 | 8초 | 34초 | 가능 | 화염 피해 증가, 근거리 폭발 부여 | 종료 후 화상 자해 |
| Frostblood Ward | 4 | 원소마법 / 빙결 | 9초 | 32초 | 가능 | 빙결 지속 증가, 피격 시 냉기 반사 | 종료 후 이동 속도 감소 |
| Tempest Drive | 5 | 원소마법 / 바람 | 8초 | 32초 | 가능 | 이동 속도 증가, 후딜 감소 | 종료 후 짧은 현기증 |
| Conductive Surge | 5 | 원소마법 / 번개 | 7초 | 38초 | 가능 | 번개 피해 증가, 체인 수 증가 | 종료 후 마나 회복 정지 |
| Crystal Aegis | 6 | 백마법 | 10초 | 40초 | 가능 | 피해 감소, 슈퍼아머 보조 | 없음 |
| Grave Pact | 6 | 흑마법 | 8초 | 42초 | 가능 | 흑마법 피해 증가, 처치 시 흡수 | 유지 중 초당 체력 소모 |
| Verdant Overflow | 7 | 원소마법 / 식물 | 12초 | 48초 | 가능 | 설치 범위 증가, 설치 지속시간 증가 | 종료 후 스킬 쿨 회복 지연 |
| Astral Compression | 8 | 공통 마법 | 6초 | 55초 | 가능 | 모든 스킬 데미지 압축 강화, 마나 효율 상승 | 종료 후 받는 피해 증가 |
| World Hourglass | 9 | 공통 마법 | 5초 | 70초 | 가능 | 짧은 시간 캐스팅 가속, 쿨 회전 가속 | 종료 후 캐스팅 속도 대폭 감소 |
| Throne of Ash | 10 | 흑마법 / 화염 | 6초 | 90초 | 가능 | 극딜 창구, 화염 및 흑마법 최종 배수 강화 | 종료 후 마나 고갈, 방어 약화 |

## 상세 스펙

### Mana Veil

- 역할: 초중반 생존 시작점
- 효과:
- 피해 감소 18%
- 경직 저항 상승
- 동일 버프 중첩:
- 피해 감소는 점감 적용
- 추천 조합:
- `Crystal Aegis`
- `Sanctuary of Reversal`

### Pyre Heart

- 역할: 화염 폭딜 시동 버프
- 효과:
- 화염 계열 최종 피해 증가
- 근거리 화염 스킬 사용 시 추가 폭발 발생
- 동일 버프 중첩:
- 폭발 피해량만 점감 중첩
- 부작용:
- 종료 후 4초간 약한 화상 자해
- 추천 조합:
- `Inferno Sigil`
- `Tempest Drive`

### Frostblood Ward

- 역할: 빙결 제어와 안정성 강화
- 효과:
- 빙결 지속시간 증가
- 피격 시 냉기 반사 파동
- 동일 버프 중첩:
- 반사 피해와 빙결 시간만 점감 중첩
- 부작용:
- 종료 후 5초간 이동 속도 15% 감소
- 추천 조합:
- `Ice Wall`
- `Glacial Dominion`

### Tempest Drive

- 역할: 바람 계열 연계와 전투 템포 강화
- 효과:
- 이동 속도 증가
- 후딜 감소
- 공중 시전 안정화
- 동일 버프 중첩:
- 이동 속도 상승은 점감 적용
- 부작용:
- 종료 후 2초간 짧은 경직 증가
- 추천 조합:
- `Pyre Heart`
- `Conductive Surge`

### Conductive Surge

- 역할: 번개 폭딜 보조
- 효과:
- 번개 계열 피해 증가
- 체인 수 +1
- 번개 계열 스킬 명중 시 짧은 추가 타격 발생
- 동일 버프 중첩:
- 체인 수는 늘지 않고 추가 타격 피해만 점감 증가
- 부작용:
- 종료 후 6초간 마나 자연 회복 정지
- 추천 조합:
- `Tempest Drive`
- `Tempest Crown`

### Crystal Aegis

- 역할: 상위 방어 버프의 핵심
- 효과:
- 피해 감소
- 슈퍼아머 보조
- 상태 이상 저항 증가
- 동일 버프 중첩:
- 방어 성능만 점감 증가
- 추천 조합:
- `Mana Veil`
- `Sanctuary of Reversal`

### Grave Pact

- 역할: 리스크를 동반한 흑마법 증폭
- 효과:
- 흑마법 피해 증가
- 처치 시 체력/마나 일부 회수
- 동일 버프 중첩:
- 회수량과 피해 증가 모두 점감 적용
- 부작용:
- 유지 중 초당 체력 1.5% 소모
- 추천 조합:
- `Grave Echo`
- `Abyss Gate`

### Verdant Overflow

- 역할: 설치형 빌드 폭발 창구
- 효과:
- 설치 범위 증가
- 설치 지속시간 증가
- 설치물 대상 수 증가
- 동일 버프 중첩:
- 범위와 지속시간만 점감 적용
- 부작용:
- 종료 후 6초간 설치형 스킬 재시전 지연
- 추천 조합:
- `Vine Snare`
- `Worldroot Bastion`

### Astral Compression

- 역할: 중후반 공통 딜 버프
- 효과:
- 모든 직접 피해형 마법의 데미지 압축 강화
- 스킬별 마나 효율 증가
- 동일 버프 중첩:
- 최종 배수는 강한 점감 적용
- 부작용:
- 종료 후 5초간 받는 피해 20% 증가
- 추천 조합:
- `Crystal Aegis`
- `World Hourglass`

### World Hourglass

- 역할: 극딜 창구를 여는 시간 압축 버프
- 효과:
- 캐스팅 속도 대폭 증가
- 쿨타임 회전 가속
- 짧은 시간 동안 연속 시전 리듬 확보
- 동일 버프 중첩:
- 쿨 회전 가속은 2중첩부터 강한 점감
- 부작용:
- 종료 후 8초간 캐스팅 속도 25% 감소
- 추천 조합:
- `Astral Compression`
- `Throne of Ash`

### Throne of Ash

- 역할: 최종 필살 버프
- 효과:
- 화염과 흑마법 최종 피해 대폭 증가
- 필드에 잔재 폭발 추가
- 동일 버프 중첩:
- 실전에서는 1중첩을 기본 권장
- 부작용:
- 종료 즉시 마나 고갈
- 10초간 방어력 약화
- 추천 조합:
- `World Hourglass`
- `Grave Pact`

## 관리 메모

- 버프의 동시 유지 수와 중첩 규칙은 [buff_system.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/buff_system.md)를 우선합니다.
- 개별 버프 스킬이 전체 마법 목록에도 등장할 경우, 자세한 버프 전투 성격은 이 문서를 우선 기준으로 삼습니다.
- 버프 조합 특수효과와 우선순위는 [buff_combo_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_catalog.md)를 우선합니다.
