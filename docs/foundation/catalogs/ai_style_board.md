---
title: AI 스타일 보드
doc_type: catalog
status: active
section: foundation
owner: design
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/art_direction.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/runbooks/flux_klein_4b_asset_regeneration.md
update_when:
  - art_direction_changed
  - prompt_bundle_changed
  - reference_changed
  - vendor_changed
last_updated: 2026-04-08
last_verified: 2026-04-08
---

# AI 스타일 보드

상태: 사용 중  
최종 갱신: 2026-04-06  
섹션: 기초 설정

## 목적

이 문서는 [art_direction.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/art_direction.md)의 비주얼 규칙을 실제 `AI img2img` 입력 단위로 변환한 카탈로그다.

이 문서가 담당하는 것은 아래다.

- 카테고리별 `reference board` 목록
- 각 board에서 어떤 이미지를 모아야 하는지
- 프롬프트에 바로 넣을 수 있는 핵심 키워드
- 카테고리별 금지 방향
- 첫 승인에 써야 할 기준 pair

이 문서는 `규칙 문서`가 아니라 `실무용 reference board 카탈로그`다. 최종 기준은 항상 [art_direction.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/art_direction.md)를 먼저 따른다.

## 사용 순서

1. [art_direction.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/art_direction.md)로 전체 규칙을 확인한다.
2. 이 문서에서 해당 카테고리 board를 고른다.
3. [flux_klein_4b_asset_regeneration.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/runbooks/flux_klein_4b_asset_regeneration.md)의 절차대로 `image 1~4`를 채운다.
4. board별 프롬프트 anchor와 금지 조건을 붙여 생성한다.

## 공통 슬롯 규칙

모든 board는 아래 `4-slot` 구조를 기본값으로 쓴다.

| 슬롯 | 역할 | 기본 내용 |
| --- | --- | --- |
| `image 1` | 구조 기준 | 현재 runtime asset 또는 placeholder asset |
| `image 2` | 외부 무드 기준 | 가장 강하게 참고할 레퍼런스 무드 이미지 |
| `image 3` | palette / 재질 기준 | 색감, 광원, 재질 참고 이미지 |
| `image 4` | 내부 일관성 기준 | 이미 승인된 Dungeon Mage 내부 asset |

공통 규칙:

- `image 1`은 항상 구조와 포즈를 가장 강하게 고정한다.
- `image 2`는 mood와 실루엣 방향을 고정한다.
- `image 3`는 색과 재질을 고정한다.
- `image 4`는 같은 게임 내부 일관성을 맞출 때만 쓴다.

작은 sprite strip 예외 규칙:

- 실제 캐릭터나 몬스터가 frame 안에서 너무 작으면 `image 2`를 외부 mood가 아니라 `같은 원본에서 뽑은 확대 구조 ref`로 쓸 수 있다.
- 이 경우 외부 mood/palette ref는 `image 3`과 `image 4`로 뒤로 민다.
- 구조 보강용 `image 2`는 `새 스타일`이 아니라 `원본 anatomy / gaze / robe hem / lower-body read` 고정용으로만 사용한다.

## board 목록

| board_id | 대상 | 주 레퍼런스 축 | 첫 사용 시점 |
| --- | --- | --- | --- |
| `monster_exploration_board` | `4~6층` 일반/엘리트 몬스터 | `CQ 75 / Maple 25` | 초반 몬스터 리스킨 |
| `monster_corruption_board` | `7~10층` 타락/악마 계열 몬스터 | `CQ 65 / Maple 35` | 후반 몬스터 리스킨 |
| `background_exploration_board` | `4~6층` 전투방, 복도, 허브 | `Maple 70 / CQ 30` | 초반 배경 리스킨 |
| `background_corruption_board` | `7~10층` 의식 공간, 전투방, 보스방 | `Maple 60 / CQ 40` | 후반 배경 리스킨 |
| `skill_effect_board` | 전 school 공통 스킬 이펙트 | `Maple 80 / CQ 20` | 모든 VFX 리스킨 |
| `character_party_board` | 플레이어와 동료 캐릭터 | `CQ 55 / Maple 45` | 캐릭터 리스킨 |
| `ui_clean_fantasy_board` | HUD, 패널, 아이콘 | `Maple 60 / CQ 40` | UI 리스킨 |
| `approval_pair_late_hub_boss_board` | 첫 전체 승인용 장면 pair | `Late-game composite` | 스타일 승인 |

