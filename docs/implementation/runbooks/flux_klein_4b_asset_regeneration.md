---
title: FLUX.2 klein 4B 에셋 재생성 런북
doc_type: runbook
status: active
section: implementation
owner: art_pipeline
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/target_doc_structure.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/art_direction.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/catalogs/ai_style_board.md
update_when:
  - handoff_changed
  - workflow_changed
  - vendor_changed
  - pricing_changed
last_updated: 2026-04-08
last_verified: 2026-04-08
---

# FLUX.2 klein 4B 에셋 재생성 런북

상태: 사용 준비  
최종 갱신: 2026-04-06  
섹션: 자산 파이프라인

## 목적

이 문서는 Dungeon Mage의 기능 구현과 placeholder asset 연결이 끝난 뒤, `FLUX.2 klein 4B` 하나만 사용해 전체 게임 asset를 다시 생성할 때의 공통 절차를 고정한다.

이번 런북이 잠그는 핵심은 아래와 같다.

- 첫 번째 전면 재생성 파동은 `FLUX.2 klein 4B` 단일 모델만 사용한다.
- 대상 범위는 `스킬`, `캐릭터`, `몬스터`, `배경`, `UI` 전부다.
- 생성 단계는 `기존 runtime 계약을 보존한 리스킨`이어야 하며, 구현 계약을 흔드는 재설계 단계가 아니다.
- `프레임 수`, `캔버스 크기`, `pivot/origin`, `빈 padding`, `파일명`, `atlas 위치`는 AI가 바꾸지 못하는 고정 계약으로 본다.
- 스타일 방향의 source of truth는 [art_direction.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/art_direction.md)다.
- 카테고리별 reference board와 prompt anchor는 [ai_style_board.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/catalogs/ai_style_board.md)를 따른다.

## 왜 `klein 4B`를 먼저 쓰는가

| 항목 | 기준 |
| --- | --- |
| 공식 포지션 | `real-time apps`, `high volume` |
| 속도 | `sub-second` |
| 품질 등급 | `High` |
| 로컬 실행 | 가능, 약 `13GB VRAM`, `Apache 2.0` |
| API 편집 비용 | `from $0.014/image` |
| 멀티 레퍼런스 | 최대 `4장` |
| 이번 프로젝트에서의 의미 | 전체 에셋군을 한 번에 다시 덮는 첫 파동의 기본값으로 가장 싸고 빠르다 |

이 프로젝트는 최종 마감 전에 `placeholder -> art style 통일` 단계를 한 번 크게 거칠 계획이다. 따라서 첫 파동은 `최고품질 1회`보다 `싼 비용으로 많은 family를 잠그는 것`이 더 중요하다.

## 적용 시작 조건

아래 조건을 모두 만족하기 전에는 이 런북을 실행하지 않는다.

- 모든 핵심 플레이 루프와 UI 흐름이 구현 완료 상태다.
- 기존 free asset 기반 runtime 연결이 테스트 가능 상태다.
- asset 폴더 구조와 파일명 규칙이 잠겨 있다.
- 각 family의 `frame_count`, `frame_size`, `pivot`, `anchor`, `loop 여부`가 문서 또는 코드에서 확인 가능하다.
- 적어도 1개의 `아트 방향 레퍼런스 보드`가 준비되어 있다.
- 카테고리별 승인용 샘플 1종을 먼저 만든 뒤 나머지 batch로 확장한다.

## 이 단계에서 하지 않는 일

- 기능 구현과 asset 재생성을 같은 턴에 동시에 밀어 넣지 않는다.
- `전체 스프라이트시트 1장`을 AI에게 맡겨 한 번에 완성하려 하지 않는다.
- runtime이 읽는 `frame_count`나 `state 분리`를 생성 단계에서 바꾸지 않는다.
- 타일 정합, UI layout, 히트박스 기준이 흔들리는 수정은 허용하지 않는다.
- 품질이 아쉬워도 첫 파동에서는 모델을 family마다 바꾸지 않는다.

## Dungeon Mage 기본 운영 잠금

### 1. 생성 단위는 작게 자른다

