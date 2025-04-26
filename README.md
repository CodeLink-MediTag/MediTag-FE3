프론트엔드 3인 협업을 위한 Git 브랜치 전략 및 워크플로우
1. 브랜치 구조
main: 출시(배포)용 브랜치입니다.
직접 커밋/푸시 금지!

dev: 개발 중인 모든 기능을 합치는 브랜치입니다.
모든 기능/수정 브랜치는 dev에서 파생합니다.

2. 작업 브랜치 네이밍 규칙
항상 dev에서 새로운 브랜치를 생성해 작업합니다.

브랜치 네이밍 규칙:

기능 개발: feat/기능명

디자인 수정: style/화면명

버그 수정: fix/버그명

리팩토링: refactor/파일명

예시:

text
feat/login
style/home-ui
fix/button-click
refactor/navbar
브랜치는 반드시 dev의 최신 상태에서 생성하세요.

text
git checkout dev
git pull
git checkout -b feat/기능명
3. 작업 흐름
dev 최신화 후 브랜치 생성

로컬에서 작업 후 커밋, 푸시

GitHub에 Pull Request(PR) 생성 (대상: dev)

PR 제목 규칙:
[feat] 로그인 기능 추가
[fix] 버튼 클릭 안되는 문제 수정

PR 본문에 작업 내용을 간단히 정리

팀원 리뷰 후 dev에 merge
(혼자 작업 시 self-merge 가능, 팀 내 합의 필요)

4. 머지 방식
Fast-forward 금지, Merge commit 생성

GitHub PR 시 Create a merge commit 옵션 선택

충돌 발생 시 PR 작성자가 직접 해결

5. 기타 추천 사항
1~2일마다 dev pull로 로컬 브랜치 최신화 (충돌 방지)

기능 개발 완료 시 브랜치 삭제 (로컬 + 원격)

큰 기능은 feat/1, feat/2 식으로 나눠서 관리

🛠️ 요약 플로우
bash
git checkout dev
git pull origin dev
git checkout -b feat/로그인페이지

# 작업
git add .
git commit -m "[feat] 로그인 페이지 UI 완성"
git push origin feat/로그인페이지

# GitHub에서 PR 생성 → dev로 머지
📄 협업 규칙 문서화 팁
위 내용을 README.md 또는 CONTRIBUTING.md 파일에 작성해두면 팀원 모두가 규칙을 쉽게 확인할 수 있습니다.

필요하다면 PR 템플릿(.github/pull_request_template.md) 파일을 만들어 PR 작성 시 자동으로 형식을 맞추게 할 수 있습니다.

실무에서도 많이 쓰는 방식이며, 팀 프로젝트 협업에 강력 추천합니다!

PR 템플릿 예시가 필요하다면 말씀해 주세요.
추가로 안내해 드릴 수 있습니다.
