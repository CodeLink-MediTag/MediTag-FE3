# Git Workflow 규칙

## 1. 메인 브랜치 구조
- `main`: 출시용 브랜치입니다. (절대 직접 커밋/푸시 ❌)
- `dev`: 개발 중인 모든 기능을 합치는 브랜치입니다. 여기서 기능 브랜치를 파생시킵니다.

## 2. 작업 브랜치 이름 규칙
- `dev`에서 항상 새 브랜치를 파고 작업합니다.

### 브랜치 이름 규칙:
- 기능 개발: `feat/기능명`
- 디자인 수정: `style/화면명`
- 버그 수정: `fix/버그명`
- 리팩토링: `refactor/파일명`

#### 예시:
- `feat/login`
- `style/home-ui`
- `fix/button-click`
- `refactor/navbar`

**브랜치는 무조건 `dev` 최신 상태에서 만들기**

```bash
git checkout dev
git pull
git checkout -b feat/기능명

3. 작업 흐름
dev 최신화 후 브랜치 생성

로컬에서 작업 후 커밋 및 푸시

GitHub에 Pull Request(PR) 생성

PR 제목 규칙: [feat] 로그인 기능 추가 / [fix] 버튼 클릭 안되는 문제 수정

PR에 작업 내용 간단히 정리

팀원 리뷰 후 dev에 머지

혼자 작업 시 self-merge도 가능 (팀에서 합의)

4. 머지 방식
Fast-forward 금지: Merge commit 생성 (기록이 남게)

GitHub PR할 때 Create a merge commit 옵션 선택.

충돌 발생 시 PR 작성자가 직접 해결

5. 기타 추천
1~2일마다 dev를 pull 하여 로컬 브랜치를 최신화합니다. (충돌 방지)

기능 개발이 완료되면 브랜치를 삭제합니다. (로컬 + 원격)

아주 큰 기능은 feat/1, feat/2 식으로 나눠서 관리합니다.



요약 플로우

git checkout dev
git pull origin dev
git checkout -b feat/로그인페이지

# 작업
git add .
git commit -m "[feat] 로그인 페이지 UI 완성"
git push origin feat/로그인페이지

# GitHub에서 PR 생성 → dev로 머지
