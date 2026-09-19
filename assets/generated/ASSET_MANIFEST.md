# GPT-generated asset manifest

이 폴더는 RELIC BOUND 전용 오리지널 그래픽을 연결하기 위한 위치입니다.

현재 ChatGPT 이미지 생성 모델로 다음 시트가 제작되었습니다.

1. `world_tiles_v1.png` — 풀/흙/물/절벽/나무/건물/던전 타일
2. `heroes_v1.png` — 방랑자/로완/미라/상인 캐릭터
3. `enemies_v1.png` — 슬라임/고블린/고블린 브루트/스켈레톤/박쥐/늑대
4. `items_ui_v1.png` — 장비/소비품/재료/UI/월드 오브젝트

## 원칙

- Sunnyside 원본을 복제하지 않는 오리지널 에셋으로 운영합니다.
- 16×16 월드 그리드와 nearest filtering을 기준으로 후처리합니다.
- AI 생성 원본은 바로 타일맵에 넣지 않고, 실제 게임용 규격으로 슬라이싱/정리한 뒤 사용합니다.
- 캐릭터/몬스터 프레임은 크기와 피벗을 통일한 뒤 Godot SpriteFrames로 연결합니다.

현재 코드에는 에셋이 없어도 실행 가능한 픽셀 placeholder가 남아 있습니다.
실제 PNG 연결이 완료되면 placeholder를 순차 제거합니다.
