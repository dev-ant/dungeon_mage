---
title: 관리자 단계 교차 검증 프리뷰
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
last_updated: 2026-04-06
last_verified: 2026-04-06
---

# 관리자 단계 교차 검증 프리뷰

## 이번 증분에서 잠근 내용

- 관리자 `Resources` 탭은 이제 같은 progression phase에 대해 `6층 허브 반응`과 `10층 최심층 경고`를 한 화면에서 함께 보여준다.
- 이 프리뷰는 현재 선택 방과 무관하게, 잠긴 source-of-truth phase 해석이 세계 반응에서 어떻게 읽히는지 교차 검증하는 용도다.

## 프리뷰 구성

- `Hub Notice`
  - 현재 progression 기준으로 `seal_sanctum`의 공지판이 보여줄 반응
- `Final State`
  - 현재 progression 기준으로 `inverted_spire`의 최심층 경고 상태
- `Final Gate`
  - 현재 progression 기준으로 `inverted_spire`의 차단 경고 핵심 문구

## 의도

- `Threshold / Companion / Final`이 관리자 요약 텍스트에만 잠기는 것이 아니라,
  실제 허브 텍스트와 최심층 경고 문구 양쪽에 일관되게 반영되는지 즉시 확인할 수 있어야 한다.
- 직접 조우/컷신 같은 미확정 연출을 잠그지 않고도,
  현재까지 잠긴 맵 서사 체인이 서로 어긋나지 않는지 빠르게 점검할 수 있어야 한다.
