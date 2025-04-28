# 🛠️ 프로젝트 협업 규칙

## 📌 보편적이고 추천하는 방식 (프론트엔드 3인 협업용)

### 1. 메인 브랜치 구조
- **main**: 출시용 (절대 직접 커밋/푸시 ❌)
- **dev**: 개발 중인 모든 기능을 합치는 브랜치. 여기서 기능 브랜치를 파생합니다.

### 2. 작업 브랜치 이름 규칙
- **기능 개발**: `feat/기능명`
- **디자인 수정**: `style/화면명`
- **버그 수정**: `fix/버그명`
- **리팩토링**: `refactor/파일명`

**예시**  
- `feat/login`  
- `style/home-ui`  
- `fix/button-click`  
- `refactor/navbar`

**브랜치 생성 시**  
- 항상 `dev` 최신 상태에서 브랜치를 파고 작업합니다.  
- 명령어:
- `git checkout dev  `
- `git pull  `
- `git checkout -b feat/기능명  `


### 3. 작업 흐름
1. 로컬에서 dev 최신화 후 브랜치 생성  
2. 로컬에서 작업 후 커밋, 원격에 푸시  
3. GitHub에 Pull Request(PR) 생성 (대상: dev)  
4. PR 제목 규칙  
   - `[feat] 로그인 기능 추가`  
   - `[fix] 버튼 클릭 안되는 문제 수정`  
5. PR 본문에 작업 내용 간단 정리  
6. 팀원 리뷰 후 dev에 merge  
   (혼자 작업 시 self-merge 가능, 팀 내 합의 필요)
   
## 📌 브랜치 병합 순서

1. 작업 완료 후 본인 브랜치를 원격 저장소에 push합니다.
2. GitHub에서 **본인 작업 브랜치 → dev 브랜치**로 Pull Request(PR)을 생성합니다.
3. 충돌이 없는 경우 PR을 바로 merge할 수 있습니다.
4. 충돌이 발생한 경우:
   - PR 화면에 **Resolve conflicts** 요청이 표시됩니다.
   - 로컬에서 본인 작업 브랜치로 이동한 후, dev 브랜치의 최신 내용을 가져와 병합합니다.

     ```bash
     git checkout feat/기능명
     git merge dev
     ```

   - 충돌이 발생한 파일을 수정합니다.
   - 수정이 완료되면 add 및 commit 후 원격 저장소에 push합니다.

     ```bash
     git add .
     git commit -m "충돌 해결"
     git push origin feat/기능명
     ```

   - 원격 PR 화면의 **Resolve conflicts** 표시가 사라지면 merge를 진행합니다.
5. merge가 완료되면 본인 작업 브랜치를 **로컬과 원격 저장소에서 모두 삭제**합니다.

   ```bash
   // 로컬 브랜치 삭제
   git branch -d feat/기능명

   // 원격 브랜치 삭제
   git push origin --delete feat/기능명

   
### 4. 머지 방식
- **Fast-forward 금지, Merge commit 생성**  
- GitHub PR 시 `Create a merge commit` 옵션 선택  
- 충돌 발생 시 PR 작성자가 직접 해결

### 5. 기타 추천 사항
- 1~2일마다 dev pull로 로컬 브랜치 최신화 (충돌 방지)  
- 기능 개발 완료 시 브랜치 삭제 (로컬 + 원격)
- 큰 기능은 `feat/1`, `feat/2` 식으로 나눠서 관리

---

### 🛠️ 요약 플로우
- `git checkout dev`
- `git pull origin dev`
- `git checkout -b feat/로그인페이지`

작업
- `git add .`
- `git commit -m "[feat] 로그인 페이지 UI 완성"`
- `git push origin feat/로그인페이지`

