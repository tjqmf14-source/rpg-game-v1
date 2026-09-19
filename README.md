# RELIC BOUND

16×16 픽셀 아트 기반 **2D 판타지 수집형 액션 RPG** 프로젝트입니다.

## 기술 스택

- Engine: Godot 4.7.2
- Language: GDScript
- Target: Windows PC 우선
- Native viewport: 480×270
- Pixel grid: 16×16
- Art base: Sunnyside World (사용자가 별도 보유 및 추가)
- Core loop: 탐험 → 전투 → 수집 → 성장 → 던전 → 보스

## 현재 구현 상태 — V0.1 Bootstrap

- Godot 실행 프로젝트
- 16px 그리드 기반 임시 월드
- 플레이어 8방향 이동
- Pixel-perfect 렌더링 기본값
- GameState 전역 상태 관리
- GameDatabase JSON 데이터 로더
- 영웅 / 몬스터 / 아이템 샘플 데이터
- Headless smoke test
- GitHub Actions 자동 검증

## 실행

1. Godot 4.7.2를 설치합니다.
2. 이 저장소의 `project.godot`을 엽니다.
3. F6가 아닌 **F5**로 프로젝트를 실행합니다.
4. 방향키 또는 WASD로 이동합니다.

## Sunnyside 에셋

이 저장소는 Sunnyside 원본 에셋을 임의로 재배포하지 않습니다.
사용자가 보유한 에셋은 `assets/sunnyside/` 아래에 직접 배치합니다.

자세한 규칙은 `assets/README.md`를 참고하세요.

## 자동 검증

push / pull request마다 GitHub Actions가 다음을 수행합니다.

1. Godot 4.7.2 설치
2. 프로젝트 headless import
3. 메인 씬 및 데이터 파일 smoke test

검증이 실패하는 변경은 main에 병합하지 않는 것을 원칙으로 합니다.

## 문서

- `docs/GAME_DESIGN.md` — 게임 기획 기준
- `docs/ROADMAP.md` — 단계별 개발 계획