이 프로젝트의 기본 단위는 `whole sheet`가 아니라 `작은 strip` 또는 `상태 단위 묶음`이다.

| 카테고리 | 기본 생성 단위 | 기본 권장 크기 | 비고 |
| --- | --- | --- | --- |
| 스킬 VFX | `2~4프레임 strip`, 또는 `attack / loop / hit / end` family별 소단위 | `256~512` 단위 | 전체 시트 1장보다 split family가 안전하다 |
| 플레이어 캐릭터 | `idle`, `run`, `attack`, `hurt` 같은 `상태별 strip` | 상태별 기존 캔버스 유지 | 여러 상태를 한 장에 섞지 않는다 |
| 몬스터 | 몬스터 1종의 상태별 strip | 상태별 기존 캔버스 유지 | `idle/run/attack/hurt/death`를 분리한다 |
| 배경 | 패럴랙스 레이어 1장 또는 타일 family 소단위 | `512~1024` 청크 | 타일형 배경은 seam 검증 없이 바로 반영하지 않는다 |
| UI | 아이콘 family, 패널 frame, border 조각 | 아이콘은 소형 batch, 패널은 조각 단위 | 화면 전체 UI를 한 장으로 생성하지 않는다 |

### 2. 입력 이미지는 runtime 계약에 먼저 맞춘다

`FLUX.2`는 입력 크기를 기본적으로 맞추되 `16의 배수`에 맞게 잘라낼 수 있다. 픽셀 정합이 중요한 게임 asset는 생성 전에 입력을 먼저 정규화해야 한다.

- 입력 이미지는 `4MP 이하`, 가능하면 `2MP 이하`로 맞춘다.
- 너비와 높이는 반드시 `16의 배수`로 맞춘다.
- 빈 투명 padding이 중요하면 AI에 넣기 전에 이미 캔버스를 최종 상태로 맞춘다.
- `png`를 기본 출력 형식으로 사용한다.
- 출력 결과는 즉시 내려받는다. BFL signed URL은 짧게 유지되므로 후처리 스크립트가 바로 저장해야 한다.

작은 sprite strip 추가 규칙:

- frame 안에서 실제 캐릭터나 몬스터가 너무 작다면, 원본 strip 1장만 그대로 보내지 않는다.
- 먼저 `nearest-neighbor 4x strip`을 만든다.
- 대표 frame 1장을 골라 `전신이 모두 보이는 focus crop`을 만들고 `보통 8x`까지 확대한다.
- 확대 구조 ref도 `16의 배수` 캔버스로 다시 패딩한다.
- 이 구조 ref는 `새 디자인`이 아니라 `원본 anatomy / gaze / lower-body / robe hem`을 더 크게 보여주는 용도다.
- 플레이어 캐릭터 idle처럼 pose drift가 치명적인 경우에는 이 단계를 기본값으로 본다.

### 3. 생성보다 후처리가 더 중요하다

`img2img` 단계는 스타일을 덮는 단계고, 실제 게임 반영은 후처리 단계가 잠근다.

후처리 스크립트가 최소한 아래를 강제해야 한다.

- 파일명 원복
- 캔버스 크기 원복
- frame 순서 보존
- alpha 정리
- pivot 기준점 보존
- atlas slice 위치 보존

## 프롬프트 작성 규칙

`klein 4B`는 `prompt upsampling`이 없으므로 짧은 키워드 나열보다 서술형 프롬프트가 더 중요하다.

### 공통 규칙

- 모든 프롬프트는 먼저 [art_direction.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/art_direction.md)에서 잠긴 항목을 추출한 뒤 작성한다.
- 임의 감각으로 새 설정을 추가한 ad-hoc 프롬프트를 직접 API에 보내지 않는다.
- 플레이어 캐릭터 프롬프트는 반드시 `주인공 시각 잠금` 섹션을 함께 읽고, 잠긴 외형/의상/무기 값만 반영한다.
- 가장 중요한 요소를 앞에 둔다.
- `무엇을 유지할지`를 먼저 적고, `무엇을 바꿀지`를 뒤에 적는다.
- 스타일, 조명, 분위기, 색 팔레트를 구체적으로 적는다.
- 색상은 가능하면 `hex code`까지 적는다.
- 레퍼런스 이미지를 쓸 때는 `image 1`, `image 2`의 역할을 명확히 적는다.
- `이전보다 더`, `전보다 덜`, `이전 결과처럼` 같은 상대 표현은 피한다.
- 프롬프트는 그 요청 한 번만 읽어도 이해되는 `자급자족형 절대 기준`으로 쓴다.
- seed를 고정한 상태에서 프롬프트 한 축만 바꿔가며 튜닝한다.

