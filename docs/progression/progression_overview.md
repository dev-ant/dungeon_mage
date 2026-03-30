# 성장 개요

상태: 사용 중  
최종 갱신: 2026-03-27  
섹션: 성장 시스템

## 범위

이 문서는 플레이어가 어떤 방식으로 성장하는지에 대한 기준 문서입니다.

## 핵심 규칙

- 캐릭터 레벨 시스템은 없습니다.
- 성장은 다음 요소에서 발생합니다.
- 스킬 사용과 숙련
- 장비 획득과 최적화
- 후반부 고서클 마법 해금
- 주인공은 이미 훈련된 상태이며 시작 시점에 10개의 마법을 알고 있습니다.
- 성장 단계는 `스킬 종합 레벨 -> 서클 승급` 규칙으로 판정합니다.

## 스킬 숙련

- 모든 스킬은 독립적인 스킬 레벨을 가집니다.
- 스킬 레벨은 1부터 30까지입니다.
- 스킬은 반복 사용으로 성장합니다.
- 스킬 레벨이 오를수록 기본적으로:
- 마나 소모가 줄어듭니다.
- 데미지가 증가합니다.
- 쿨타임이 줄어듭니다.

## 확장 성장 규칙

스킬에 따라 레벨 상승 시 다음 항목도 함께 증가할 수 있습니다.

- 지속시간
- 공격 범위
- 공격 대상 수
- 투사체 수
- 히트 수
- 오라 반경
- 설치 지속시간

## 장비의 역할

- 캐릭터 레벨이 없어도 장비 시스템은 존재합니다.
- 장비는 스킬 정체성을 대체하는 것이 아니라 빌드 방향을 강화해야 합니다.
- 장비는 마나 효율, 속성 특화, 시전 템포, 생존력, 유틸리티에 영향을 줄 수 있습니다.

## 버프 중심 전투 방향

- 이 게임은 순간 폭발력에서 뽕맛을 느끼는 액션 RPG를 지향합니다.
- 따라서 버프는 약한 보조 효과가 아니라 전투 흐름을 뒤집는 강력한 수단이어야 합니다.
- 버프는 중첩 가능하며, 같은 버프도 중복 시전이 가능합니다.
- 대신 긴 쿨타임과 일부 강력 버프의 부작용을 통해 리스크를 부여합니다.
- 자세한 규칙은 [buff_system.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/buff_system.md)에서 관리합니다.
- 서클 승급 기준은 [circle_progression.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/circle_progression.md)에서 관리합니다.

## 설계 의도

- 주인공이 이미 엘리트 마법사이기 때문에 시작부터 강하게 느껴져야 합니다.
- 자주 쓰는 스킬일수록 더 부드럽고 효율적으로 운용되도록 만들어야 합니다.
- 장비는 단순 수치 누적보다는 플레이스타일을 더 깊게 만들어야 합니다.

## 연관 문서

- [buff_system.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/buff_system.md)
- [circle_progression.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/circle_progression.md)
- [spell_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/spell_catalog.md)
- [protagonist.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/protagonist.md)
