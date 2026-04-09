---
title: 관리자 대표 방 서사 연결 메모
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

# 관리자 대표 방 서사 연결 메모

## 이번 증분에서 잠근 내용

- 관리자 `Resources` 탭은 이제 현재 선택된 대표 방이 다음 대표 방으로 어떤 서사 의미를 넘겨주는지 `Path Note`로 표시한다.
- `Room Note`가 방 자체의 역할을 요약한다면, `Path Note`는 그 방이 prototype flow 안에서 다음 구간으로 넘기는 해석을 요약한다.
- 현재 `Path Note`의 source of truth는 `GameState.get_room_path_note_summary()`이며, 관리자 메뉴는 그 결과만 소비한다.

## 현재 메모 방향

- `4F -> 6F`
  - 추락과 외벽 붕괴 감각이 허브의 생존 해석으로 넘어간다.
- `6F -> 7F`
  - 허브 경고가 7층 심판 문턱 진입의 문맥이 된다.
- `7F -> 8F`
  - 혈통 판정 문턱이 내성 조사 단계로 넘겨진다.
- `8F -> 9F`
  - 지워진 기록과 왜곡된 지원 흔적이 왕좌 강요 패턴으로 이어진다.
- `9F -> 10F`
  - 강요 패턴이 계약의 의도로 최종 확인된다.
- `10F -> 6F`
  - 계약의 진실이 다시 허브 반응을 갱신한다.

## 보류 유지

- 직접 조우, 컷신, 보스전 페이즈 연출은 여전히 사용자 결정이 필요한 범위로 남긴다.
- 이번 증분은 잠긴 대표 방 연결 의미를 관리자 검증용 메모로 정리하는 범위까지만 다룬다.
