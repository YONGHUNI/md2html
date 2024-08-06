# TODO: 대표단 권한 인수인계

바쿠스 대표단이 변경된 후 권한의 인수인계를 위해 처리할 TODO 리스트입니다.

대표가 변경되는 경우, 아래의 TODO를 전부 처리하면 됩니다.

대표가 변경되지 않고 부대표만 변경되는 경우, ***이 부분은 `신임 대표`가 처리합니다!*** 또는 ***이 부분은 `전임 대표`와 `신임 대표`가 함께 처리합니다!*** 에 해당하는 TODO를 처리하면 됩니다. 이때 현 대표는 `전임 대표` 및 `신임 대표`가 하는 일들을 모두 처리하되, `전임 부대표` 및 `신임 부대표`가 대상이 되는 일들만 처리하면 됩니다.

## Internal

### 1. Google Admin

***이 부분은 `신임 대표`가 처리합니다!***

1. `신임 대표`가 전달받은 `admin@snucse.org` (Google Admin) 계정으로 로그인.
2. `신임 대표`가 <https://myaccount.google.com/security> 에서 Recovery phone과 Recovery email을 `신임 대표` 자신의 정보로 업데이트.
3. `신임 대표`가 <https://admin.google.com/ac/accountsettings/profile> 에서 Contact info의 Secondary Email을 `신임 대표` 자신의 이메일로 업데이트.
4. `신임 대표`가 <https://admin.google.com/ac/groups> 에서 `Bacchus etc` 그룹 업데이트. Members에서 `신임 대표` 및 `신임 부대표`를 추가하고, `전임 대표` 및 `전임 부대표`는 제거.
5. `신임 대표`가 <https://groups.google.com/g/bacchus_archive/members> 에서 `신임 대표` 자신의 바쿠스 이메일을 Member로 추가. `Administrator bacchus`와 `신임 대표` 자신을 제외한 모든 사람은 제거.

### 2. GitHub

***이 부분은 `전임 대표`와 `신임 대표`가 함께 처리합니다!***

- [Maintaining ownership continuity for your organization](https://docs.github.com/en/free-pro-team@latest/github/setting-up-and-managing-organizations-and-teams/maintaining-ownership-continuity-for-your-organization)
- [Adding organization members to a team](https://docs.github.com/en/free-pro-team@latest/github/setting-up-and-managing-organizations-and-teams/adding-organization-members-to-a-team)
- [Removing organization members from a team](https://docs.github.com/en/free-pro-team@latest/github/setting-up-and-managing-organizations-and-teams/removing-organization-members-from-a-team)

1. <https://github.com/orgs/bacchus-snu/people> 에서 role 업데이트.
   - `전임 대표`가 `신임 대표` 및 `신임 부대표`를 Owner로 변경.
   - 새로 Owner가 된 `신임 대표`가 `전임 대표` 및 `전임 부대표`를 Member로 변경.
2. <https://github.com/orgs/bacchus-snu/teams/deputy/members> 에서 `deputy` 업데이트.
   - 새로 Owner가 된 `신임 대표`가 `신임 대표` 및 `신임 부대표`를 `deputy`에 추가.
   - 새로 Owner가 된 `신임 대표`가 `전임 대표` 및 `전임 부대표`를 `deputy`에서 제거.

### 3. Discord

***이 부분은 `전임 대표`와 `신임 대표`가 함께 처리합니다!***

1. Server Owner 권한 이전.
2. 새로 Owner가 된 `신임 대표`가 `신임 대표` 및 `신임 부대표`를 `회장단` Role에
   추가.
3. 새로 Owner가 된 `신임 대표`가 `전임 대표` 및 `전임 부대표`를 `회장단`
   Role에서 제거.

### 4. Vault

***이 부분은 `전임 대표`와 `신임 대표`가 함께 처리합니다!***

1. Vault CLI 설치 및 로그인
   - <https://www.vaultproject.io/>
   - `VAULT_ADDR=https://vault.bacchus.io vault login -method=oidc`
2. `전임 대표`가 `신임 대표`  에게 `기존 unseal key` 전달.
3. `신임 대표`가 `신규 unseal key` 생성.
   - `vault operator rekey -init -key-shares=1 -key-threshold=1`
   - `vault operator rekey` 에 `기존 unseal key` 입력.
   - 아웃풋의 `신규 unseal key` 안전하게 저장.
4. `신임 대표`가 `신규 unseal key`를 `신임 부대표` 에게 안전하게 전달.

### 5. Talos

***이 부분은 `전임 대표`와 `신임 대표`가 함께 처리합니다!***

1. Talos `secret bundle`을 `전임 대표`가 `신임 대표` 에게 안전하게 전달.
   - `secret bundle` (`secret.yaml`)을 rotation이 불가능하니 보관/전달 시 유의.
2. `신임 대표`가 `secret bundle`를 `신임 부대표` 에게 안전하게 전달.

## Public

### 1. 대표단 변경 이메일 발송

***이 부분은 `신임 대표`가 처리합니다!***

- `신임 대표`가 이메일을 통해 대표단 변동 사항을 공고.
- 이메일 내용에는 `신임 대표`와 `신임 부대표`의 정보를 포함하고, 과거의 대표단 변경 이메일을 참고하여 작성.
- 수신인은 다음과 같이 설정.
   - Recipient: `member@bacchus.snucse.org`
   - CC: `staff@cse.snu.ac.kr`, `bgchun@snu.ac.kr` (전병곤 교수님, 지도교수), `gil.hur@sf.snu.ac.kr` (허충길 교수님, 현 학생.연구부학부장 -> 변경되면 업데이트)

### 2. 바쿠스 홈페이지 업데이트

***이 부분은 `신임 대표`가 처리합니다!***

- <https://bacchus.snucse.org/members/> 페이지의 Deputy를 `신임 대표`와 `신임 부대표`의 정보로 업데이트.
- `신임 대표`가 <https://github.com/bacchus-snu/bacchus-homepage> 의 내용에 따라 바쿠스 홈페이지 업데이트.

### 3. 컴퓨터공학부 동아리연합회 단체톡방 인수인계

***이 부분은 `전임 대표`가 처리합니다!***

- `전임 대표`가 컴퓨터공학부 동아리연합회 단체톡방에 `신임 대표`를 초대.
- `전임 대표`는 `신임 대표`를 소개 후 해당 단체톡방에서 퇴장.