### Dungeon Mage 공통 프롬프트 골격

```text
Keep the exact silhouette, frame timing, empty padding, center alignment, and motion direction from image 1.
Restyle this asset for Dungeon Mage as a dark fantasy pixel-friendly game asset.
Category: [skill effect / player animation / monster animation / background chunk / UI icon].
Subject: [what this asset is].
Action: [what happens in this frame or strip].
Style: [final art direction].
Color palette: [hex colors].
Lighting and mood: [lighting, temperature, tone].
Background handling: transparent background / isolated subject / keep current framing.
Important: preserve readability at gameplay scale and do not change the current pose or composition.
```

### 카테고리별 추가 문구

- 스킬 VFX: `Preserve the attack read, hit read, and empty space needed for gameplay clarity.`
- 캐릭터: `Preserve body proportions, facing direction, weapon silhouette, and foot placement.`
- 몬스터: `Preserve the hitbox silhouette, attack wind-up read, and weak-point readability.`
- 배경: `Preserve tile seam safety and parallax layer readability.`
- UI: `Preserve icon legibility at small sizes and keep clean negative space for game HUD use.`

### 아트 컨셉 기반 프롬프트 조립 절차

고해상도 도트 그래픽 인게임 에셋을 만들 때는 FLUX에게 저해상도 픽셀아트를 직접 요구하지 않는다.
기본은 `고해상도 working image`를 생성하고, 그 결과를 `runtime normalization`으로 내릴 때 도트감과 픽셀 밀도를 결정하는 방식이다.
다만 사용자가 `직접 적용`을 원하면, 생성 결과를 runtime 스트립 규격 그대로 유지하고 후처리 downscale은 생략한다.
즉, 생성 단계의 목표는 `선명한 고해상도 원본`이거나 `고해상도 runtime strip`이며, 최종 도트 룩은 필요할 때만 후처리 단계에서 맞춘다.

모든 이미지 생성 API 요청은 아래 순서로 조립한다.

1. [art_direction.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/art_direction.md)에서 현재 카테고리에 해당하는 잠금값을 추출한다.
2. [ai_style_board.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/catalogs/ai_style_board.md)의 board와 prompt anchor를 붙인다.
3. `image 1~4` 역할을 선언한다.
4. runtime 계약 유지 문장을 프롬프트 첫 문장에 둔다.
5. 고해상도 working image가 필요한 경우, 프롬프트에 `high-resolution working sprite`, `not low-resolution retro pixel art`, `later runtime downscale` 같은 문장을 포함한다.
6. 직접 적용이 필요한 경우, 프롬프트에 `direct-use runtime strip`, `keep the final runtime strip readable without downscaling` 같은 문장을 포함한다.
7. 마지막에 `현재 문서에 없는 새 설정은 추가하지 않는다`는 운영 원칙을 검토한다.

플레이어 캐릭터의 경우 최소 추출 항목:

- 금발, 단정하지만 약간 뾰족한 단발
- 잘생기고 정돈된 인상, 약간 날카로운 눈매, 오똑한 코
- 마법학교 학생, 졸업 시험을 위해 미궁에 들어온 학생 마법사
- 천/로브 중심의 야외 활동형 교복
- 흰색+금색 이너, 청색 아우터, 회색 로브, 금색 학교 로고
- 로브와 어울리는 가죽 신발, 장갑 없음, 청색 바지
- 고풍스러운 목재 완드, 황금색 마석, 소량의 금색 장식
- 뒤로 넘긴 가죽 크로스백
- 현재 runtime 비율, 애니메이션, 실루엣 유지
- 다만 최종 도트감은 필요할 때 runtime normalization 단계에서 맞춘다
- 직접 적용 루트라면 runtime strip 자체의 고해상도 가독성을 우선한다

