# Assets

RELIC BOUND는 제3자 에셋에 필수 의존하지 않고 **오리지널 생성 에셋**을 기준으로 개발합니다.

## 구조

```text
assets/
├─ generated/
│  ├─ source/       # 생성 원본
│  ├─ processed/    # 게임용 정리본
│  ├─ tiles/
│  ├─ characters/
│  ├─ monsters/
│  └─ ui/
└─ sunnyside/       # 필요 시 개인 참고용. Git 제외.
```

## 생성 에셋 사용 규칙

이미지 생성 결과를 그대로 게임에 넣지 않습니다.

1. 원본 생성
2. 배경/투명도 정리
3. 실제 픽셀 그리드로 리샘플링
4. 타일/프레임 분리
5. 크기와 피벗 통일
6. nearest filtering 확인
7. Godot TileSet / SpriteFrames 연결
8. 실제 화면에서 애니메이션·경계·충돌 검수

## 기준

- 월드 기본 그리드: 16×16
- 대형 오브젝트: 16px 배수
- 캐릭터 렌더 영역: 필요 시 16×24 / 16×32 등으로 확장하되 피벗 규칙 통일
- anti-aliasing 금지
- 반투명 경계 픽셀 최소화
- 런타임에서 텍스처 필터 nearest 유지

현재 `assets/sunnyside/**`는 실수로 제3자 원본이 공개 저장소에 올라가지 않도록 Git에서 제외되어 있습니다.
