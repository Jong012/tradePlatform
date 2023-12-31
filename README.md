# tradePlatform

중고 거래 플랫폼입니다.

# 시나리오

```text
개발자 김기주는 요즘 중고 거래에 푹 빠졌다. 전단지에 팔 물건을 이곳 저곳에 붙이면 사람들에게 연락이 오고 처치 곤란하던 물건을 팔 수 있었다.
또는 다른 전단지를 보고 필요한 물건이 있으면, 싼 값에 살 수 있어 좋았다. 하지만 전단지를 이곳 저곳 붙이는 것이 불편한 그는 인터넷을 하다 '중고나라'라는 사이트를 보았다.
그 사이트에 들어가 회원 가입을 하고 난 뒤, 자신이 필요한 물건을 올리면 판매자가 메시지를 보내고 그는 그 메시지를 보고 대화를 한 뒤 물건을 살 수 있다.
또 그는 다른 사람들이 올린 매물을 보면서 정보를 얻고 사고 싶은 물건에 좋아요를 눌러 자신이 사고자 하는 물건을 한 눈에 보거나 판매자에게 메시지를 보내 거래를 할 수 있다.
목록을 찬찬히 살펴보다 요즘 사람들이 많이 찾는(찜하는) 필터로 물건을 보거나 최근 올라온 제품으로 정렬을 하여 보는 것도 재밌었다.
```

# 개발 정보

## 기술 스택

- Python 3.11, FastApi, Postgresql, SqlAlchemy
- 관리 도구
    - poetry
    - alembic

## 기능 요구사항

### 회원

- 회원 가입
- 찜한 목록 보기
    - 페이징
    - 필터
    - 검색
- 회원 정보 수정
- 회원 탈퇴
- 비밀번호 / 아이디 찾기

### 게시판

- 구매 게시판 CRRUD
- 판매 게시판 CRRUD
- 찜하기

### 쪽지

- 쪽지 보내기
- 쪽지 알림

## 환경변수

| key | value | 
|-----|-------|
|     |       |

## ERD

## 배포 전략

### 개발환경

### 운영환경

## 테스트

```shell
# 테스트를 위해 docker compose 를 실행시키면 됩니다.
docker compose build 
docker compose up
docker compose down
```