플레이어 캐릭터 API 요청 전 체크:

- 프롬프트가 `현재 runtime 비율을 유지`한다고 명시했는가
- 프롬프트가 `의상/얼굴/신발/무기만 변경` 의도를 반영하는가
- 프롬프트가 `high-resolution working image`를 생성하라고 명시하는가
- 프롬프트가 `not low-resolution retro pixel art` 또는 이에 준하는 문장을 포함하는가
- 직접 적용이 필요한 경우 프롬프트가 `runtime strip` 유지와 `downscale 생략`을 명시하는가
- 프롬프트가 `학생 마법사` 판타지를 포함하는가
- 프롬프트가 `기사`, `다크 히어로`, `긴 스태프` 같은 금지 방향을 피하는가
- 작은 sprite strip이라면 `원본 확대 strip`과 `대표 frame focus 구조 ref`를 같이 준비했는가

### 멀티 레퍼런스 규칙

`klein 4B`는 최대 `4장` 레퍼런스를 지원한다. 이 프로젝트에서는 아래 역할로 고정한다.

- `image 1`: 현재 runtime asset. 가장 중요한 구조 기준.
- `image 2`: 아트 스타일 기준 이미지.
- `image 3`: palette 또는 재질 기준 이미지.
- `image 4`: 동일 family 내부의 다른 승인 샘플. 일관성 유지용.

고해상도 working image 전용 작업에서는 `image 1`과 `image 2`를 구조와 포즈 잠금에 집중시키고, 결과를 `apply_runtime_contract.py` 또는 `normalize_strip_to_runtime.py`로 내려서 128x128 혹은 원본 runtime 계약에 맞춘다.

직접 적용 작업에서는 `image 1`과 `image 2`를 구조 잠금에 집중시키되, 생성 결과를 그대로 runtime strip에 덮어쓰고 downscale 단계는 생략한다. 이 경우 최종 산출물은 runtime 스트립 규격을 유지하면서도 더 고해상도처럼 보이는 clean sprite여야 한다.

tiny sprite strip에서는 아래 변형을 기본값으로 허용한다.

- `image 1`: 원본 runtime strip의 nearest-neighbor 확대본
- `image 2`: 같은 원본에서 뽑은 대표 frame 전신 focus 구조 ref
- `image 3`: 외부 style / mood / 재질 ref
- `image 4`: 승인된 내부 keyframe 또는 승인된 sibling asset

중요:

- `image 1`과 `image 2`는 구조와 pose를 잠그는 용도다.
- tiny sprite character 작업에서는 `image 1`과 `image 2`로부터 `의상 종류`, `망토/로브 해석`, `기존 의상 색상`, `헤어 컬러`를 가져오지 않는다.
- 특히 원본 placeholder가 망토처럼 보여도, 새 아트 컨셉이 긴 로브라면 `pose만 유지하고 의상 해석은 버린다`.

### tiny sprite 캐릭터 2단계 잠금

플레이어처럼 `포즈가 자주 틀어지는 tiny sprite 캐릭터`는 아래 2단계를 기본값으로 둔다.

1. `pose-lock pass`
2. `design-finish pass`

`pose-lock pass`에서는:

- `image 1`, `image 2`를 절대 구조 기준으로 둔다.
- body-facing direction, lean, head angle, hand placement, leg spacing 같은 `포즈 정보`만 통과 기준으로 본다.
- 외부 디자인 레퍼런스는 쓰더라도 `held item`, `casting action`, `illustration pose` 같은 오염 요소를 강하게 금지한다.

`design-finish pass`에서는:

- 승인된 `pose-lock result`를 `image 4`로 넣는다.
- 그 다음에만 공식 일러스트 / 재질 레퍼런스를 다시 얹는다.
- 즉, `구조는 stage 1`, `디자인은 stage 2`로 분리한다.

프롬프트에는 역할을 직접 적는다.

