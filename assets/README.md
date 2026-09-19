# Assets

## Sunnyside World

Sunnyside 원본 파일은 이 저장소에 자동으로 포함하지 않습니다.

사용자가 합법적으로 보유한 파일을 아래 구조에 배치합니다.

```text
assets/
└─ sunnyside/
   ├─ tilesets/
   ├─ characters/
   ├─ monsters/
   ├─ objects/
   ├─ interiors/
   └─ ui/
```

현재 `.gitignore`는 `assets/sunnyside/**`를 Git에서 제외합니다.
이는 원본 에셋의 의도치 않은 공개 재배포를 방지하기 위한 기본 안전장치입니다.

게임 코드는 에셋 경로를 한 곳에서 관리하도록 확장하며, 에셋이 아직 없어도 placeholder 상태로 실행 가능해야 합니다.
