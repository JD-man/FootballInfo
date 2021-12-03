# DevLog Day 11
- 심사 제출하고 결과 기다리느라 개발된건 없음

---
## 업데이트할거 생각해보기

### 1. SideMenu 제거
- 리그를 변경하는데 사이드메뉴까지 사용할 필요는 없어보인다.
- 맨 왼쪽 상단 끝자락에 있어 한손으로는 사용하기 힘들거 같다.
- 대체재로는 플로팅 버튼같이 기기 아래쪽에 위치하고 엄지손가락으로 편하게 변경할 수 있는 수단이 좋다.
- 그렇다고 플로팅 버튼을 사용할건 아니다.
- 가장 좋아보이고 도전해보고 싶은 방법은 네이버 앱의 중앙탭 돌아가는 메뉴이다.
- 서브 프로젝트를 만들어서 여러가지 실험 후에 적용 예정이다.

### 2. 팀로고 삭제
- 내가 예민한거겠지만 팀로고를 사용하는게 계속 마음에 걸린다.
- 팀명 한글화와 함께 팀컬러를 만들어서 팀로고를 대체할 예정.
- 글씨만 있으면 심심하니까~
- 심사가 통과되더라도 나중에 광고를 넣을 생각도 있어 뺄거면 빠르게 빼는게 나을거 같다.

### 3. 뉴스탭 삭제
- 네이버 뉴스 검색 API를 사용하고 있지만 검색어를 기준으로 response가 온다.
- 뉴스의 카테고리를 기반으로 검색할 수 있다면 해외축구 카테고리로 검색을 하면 될텐데 아쉽다.
- 검색어를 더 세밀하게 만든다고 해도 단어 자체가 포함되면 검색이 되다 보니 정확한 뉴스 전달이 어렵다.

### 4. Realm Migration 구현
- 이건 내가 불편해서 해야겠다.

### 5. MatchDetailVC - 포메이션
- 어떤 포메이션이고 어떤 위치 grid를 가지는지는 schema로 짜놨고 저장이 되어있다.
- 당장은 안쓰지만 나중에 업데이트할거라 미리 저장해놨다. 호호호
- Portrait만 지원하고 아무래도 가로공간이 많지 않다보니 이쁘게 나올 수 있을지 모르겠다.
- grid 정보는 row:col 형식으로 되어 있어 스택뷰를 사용하면 편리할 듯