```text
Use image 1 as the exact composition and motion reference.
Use image 2 for overall art style.
Use image 3 for the gold-white palette and emissive glow treatment.
Use image 4 only to keep consistency with the already approved holy effect family.
```

캐릭터 keyframe이나 idle strip에는 아래처럼 더 강하게 쓰는 편이 좋다.

```text
Use image 1 and image 2 only for pose and body-structure facts.
Keep pose, facing direction, eye direction, head angle, shoulder line, hand placement, pelvis position, leg spacing, knee height, and calf width from the source.
Do not copy the source outfit, source cloth silhouette, cape interpretation, robe type, cloth colors, shoes, or hair color.
Do not preserve trailing cloth or backward-flaring outerwear from the source image.
```

## API와 로컬 사용 방식

## 런타임 규격 잠금

본체/이펙트/기타 strip asset은 `AI 생성용 작업 크기`와 `게임 납품 크기`를 분리한다.

- 생성 단계에서는 `512x512` 같은 더 큰 작업 단위를 허용한다.
- 최종 납품 단계에서는 반드시 `원본 source image`가 가진 `frame_width`, `frame_height`, `frame_count`, `strip orientation`에 맞춰 복원한다.
- 플레이어처럼 고정 atlas 기반 asset은 기존 scene 계약까지 유지한다.
- 최종 strip는 기존 `frame_count`, `frame order`, `empty padding`, `feet baseline`, `body center`, `visible silhouette envelope`를 유지한다.

공용 동적 정규화는 아래 repo-local wrapper를 기본으로 사용한다.

- `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tools/flux_klein/apply_runtime_contract.py`

이 wrapper는 아래 정보를 `원본 source image` 또는 `manifest`에서 동적으로 읽는다.

- `frame_width`
- `frame_height`
- `frame_count`
- `source_strip`

예시:

```bash
python3 /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tools/flux_klein/apply_runtime_contract.py \
  --original-strip /abs/source_strip.png \
  --frame-count 10 \
  --generated-strip /abs/generated_strip.png \
  --output /abs/generated_runtime.png
```

animation workdir를 이미 만들었다면 `manifest`를 그대로 넣는 편이 더 안전하다.

```bash
python3 /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tools/flux_klein/apply_runtime_contract.py \
  --manifest /abs/workdir_manifest.json \
  --generated-strip /abs/generated_strip.png \
  --output /abs/generated_runtime.png
```

또는 chunk/frame 결과를 먼저 검토하고, frame 폴더를 직접 넣을 수도 있다.

```bash
python3 /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tools/flux_klein/apply_runtime_contract.py \
  --manifest /abs/workdir_manifest.json \
  --generated-frame-dir /abs/generated_frames \
  --output /abs/generated_runtime.png
```

플레이어 본체처럼 scene 계약까지 같이 보는 경우엔 아래 spec/wrapper를 추가로 참고한다.

- `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tools/flux_klein/specs/player_runtime_spec.json`
- `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tools/flux_klein/apply_player_runtime_contract.py`

### 기본 선택

- 빠른 튜닝과 브라우저 확인은 `Playground`
- Codex 자동화와 batch 저장은 `API`
- 완전 무과금 반복 실험은 `로컬 4B`

공식 문서 기준 `API`와 `Playground`는 같은 가격이다. 따라서 사람이 눈으로 몇 장만 비교할 때는 Playground를 써도 되지만, 실제 프로젝트 반영 파이프라인은 `API 또는 로컬 스크립트`를 기준으로 잡는다.

### API 기본 파라미터

- endpoint: `POST /v1/flux-2-klein-4b`
- 필수: `prompt`, `input_image`
- 선택: `input_image_2` ~ `input_image_4`, `width`, `height`, `seed`, `output_format`
- 기본 출력은 `png`

### 최소 요청 예시

```bash
curl -X POST "https://api.bfl.ai/v1/flux-2-klein-4b" \
  -H "x-key: ${BFL_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Keep the exact silhouette, frame timing, empty padding, and center alignment from image 1. Restyle this skill effect as a dark fantasy holy barrier activation effect for Dungeon Mage. Transparent background, gold-white palette #fff5be #ffe27a #fffdf2, readable at gameplay scale, preserve the current pose and composition.",
    "input_image": "https://example.com/holy_guard_activation_frame.png",
    "input_image_2": "https://example.com/style_board.png",
    "seed": 42,
    "output_format": "png"
  }'
```

