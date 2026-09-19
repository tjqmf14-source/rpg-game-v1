# RELIC BOUND

16×16 픽셀 아트 기반 **2D 판타지 수집형 액션 RPG**입니다.

## 기술 스택

- Engine: Godot 4.7.2
- Language: GDScript
- Target: Windows PC
- Native viewport: 480×270
- Pixel grid: 16×16
- Art: GPT 이미지 생성 기반 오리지널 에셋 + 게임용 후처리
- Core loop: 탐험 → 전투 → 수집 → 성장 → 던전 → 보스

## 현재 상태 — V0.4.4 Visual Foundation Build

구현됨:

- 8방향 이동 / 카메라
- NPC 상호작용 / 대화
- 첫 퀘스트 `초원의 위협` / 진행 HUD / 1회성 보상
- 생성형 오리지널 16px 타일/캐릭터/몬스터 에셋 V1
- 플레이어 4방향 걷기 및 몬스터 프레임 애니메이션
- 저장 / 불러오기
- 물리 hitbox/hurtbox 기반 실시간 전투 / 회피 / 적 AI
- 슬라임 / 고블린 / 스켈레톤
- 드롭 / 경험치 / 레벨업
- 영웅 영입 / 최대 4인 파티 / 캐릭터 전환
- 인벤토리 / 장비 / 유물 슬롯
- 몬스터 도감
- 손상 save 정규화 및 버전 검증
- GitHub Actions 품질 게이트
- Windows 실행 빌드 자동 생성

## 품질 게이트

main 병합 전 아래 검사를 모두 통과해야 합니다.

1. Godot project import
2. Runtime smoke test
3. Data integrity test
4. Gameplay regression test
5. Combat runtime test

자세한 기준은 `docs/QUALITY_GATE.md`를 참고하세요.

## 실행

### 방법 A — GitHub Windows 빌드

GitHub Actions의 `Windows Playtest Build`에서 `RELIC-BOUND-Windows-Playtest` Artifact를 받아 압축을 풀고 `RelicBound.exe`를 실행합니다.

### 방법 B — Godot

1. Godot 4.7.2 설치
2. `project.godot` 열기
3. F5 실행

기본 조작:

- WASD / 방향키: 이동
- J / 마우스 왼쪽: 공격
- K / Space: 회피
- E: 상호작용
- 1~4: 파티 캐릭터 전환
- P: 파티
- I: 인벤토리
- C: 도감
- F5: 저장
- F9: 불러오기

## 다음 개발 목표

대형 시스템 추가보다 먼저 **30~60분짜리 실제 Vertical Slice**를 완성합니다.

시작 마을 → 초원 → 첫 퀘스트 → 영웅 영입 → 전투 → 장비 → 첫 던전 → 첫 보스 → Windows 빌드.

## 문서

- `docs/GAME_DESIGN.md` — 게임 기획 기준
- `docs/ROADMAP.md` — 개발 순서
- `docs/QUALITY_GATE.md` — 오류/회귀 방지 기준