## board 상세

### `monster_exploration_board`

**용도**

- `4~6층` 일반 몬스터
- `4~6층` 엘리트 몬스터
- 탐험형 판타지 미궁 구간의 중소형 적

**핵심 인상**

- 귀엽지만 위협적
- 짧고 강한 실루엣
- 유치하지 않은 chibi fantasy
- warm stone brown 배경 위에서 잘 읽히는 로컬 컬러

**반드시 보여야 하는 것**

- 얼굴, 머리, 뿔, 날개, 무기 중 최소 1개 이상이 즉시 읽힌다
- 공격 전조가 실루엣만으로도 구분된다
- 주색 4~5개 안에서 속성과 역할이 보인다

**피해야 하는 것**

- 장난감 같은 과도한 SD
- 고어
- 복잡한 금속 장식
- 배경색과 섞여 사라지는 저대비 채색

**prompt anchor**

```text
Compact readable fantasy monster, cute but threatening, not childish, strong silhouette, simple readable face, local colors separated clearly, dark outline silhouette, designed for a side-scrolling action RPG over a subdued warm stone ruin background.
```

**추천 reference 수집**

- 외부 무드 이미지: 읽기 쉬운 chibi 몬스터, 전투 전조가 보이는 적 2장
- palette / 재질 이미지: warm stone brown 배경 위에서 잘 뜨는 몬스터 1장
- 내부 일관성 이미지: 이미 승인된 초반 몬스터 1장

### `monster_corruption_board`

**용도**

- `7~10층` 악마형 적
- 타락한 엘리트
- 심층부 보스 하수인

**핵심 인상**

- 악마 침식의 공포
- 귀엽지만 위험한 판타지 악마
- 불꽃과 재가 섞인 파열감
- 붕괴된 유적 위에서 또렷한 위험성

**반드시 보여야 하는 것**

- 갈라진 균열, 재, 내부 화염 누출 중 하나 이상
- 타락/악마 계열의 위협감
- `ashen red-brown` 배경 위에서도 분리되는 색

**피해야 하는 것**

- 점액질 오염
- 생고기 같은 고어
- 지나치게 현실적인 악마 해부학
- 순흑색 덩어리처럼 뭉개지는 채색

**prompt anchor**

```text
Corrupted fantasy demon monster, cute but dangerous, ash and fire bursting through cracked surfaces, demonic corruption without gore, readable silhouette for side-scrolling combat, designed to stand out against an ashen red-brown ruined labyrinth background.
```

**추천 reference 수집**

- 외부 무드 이미지: 귀여운 비율이지만 불길한 적 2장
- palette / 재질 이미지: ash, ember, cracked stone, demonic fire 1~2장
- 내부 일관성 이미지: 후반 승인 몬스터 또는 보스 하수인 1장

### `background_exploration_board`

**용도**

- `4~6층` 복도
- `4~6층` 일반 전투방
- `4~6층` 허브/안전지대

**핵심 인상**

- 탐험형 판타지 미궁
- 구조 변화가 먼저 보이는 유적
- 성역 같은 안전지대와 봉인의 비참함 공존
- 레이어가 풍부하지만 전투를 가리지 않음

**반드시 보여야 하는 것**

- 전경/중경/후경 구분
- warm stone brown 기반
- 탐험과 발견의 감정
- 전투 오브젝트가 더 밝게 떠 보이는 값 구조

**피해야 하는 것**

- 지나친 장식 밀도
- 평면적인 벽지 같은 배경
- 채도가 너무 높은 놀이공원 느낌

**prompt anchor**

```text
Layered 2D fantasy labyrinth background for exploration floors, warm stone brown ruins, magical accents, sanctuary-like but bittersweet safe zone energy, rich parallax depth, subdued enough for gameplay readability, not overly cute or toy-like.
```

**추천 reference 수집**

- 외부 무드 이미지: 밝은 판타지 유적 맵 2장
- palette / 재질 이미지: warm stone, gold light, teal accent, ancient brick 1~2장
- 내부 일관성 이미지: 승인된 초반 배경 타일 또는 방 1장