### 결과 회수 규칙

- 응답의 `polling_url`을 저장한다.
- 큐가 느릴 때는 `submit-only -> polling_url / job id / submit metadata 저장 -> 나중에 회수`를 기본 운영으로 본다.
- 결과 URL이 오면 즉시 다운로드한다.
- 결과는 `tmp/`에 먼저 저장한 뒤 후처리 검증을 거쳐 실제 asset 경로로 복사한다.
- 비용 추적은 응답의 `cost`, `input_mp`, `output_mp`를 로그에 남긴다.

### 느린 큐 대응 기본값

`klein 4B` job이 오래 `Pending`이면, 같은 턴 안에서 폴링을 계속 끌고 가지 않는다.

- 기본값: `submit-only`
- 저장 항목: `request body`, `submit metadata`, `polling_url`, `job id`
- 후속 회수: 기존 job만 폴링해서 결과를 받는다.
- webhook endpoint가 준비된 경우에는 `webhook_url + submit-only` 조합을 허용한다.
- 같은 prompt / 같은 input으로 새 job을 반복 제출하기 전에, 기존 job이 실제로 stuck인지 먼저 확인한다.

이 프로젝트에서는 아래 흐름을 권장한다.

1. request body를 저장한다.
2. `submit-only`로 job을 만든다.
3. submit metadata를 파일로 저장한다.
4. 나중에 같은 job을 회수한다.
5. 결과 파일이 준비되면 후처리와 구조 검증을 한다.

## 카테고리별 권장 실행 순서

첫 전면 재생성 파동은 아래 순서로 진행한다.

1. 스킬 VFX family
2. 플레이어 캐릭터
3. 몬스터
4. UI 아이콘과 패널 skin
5. 배경과 환경 장식

이 순서를 쓰는 이유는 `전투 판독`이 가장 빨리 체감되고, 캐릭터/몬스터에서 스타일 기준이 잠기면 UI와 배경도 같은 방향으로 맞추기 쉬워지기 때문이다.

## 1 family당 실행 절차

### Step 1. 계약 고정

- 기존 asset에서 `frame_count`, `canvas`, `pivot`, `loop 여부`를 적는다.
- 현재 runtime 스크린샷 1장을 남긴다.
- [ai_style_board.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/catalogs/ai_style_board.md)의 해당 family board를 연결한다.

### Step 2. 샘플 1종 생성

- family 대표 frame 또는 대표 strip 1개만 먼저 생성한다.
- seed를 고정한다.
- 프롬프트는 1개 축만 바꿔가며 2~3회 이내로 조정한다.

캐릭터/몬스터 strip 추가 규칙:

- `6프레임`을 넘는 상태 strip은 바로 전체 redesign에 들어가지 않는다.
- 먼저 대표 keyframe 1장을 승인한다.
- 그 승인 keyframe을 이후 strip 요청의 내부 일관성 레퍼런스로 재사용한다.
- 여전히 drift가 크면 `2~4프레임 chunk`로 나눠 생성한다.
- 작업 폴더는 `frame 분리 -> keyframe -> chunk strip -> manifest` 구조로 먼저 준비한다.

### Step 3. family 확장

- 샘플이 통과하면 같은 prompt 골격으로 같은 family의 나머지 strip을 생성한다.
- 이미 승인된 샘플은 `image 4` 일관성 레퍼런스로 재사용한다.

### Step 4. 후처리

- 자동 crop / pad / alpha cleanup
- 파일명 원복
- frame index 순서 확인
- 필요하면 palette 정리
- 생성 결과가 원본 bbox를 크게 벗어나면 `runtime silhouette normalize`를 먼저 거친다.
- chunk별 결과는 먼저 frame 단위로 검토한 뒤 최종 runtime strip로 다시 합친다.

정규화를 써도 되는 경우:

