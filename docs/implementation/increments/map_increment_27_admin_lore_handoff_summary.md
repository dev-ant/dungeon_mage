---
title: 관리자 서사 핸드오프 요약
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

# 관리자 서사 핸드오프 요약

## 이번 증분에서 잠근 내용

- 관리자 `Resources` 탭은 이제 `Threshold / Companion / Final` 세 단계를 단순 상태 마커뿐 아니라 짧은 서사 문장으로도 요약한다.
- 이 요약은 이후 구현자가 `지금 무엇이 이미 잠겼는지`를 룸 데이터와 진행 플래그를 다시 추적하지 않고도 바로 읽게 하기 위한 handoff 역할을 맡는다.

## 요약 기준

- `Threshold`
  - 7층 문턱이 혈통을 판정하는 선택 장치라는 해석
- `Companion`
  - 8층/9층 전조와 기록이 친구 B 계열 지원 흔적이 왜곡된 패턴이라는 해석
- `Final`
  - 10층 계약이 위 단서들을 하나의 의도로 묶는다는 해석

## 범위

- 직접 조우, 컷신, 보스전 페이즈 연출은 여전히 포함하지 않는다.
- 이번 증분은 현재 잠긴 맵 서사 체인을 `admin preview`에서 읽기 좋게 handoff 하는 범위까지만 다룬다.