### `background_corruption_board`

**용도**

- `7~10층` 의식 공간
- `7~10층` 전투방
- `7~10층` 보스방

**핵심 인상**

- 붕괴된 유적
- 악마 침식의 공포
- 타락한 마력 누출
- 배경은 크게 어두워지지만 채도는 완전히 죽지 않음

**반드시 보여야 하는 것**

- `ashen red-brown` base
- 붕괴된 구조와 균열
- 악마성 flame / ash accent
- 플레이어, 적, 이펙트가 앞으로 나오도록 낮춘 배경 contrast

**피해야 하는 것**

- 검정 일색의 단조로운 어둠
- 배경이 너무 밝아 전투를 삼키는 것
- 단순 화염 지옥처럼만 보이는 것

**prompt anchor**

```text
Dark fantasy ruined labyrinth background, collapsed architecture, demonic corruption leaking through ritual scars, ashen red-brown base, ember and ash accents, heavy mood but still readable for side-scrolling combat, background intentionally subdued behind bright combat elements.
```

**추천 reference 수집**

- 외부 무드 이미지: 붕괴 유적, 의식 공간, 보스방 2~3장
- palette / 재질 이미지: ash, ember, burnt stone, demonic cracks 1~2장
- 내부 일관성 이미지: 승인된 후반 허브 또는 보스룸 1장

### `skill_effect_board`

**용도**

- 모든 school의 cast / main / hit / end 이펙트
- projectile / burst / field / aura / support 계열 공통 VFX

**핵심 인상**

- 메이플식 화려한 layered effect
- 거의 모든 스킬에서 속성 문양이 보임
- 어두운 층에서도 끝까지 선명한 광량
- 옵션으로 투명도 조절 가능

**공통 구조**

- 밝은 코어
- 속성 문양
- 잔광 또는 잔향
- hit와 end의 별도 read

**피해야 하는 것**

- 문양 없는 generic glow
- 너무 탁해서 배경에 묻히는 이펙트
- 반대로 화면 전체를 지워버리는 과한 bloom 인상

**prompt anchor**

```text
Flashy layered fantasy spell effect for a side-scrolling action RPG, bright core, readable elemental rune, clear cast-main-hit-end separation, vivid even in dark dungeon scenes, gameplay readability first, opacity can be reduced in settings without losing shape readability.
```

**school overlay catalog**

| school | 기본 색 | 문양 느낌 | 움직임 느낌 | 추가 키워드 |
| --- | --- | --- | --- | --- |
| `fire` | `gold-orange`, `ember red` | 원형 화염 문양, 균열형 flare | 위로 치솟는 폭발, 파열 | `bright gold-orange core`, `ember burst`, `heat ripple` |
| `ice` | `cyan-white` | 서리 꽃문양, crystalline ring | 짧은 냉기 폭발, 뻗는 결정 | `frost rune`, `cold crystal spokes`, `clean icy glow` |
| `lightning` | `yellow-white`, `blue-white` | 뾰족한 각형 glyph | 빠른 섬광, 분기 arc | `angular rune`, `sharp flash`, `chain spark` |
| `wind` | `mint`, `teal` | 소용돌이형 thin rune | 얇고 빠른 흐름, 회오리 | `spiral glyph`, `thin fast stream`, `clean gust trail` |
| `earth` | `sepia`, `stone brown` | 무거운 block rune | 묵직한 솟구침, 파편 충돌 | `stone sigil`, `heavy debris`, `ground burst` |
| `holy` | `gold-white` | 대칭형 seal, sanctum mandala | 정돈된 팽창, 보호막 | `clean holy seal`, `ordered light`, `blessing glow` |
| `dark` | `violet`, `indigo`, `black-red` | 깨진 eclipse rune | 수축 후 파열, 어두운 맥동 | `fractured rune`, `void pulse`, `corrupt flare` |
| `plant` | `green`, `leaf gold` | 뿌리/잎 문양 | 감기듯 뻗는 성장 | `root glyph`, `vine sweep`, `living bloom` |

### `character_party_board`

**용도**

- 플레이어
- 친구 A, 친구 B
- 주요 NPC 마법사 계열

