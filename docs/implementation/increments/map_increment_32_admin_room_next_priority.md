---
title: 관리자 대표 방 다음 우선순위
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 관리자 대표 방 다음 우선순위

## 이번 증분에서 잠근 내용

- 관리자 `Resources` 탭은 이제 현재 선택된 대표 방에 대해 `Next Priority`를 표시한다.
- 이 우선순위는 사용자 결정이 덜 필요한 작업부터 이어가기 위한 구현 가이드이며, 이미 잠긴 문서 기준과 현재 progression 상태만을 사용한다.

## 우선순위 원칙

- 스캐폴드만 있는 방:
  - 아직 비어 있는 핵심 단서를 먼저 잠근다
- 부분 잠금 상태 방:
  - 남은 단서를 채워 phase 해석을 완성한다
- 완전 잠금 상태 방:
  - 직접 조우/컷신을 건드리지 않는 범위에서 반응성, 검증성, payoff polish를 우선한다

## 보류 유지

- 직접 조우, 컷신, 보스전 페이즈 연출은 여전히 사용자 결정이 필요한 범위로 남긴다.
- 이번 증분은 이미 잠긴 환경 단서를 기준으로 다음 안전 작업 순서를 제안하는 범위까지만 다룬다.
