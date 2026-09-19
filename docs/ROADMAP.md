# Development Roadmap

## V0.1 — Bootstrap

- [x] Godot 프로젝트 골격
- [x] 16px 월드 기준
- [x] 플레이어 이동 / 카메라
- [x] JSON 데이터 레이어
- [x] GitHub Actions

## V0.2 — Exploration Foundation

- [x] 충돌 레이어
- [x] 상호작용
- [x] NPC 대화
- [x] 세이브/로드 V1
- [ ] 실제 TileMapLayer 필드
- [x] 맵 전환

## V0.3 — Combat Prototype

- [x] 플레이어 공격
- [x] 회피
- [x] 데미지/피격
- [x] 적 AI
- [x] 슬라임 / 고블린 / 스켈레톤
- [x] 드롭
- [x] 경험치 / 레벨
- [ ] 실제 hitbox/hurtbox
- [ ] 첫 보스

## V0.4 — Collection RPG Prototype

- [x] 영웅 해금
- [x] 최대 4인 파티
- [x] 캐릭터 교체
- [x] 몬스터 도감
- [x] 인벤토리
- [x] 장비
- [x] 유물 슬롯

## V0.4.1 — Stabilization

- [x] 누락 데이터 교차검증
- [x] save version 검증
- [x] 손상 save 정규화
- [x] runtime smoke test
- [x] data integrity test
- [x] gameplay regression test
- [x] UI unique-name 충돌 수정
- [x] main 병합 품질 게이트 정의

## V0.4.3 — First Quest

- [x] 저장 가능한 첫 퀘스트 상태
- [x] 몬스터 도감 처치 수 기반 목표 판정
- [x] 퀘스트 진행 HUD
- [x] 완료 보상 중복 방지
- [x] 회귀 테스트 추가

## Vertical Slice — 현재 최우선

- [x] 실제 게임용 16px 에셋 규격 확립
- [x] 시작 마을 독립 씬/충돌/스폰 기반\n- [ ] 시작 마을 실제 TileMap
- [x] 초원 독립 씬/충돌/스폰/적 기반\n- [ ] 초원 실제 TileMap
- [x] 캐릭터 4방향 걷기 애니메이션 V1
- [x] 적 4프레임 애니메이션 V1
- [x] hitbox / hurtbox 전투
- [x] 첫 퀘스트
- [ ] 첫 던전
- [ ] 첫 보스
- [x] Windows export 자동화
- [ ] 실플레이 검수

## 이후 Content Systems

Vertical Slice 검증 후에만 확장합니다.

- [ ] 상점
- [ ] 제작
- [ ] 채집 / 채광
- [ ] 낚시
- [ ] 낮/밤
- [ ] 추가 지역
- [ ] 추가 영웅/몬스터

## V1.0 목표

- 영웅 12명
- 몬스터 30종
- 보스 5종
- 마을 2곳
- 필드 4곳
- 던전 3곳
- 장비 약 80종
- 유물 약 30종
- 플레이타임 약 4~6시간

단, Vertical Slice의 안정성과 재미가 확인된 후 콘텐츠를 확대합니다.