**핵심 인상**

- 몬스터와 거의 같은 계열의 판타지 비율
- 현재 runtime 비율 유지
- 선하지만 더 날카로운 얼굴
- 천/로브 중심
- 몬스터보다 더 정돈된 인상
- 마법학교 학생이자 미궁 탐험자
- 금발의 정돈된 학생 마법사
- 더 따뜻한 golden-orange blond
- 슬림하지만 훈련된 마른 근육질
- 3등신에 가까운 compact heroic SD read
- 검은색에 가까운 매우 어두운 청색 아카데미 로브 우세 silhouette
- 긴 로브가 의상 read의 대부분을 차지함
- idle에서는 목 주변과 제한된 중심 opening을 제외하면 로브가 거의 닫혀 있음
- 원본 placeholder의 망토형 outer cloth는 참고하지 않고, 몸 구조만 유지함
- 소량의 gold trim, 학교 문장 패치, 구조적인 큰 겉깃
- 내부에는 로브와 같은 계열 조끼, 흰 셔츠, red tie
- 선한 인상 위에 `약간의 장난기`, `자기 확신`, `엘리트 생존자 같은 냉정함`이 얹힌 얼굴

**반드시 보여야 하는 것**

- 로브, 천, 망토, 머리카락이 작은 화면에서도 읽힘
- 너무 무거운 갑옷보다 마도학 판타지 실루엣
- 선하고 영리하지만 더 날카로운 인상
- 금발보다 약간 더 따뜻한 golden-orange blond, 반쯤 넘긴 단정한 단발 헤어, 층이 나뉜 샤프한 앞머리
- 너무 둥글지 않은 얼굴선, 더 덜 부푼 볼, 더 길고 더 날카로운 눈매, 절제된 입매
- 눈썹이 살아 있는 집중한 brow line
- 너무 웃지 않는 차분한 표정
- 아주 약한 비대칭 미소나 입꼬리 긴장감처럼 `장난기 섞인 자신감`
- 장난기와 냉정함이 동시에 있는 소년 주인공 인상
- 긴 almost-black deep blue robe가 전체 read를 주도하고, 적은 양의 gold trim과 작은 학교 문장 패치가 소속감을 준다
- 붉은 넥타이와 내부 조끼, 흰 셔츠는 가슴 중앙의 `얼굴 너비 이하`의 아주 좁은 vertical opening에서만 제한적으로 보인다
- 허리띠 없이 떨어지는 긴 로브 silhouette
- 긴 로브여도 전면 split 구조 덕분에 idle 상태에서 하반신과 신발 read가 유지된다
- 로브는 망토처럼 뒤로 날리지 않고 앞뒤를 감싸는 의복처럼 읽힌다
- 소매는 손목까지 감싸며 손목 끝단만 살짝 접혀 있고, 손목 보호대는 없다
- 하의는 로브와 같은 어두운 계열의 스트레이트 슬랙스, 신발은 단화형 구두로 읽힌다
- idle 상태에서는 프레임 간 방향 변화 없이 원본 대기 모션만 유지
- idle 상태에서는 원본과 같은 시선 처리와 바라보는 방향 유지
- 몸이 향하는 방향과 눈동자 방향이 항상 일치한다
- idle 상태에서도 원본처럼 골반, 다리, 신발, 로브 밑단이 계속 읽힘
- 원본 이미지에서는 `포즈 / 바라보는 방향 / 시선 방향 / 머리 각도 / 어깨선 / 손 위치 / 골반 위치 / 다리 간격 / 무릎 높이 / 종아리 폭`만 참고한다
- 원본 이미지의 의상 형태 해석, 로브 종류, 망토성, 헤어 색상, 기존 의상 색상은 참고하지 않는다
- 짧은 고풍 목재 완드와 금색 마석 팁
- idle 상태에서는 완드가 손에 보이지 않아도 된다

**피해야 하는 것**

