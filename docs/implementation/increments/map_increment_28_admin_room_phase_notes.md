---
title: 관리자 대표 방 서사 역할 메모
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

# 관리자 대표 방 서사 역할 메모

## 이번 증분에서 잠근 내용

- 관리자 `Resources` 탭은 이제 현재 선택된 대표 방이 맵 서사 체인에서 맡는 역할을 `Room Note`로 직접 표시한다.
- 이 메모는 phase 전체 요약과 별개로, 각 대표 방을 구현 또는 검증할 때 어떤 역할을 유지해야 하는지 빠르게 handoff 하기 위한 것이다.
- 현재 `Room Note`의 source of truth는 `GameState.get_room_note_summary()`이며, 관리자 메뉴는 더 이상 로컬 분기로 같은 규칙을 중복 계산하지 않는다.

## 현재 메모 범위

- `4F entrance`
  - 겉으로는 출구처럼 보이지만 더 깊은 곳을 가리키는 외벽 붕괴 지점
- `6F seal_sanctum`
  - 위층에서 드러난 진실을 생존 가능한 경고로 다시 적어두는 허브
- `7F gate_threshold`
  - 혈통을 판정하는 문턱
- `8F royal_inner_hall`
  - 기록 삭제와 왜곡된 지원 흔적이 겹치기 시작하는 내성
- `9F throne_approach`
  - 강요와 판단이 패턴을 완성하는 왕좌 접근부
- `10F inverted_spire`
  - 모든 단서를 계약의 의도로 묶는 최종 확인 공간

## 보류 유지

- 직접 조우, 컷신, 보스전 페이즈 연출은 여전히 사용자 결정이 필요한 범위로 남긴다.
- 이번 증분은 잠긴 해석을 방 단위 메모로 재표현하는 범위까지만 다룬다.