- 디자인은 마음에 들지만 위치나 크기만 약간 흔들린 경우
- center drift와 bottom drift가 작고, edge touch가 없는 경우

정규화로 해결하지 말고 바로 reject해야 하는 경우:

- 여러 frame에서 캐릭터가 frame edge를 치는 경우
- silhouette area가 원본보다 과도하게 커진 경우
- 좌우 중심이 크게 흔들리는 경우
- design lock과 animation preservation이 동시에 실패한 경우

### Step 5. 엔진 검증

- 실제 scene에서 재생
- 좌우 반전 시 아티팩트 확인
- hit read / telegraph read / UI legibility 확인
- strip 구조 분석에서 `center drift`, `bottom drift`, `silhouette inflation`, `edge touch`가 허용 범위를 넘으면 바로 reject한다.

## 승인 기준

아래를 모두 만족하면 해당 family를 승인한다.

- 기존 runtime 계약과 같은 수의 프레임을 유지한다.
- 화면 흔들림 없이 재생된다.
- 전투 판독성이 placeholder보다 나쁘지 않다.
- 동일 school 또는 동일 UI family와 스타일 충돌이 없다.
- 배경과 UI는 실제 게임 스케일에서 글자/아이콘 가독성이 유지된다.
- QA 스크린샷과 실제 플레이 화면에서 톤이 과하게 튀지 않는다.

## 실패 처리 규칙

- 1 family가 `3회` 연속 실패하면 그 family는 placeholder를 유지하고 다음 family로 넘어간다.
- 실패 원인이 `구조 붕괴`면 prompt 수정이 아니라 입력 정규화부터 다시 본다.
- 실패 원인이 `색/분위기 drift`면 style reference와 hex palette를 강화한다.
- 실패 원인이 `가독성 부족`이면 frame 수를 늘리지 말고 밝기 대비와 silhouette를 먼저 수정한다.

## 프로젝트별 주의점

### 스킬 VFX

- `attack`, `hit`, `loop`, `end`는 같은 family라도 한 번에 다 만들지 말고 분리한다.
- 통합 sheet보다 split family가 runtime hook과 더 잘 맞는다.
- alpha가 너무 두꺼워지면 실제 판독성이 급격히 나빠진다.

### 캐릭터와 몬스터

- 같은 캐릭터의 여러 상태를 한 프롬프트에서 동시에 바꾸려 하지 않는다.
- foot placement와 weapon silhouette가 어긋나면 재생성보다 보류가 낫다.
- `idle`과 `run`이 승인된 뒤에 `attack/hurt/death`로 확장한다.

### 배경

- 타일형 배경은 먼저 작은 반복 청크로 seam을 검증한다.
- 패럴랙스 레이어는 화면 전체를 새로 그리기보다 레이어별 mood 통일이 우선이다.

### UI

- UI는 panel art와 icon art를 분리한다.
- 아이콘은 실제 크기로 축소해서 읽히지 않으면 바로 탈락시킨다.
- 텍스트가 들어가는 UI는 `klein 4B`보다 후처리로 직접 정리하는 쪽을 기본값으로 둔다.

## 현재 가정

- 첫 전면 재생성 시점까지는 지금의 free/placeholder asset가 계속 source image 역할을 한다.
- 이후 더 높은 품질 모델을 쓸 수 있어도, 첫 파동의 source of truth는 이 런북이다.
- 가격과 API 파라미터는 `2026-04-06` 조사 기준이다. 벤더 정책이 바뀌면 이 문서를 먼저 갱신한다.

## 외부 참고 문서

- [BFL `FLUX.2 Model Variants`](https://help.bfl.ai/articles/6665431086-flux-2-model-variants)
- [BFL `FLUX.2 [klein] - Fast Generation Guide`](https://help.bfl.ai/articles/8642316687-flux-2-klein-fast-generation-guide)
- [BFL `FLUX.2 Image Editing`](https://docs.bfl.ai/flux_2/flux2_image_editing)
- [BFL `FLUX.2 Prompting Guide`](https://docs.bfl.ai/guides/prompting_guide_flux2)
- [BFL `Pricing Overview`](https://docs.bfl.ai/quick_start/pricing)