- 지나치게 날카로운 다크 히어로 인상
- 금속 갑옷 위주의 기사풍
- 몬스터보다 과하게 복잡한 실루엣
- 현대 교복처럼만 보이는 비마도학 복장
- 긴 스태프나 대검처럼 읽히는 무기 실루엣
- 무겁고 벌크감 있는 체형
- 둥글고 아동형으로만 읽히는 얼굴
- 너무 큰 동그란 눈, 짧은 코, 동글동글한 볼살 위주의 cute read
- 귀여운 아이돌 소년처럼만 보이는 표정과 헤어
- 너무 순하고 멍한 표정
- 허리띠나 sash 때문에 허리선이 강하게 강조되는 로브
- 짧은 로브나 하프코트 길이 때문에 긴 학생 로브 판타지가 무너지는 것
- 내부 교복 레이어가 로브보다 더 크게 읽히는 구성
- 지나치게 현대적인 사복 교복처럼만 보이는 내층 구성
- 로브가 망토처럼 뒤로 크게 젖혀지거나 idle에서 펄럭이는 것
- 눈동자가 몸 방향과 다른 곳을 보는 것
- 금색 장식이 과해져 제복성보다 장신구성이 더 커지는 것
- 원본 이미지의 망토형 외피, 헤어 컬러, 기존 의상 팔레트를 그대로 끌고 오는 것
- 특정 유명 소년 주인공의 얼굴 문양, 정확한 헤어 외곽, 세계관 소품을 그대로 옮긴 read
- 밝은 장난꾸러기 표정으로만 기울어져 긴장감이 사라지는 것
- 피투성이 전투 일러스트 같은 과한 상처/광기 무드를 기본 얼굴 인상으로 가져오는 것
- idle 상태에서 몸이 회전하거나 빙글빙글 도는 모션
- idle 상태에서 로브 여밈이 프레임마다 크게 달라지는 것
- idle 상태에서 시선이나 얼굴 방향이 흔들리는 것
- idle 상태에서 하반신이 사라지거나 로브 아래로 묻히는 것

**prompt anchor**

```text
Fantasy mage party character for a side-scrolling action RPG, preserve the original source image only for pose and body-structure facts: pose, exact body-facing direction, eye direction, head angle, shoulder line, hand placement, pelvis position, leg spacing, knee height, calf width, and frame placement. Never mirror the pose, never flip the body-facing direction, and never reinterpret a right-facing idle pose as left-facing. Rebuild the character as a compact 3-head SD in-game sprite rather than a tall illustration. Do not copy the original outfit, source cloth silhouette, cape interpretation, robe design, cloth colors, hair color, or any existing costume styling from the source image. Same visual family as the monsters but cleaner and more noble, handsome golden-orange blond academy student mage, lean athletic build, lighter cheek volume, sharper jaw, longer sharper eye line, defined brow line, restrained mouth shape, and a slight mischievous confidence without becoming goofy, half-swept layered short hair with sharper strand separation and angled bangs near the eyes, ruby-red irises, long robe-dominant academy silhouette with a near-black deep blue robe covering almost the entire outfit read, only a small amount of gold trim and a small academy crest detail, robe mostly closed in idle except for a narrow center chest opening no wider than about 70 to 80 percent of the face width, robe sleeves extending fully to the wrists with a slightly folded cuff and no wrist guard, no belt or waist sash, no cape-like backward flutter, robe wrapping the front, back, sides, and arms like a true heavy gown rather than a cape, straight dark blue-black slacks and low dark dress shoes, only a restrained glimpse of matching dark vest, white shirt, and red tie beneath the robe, eyes always looking in the same direction as the torso facing, short antique wooden wand with a gold mana stone when the state requires it, no frame-to-frame body rotation in idle, keep the same gaze direction and facing direction as the original idle strip.

For the in-game sprite rendering, do not ask for retro low-resolution pixel art directly. Ask for a high-resolution working sprite with subtle pixel texture and only enough dot-like structure to survive later downsampling. The final dot-graphic feel should come from the runtime normalization step, not from making the model output blocky pixels. If the user explicitly wants direct application, keep the runtime strip high-detail and skip the downscale step while still preserving the runtime strip contract. For the current player asset strategy, the in-game character is `3-head SD`, while the dialogue portrait / official illustration is `7-head`. Use visible 2 to 6 pixel shadow clusters at 4x upscale, about 4 to 7 tone groups per major material, selective 1 pixel anti-aliasing only, and no soft painterly gradients.
```

**추천 reference 수집**

