# DevLog Day10 2021.12.2(목)

## 출시
- 와이파이 이슈를 확인하고 심사제출 준비물을 만들어 제출했다.

### 리젝 사유가 될거라고 생각하는 부분
- 스포츠 팀로고의 경우 저작권 문제가 있을 수 있어 이 부분 때문에라도 리젝이 될거라고 생각한다.

### 대응방안
- 팀명은 한글화로 따로 데이터를 만든다.
- 팀명만 있으면 심심하니 팀 로고의 색상 2개를 반영한 단순한 직사각형 2개를 같이 보여주는거로 대체 예정
- 한글화 작업은 진행중

---

## API 데이터의 문제

### 교체 이벤트에서 잘못된 데이터 작성
- player가 들어온 선수 assist가 나간 선수인 데이터도 있고 그 반대인 경우도 있다.
- 화살표나 색상 등 들어오고 나간 선수의 표시가 다르므로 대응이 필요하다.
- 선발 명단을 받아와서 거기에 포함되어 있으면 나가는 쪽 Label에 적는 작업 예정  

## 계획취소
- 선발 명단은 풀네임이고 교체 이벤트 이름은 줄인 이름이라서 확인이 힘듬  
- 선수 이름이 아닌 선수 id로 하면 해결 될텐데 Realm 스키마를 변경해야해서 적용이 힘듬.

### 오늘의 교훈
- id로 구분되어 있는 것은 id를 이용하자

### 임시대응
- 화살표를 위아래로 변경해서 오해의 소지를 조금 줄임
  

