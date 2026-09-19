# GPT-generated asset manifest

RELIC BOUND의 오리지널 그래픽은 GPT 이미지 생성 결과를 아트 방향 기준으로 사용하고, 게임에서 안정적으로 사용할 수 있도록 실제 픽셀 규격으로 후처리합니다.

## V0.4.4 production sheets

| 파일 | 규격 | 용도 |
| --- | ---: | --- |
| `tiles/world_tiles_v1.png` | 128×128 | 16×16 타일 8×8 atlas |
| `characters/heroes_v1.png` | 192×96 | 16×24 캐릭터, 4방향 × 3프레임 × 4행 |
| `monsters/enemies_v1.png` | 64×48 | 16×16 몬스터, 4프레임 × 3행 |
| `ui/ui_icons_v1.png` | 128×16 | 16×16 UI 아이콘 8종 |

## 현재 연결 상태

- 플레이어: 캐릭터 시트 연결 + 방향/걷기 프레임
- 로완/미라/NPC: 캐릭터 시트 연결
- 슬라임/고블린/스켈레톤: 몬스터 시트 연결 + 4프레임 애니메이션
- 시작 마을/초원: 16×16 tile atlas 기반 렌더링
- UI 아이콘: 파일 규격 확립, 실제 UI 배치는 후속 단계

## 품질 규칙

- nearest filtering
- anti-aliasing 사용 금지
- 타일 기본 단위 16×16
- 캐릭터 피벗/프레임 크기 고정
- 이미지 모델의 원본 해상도를 그대로 런타임 에셋으로 사용하지 않음
- CI에서 sheet dimensions를 자동 검증
