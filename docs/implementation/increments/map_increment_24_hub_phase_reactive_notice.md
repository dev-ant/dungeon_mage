---
title: 허브 공지판 단계 반응 고도화
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

# 허브 공지판 단계 반응 고도화

## 이번 증분에서 잠근 내용

- `seal_sanctum`의 `refuge_notice`는 이제 단일 progression flag뿐 아니라 `복수 flag가 모두 충족되어야 열리는 단계 반응`도 지원한다.
- 현재 허브 반응은 세 단계 묶음으로 읽힌다.
  - `Threshold`: 7층 생존자 경고 + 7층 혈통 떡밥
  - `Companion`: 8층 친구 B 전조 + 8층 기록 + 9층 친구 B 전조 + 9층 칙령
  - `Final`: 10층 계약 확인
- `Final`은 기존처럼 최우선이며, 그 아래에서 `Companion` 묶음 반응이 단일 8층/9층 반응보다 우선한다.
- `Threshold` 묶음 반응도 단일 7층 반응보다 우선한다.

## 구현 변경

- [refuge_notice.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/world/refuge_notice.gd)
  - `required_flags_all` 조건 해석 추가
- [admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
  - 관리자 `Reactive Preview`도 같은 조건 해석을 사용하도록 동기화
- [rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
  - `seal_sanctum` 공지판에 `Threshold` 묶음 메시지 추가
  - `seal_sanctum` 공지판에 `Companion` 묶음 메시지 추가

## 검증 포인트

- 단일 7층 플래그만 있을 때는 기존 개별 경고가 보인다.
- 7층 두 플래그가 모두 있으면 묶음 경고가 개별 경고를 덮는다.
- 8층/9층 묶음 네 플래그가 모두 있으면 companion 요약 반응이 개별 8층/9층 반응을 덮는다.
- 10층 계약을 확인하면 최종 계약 반응이 최우선으로 유지된다.