- 외부 무드 이미지: 학생 마법사, 야외 탐험형 mage 2장
- 공식 일러스트 style image: [male_hero_official_illustration.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/assets/player/male_hero/references/male_hero_official_illustration.png)
- palette / 재질 이미지: blue-black robe cloth, gold trim, white shirt, muted red tie, academy knit layer, antique wand wood, soft face lighting 1~2장
- 내부 일관성 이미지: 승인된 플레이어 또는 동료 1장
- tiny sprite strip이면 별도로 `원본 strip x4 확대본`과 `대표 frame 전신 focus x8 구조 ref`를 같이 준비한다
- 인게임 sprite 생성일 때는 공식 일러스트의 `디자인 언어`만 가져오고, `렌더링 방식`은 따로 `세미-픽셀 / 약한 도트감 / sprite readability / 3.5등신 compact SD read`로 잠근다

### `ui_clean_fantasy_board`

**용도**

- HUD 프레임
- 패널
- 버튼
- 아이콘

**핵심 인상**

- 깔끔한 판타지
- 작은 화면에서도 즉시 읽히는 UI
- 너무 심심하면 금속 장식으로 보정
- 배경과 캐릭터보다 한 단계 더 정돈된 시각 언어

**반드시 보여야 하는 것**

- 아이콘 우선 판독성
- 프레임보다 내용이 먼저 읽힘
- 장식은 구조를 방해하지 않음

**피해야 하는 것**

- 과한 보석/금속 장식
- 테마파크 같은 장난감 인상
- 지나친 dark fantasy 금속 압박감

**prompt anchor**

```text
Clean fantasy RPG UI, highly readable icons and panels, restrained metal trim, organized shapes, not childish, not overdecorated, designed to sit comfortably over a busy action game screen.
```

### `approval_pair_late_hub_boss_board`

**용도**

- 첫 전체 스타일 승인
- 외부 레퍼런스와 내부 리스킨 결과를 비교할 기준 pair

**pair 구성**

1. `7~10층 허브/의식 공간` 1장
2. `7~10층 보스전` 1장

**허브/의식 공간 체크 포인트**

- 악마 침식의 공포가 읽히는가
- 성역의 잔해와 봉인 파손이 동시에 보이는가
- 배경은 어두워졌지만 완전히 탁해지지 않았는가

**보스전 체크 포인트**

- 보스, 플레이어, telegraph, 이펙트가 분리되어 읽히는가
- 화려한 이펙트가 배경에 묻히지 않는가
- `ashen red-brown` 배경에서도 불/암흑/신성 계열 차이가 보이는가

**prompt anchor**

```text
Create a matching late-game visual pair for Dungeon Mage: one corrupted ritual hub scene and one boss battle scene. Both must clearly belong to the same game. The hub should foreground demonic corruption and ritual collapse. The boss fight should foreground combat readability, bright spell effects, clear telegraphs, and strong contrast against an ashen red-brown ruined labyrinth.
```

## reference 수집 체크리스트

각 board를 실제로 채울 때는 아래 방식으로 수집한다.

- 외부 레퍼런스는 `무드`, `실루엣`, `색감` 용도로만 쓴다.
- 같은 이미지를 모든 슬롯에 재사용하지 않는다.
- 한 board당 최소 `image 1~3`은 반드시 채운다.
- `image 4`는 승인된 내부 asset가 생긴 뒤부터 필수로 본다.

권장 수집 수:

- 몬스터: board당 `2~4장`
- 배경: board당 `3~5장`
- 스킬 이펙트: school당 `2~3장`
- 캐릭터: `3장`
- UI: `2~3장`

## 프롬프트 조립 규칙

1. board의 `prompt anchor`를 붙인다.
2. 필요한 경우 `school overlay` 한 줄을 붙인다.
3. `background subdued for gameplay readability` 같은 공통 잠금 문구를 붙인다.
4. `not childish`, `not a direct copy` 같은 금지 방향을 함께 넣는다.
5. 최종 prompt는 항상 `image 1의 구조 유지` 문장으로 시작한다.

## 연관 문서

- [art_direction.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/art_direction.md)
- [flux_klein_4b_asset_regeneration.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/runbooks/flux_klein_4b_asset_regeneration.md)
