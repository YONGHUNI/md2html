# ID 데이터베이스 접근
컴퓨터공학부 통합계정 서비스인 ID는 `id.snucse.org`에 웹 서비스와 데이터베이스가 함께 배포되어 있다.
이 문서에서는 통합계정 데이터베이스에 접속한 뒤 데이터를 얻어내기 위해 필요한 지식을 설명한다.

## 데이터베이스 접속
ID 데이터베이스는 PostgreSQL을 사용하고 있다. 먼저 관리자 권한이 있는 `bacchus` 계정으로
`id.snucse.org`에 접속한다. 비밀번호는 정회원인 경우 바장 또는 부바장한테 물어보면 알려 줄 것이다.

```
ssh bacchus@id.snucse.org
```

접속되었다면 다음 세 가지 방법을 통해 데이터베이스에 접속할 수 있다. 간단한 방법부터 소개한다.

### `id-fetch-user`: 유저 정보 검색
가장 흔한 경우인 유저 정보 검색을 위한 스크립트가 `bacchus`의 홈 디렉토리에 준비되어 있다. 만약 유저
정보를 확인하는 것만이 목적이라면 따로 데이터베이스에 접속해 SQL 쿼리를 작성할 필요 없이 미리 준비된
스크립트만을 사용해 정보를 얻을 수 있다. 만약을 위해 스크립트 본문을 이 문서의 마지막에 있는 부록에
복사해 두었으니, 혹시라도 스크립트가 삭제되었다면 복사해서 사용하도록 하자.

아래 명령어를 통해 도움말을 출력할 수 있다. (`$` 뒤의 내용 한 줄을 입력하면 된다.)
```
$ ./id-fetch-user -h
Usage: ./id-fetch-user [QUERIES]...

  -n NAME         search by name
  -u USERNAME     search by username
  -s STUDENT_NUMBER
                  search by student number
```

`-n`을 사용해 이름으로 검색, `-u`를 사용해 유저 ID로 검색, `-s`를 사용해 학번으로 검색할 수 있다.
실제 검색을 할 때는 데이터베이스에 접속하게 되므로, `bacchus`의 비밀번호를 한번 더 입력해야 할 수
있다.

예를 들어, 이 문서를 작성한 사람의 정보를 검색해 보자.
```
$ ./id-fetch-user -u vbchunguk
[sudo] password for bacchus:
 username  |  name  | student_number | address_local | address_domain | group_idx
-----------+--------+----------------+---------------+----------------+-----------
 vbchunguk | 최원우 | 2016-18720     | chwo9843      | gmail.com      |         1
 vbchunguk | 최원우 | 2016-18720     | chwo9843      | gmail.com      |         2
 vbchunguk | 최원우 | 2016-18720     | chwo9843      | gmail.com      |         9
(3 rows)

```

검색 결과에서는 다음과 같은 내용을 확인할 수 있다.
- `username`: 유저 ID
- `name`: 이름
- `student_number`: 학번
- `address_local`, `address_domain`: 이메일 주소
- `group_idx`: 해당 유저가 가입되어 있는 그룹의 ID
  - 그룹에 관해서는 ID의 구조를 설명한 문서를 참고하자.

이 결과만으로 통합계정과 관련된 대부분의 문의를 처리할 수 있다.
- 검색 결과가 없으면 가입 기록이 없는 경우이니 가입을 안내한다.
- `group_idx = 1`이 컴퓨터공학 전공 그룹이다. 스누씨나 학부 홈페이지 가입을 위해서는 해당 그룹에
  가입되어 있어야 한다.

### 간단한 SQL 쿼리를 쓸 때
데이터베이스를 수정하지 않는 읽기 쿼리를 사용할 때는 다음 명령을 사용해 바로 PostgreSQL 콘솔을 띄울
수 있다.

```
$ sudo -u id psql
[sudo] password for bacchus:
psql (10.19 (Ubuntu 10.19-0ubuntu0.18.04.1))
Type "help" for help.

id=>
```

### 좀 복잡한 SQL 쿼리가 필요할 때
데이터베이스에 많은 수정이 필요한 경우 먼저 백업을 만든 뒤에 진행하는 것이 권장된다. 백업용
스크립트가 있는 `id` 계정으로 전환한다. `bacchus` 셸에서 `i`를 입력하면 전환할 수 있다.
```
bacchus@id:~$ i
[sudo] password for bacchus:
간이 백업 시스템: 뭔가 라이브 DB에 쿼리 때리기 전에 'b' 라고 입력하세요. DB가 백업됩니다.
id@id:~$
```

이 상태에서 `b`를 입력하면 백업이 `id`의 홈 디렉토리에 생성된다.
```
$ b
2022-03-24T18:23:39+09:00
$ ls backup/2022-03-24*
backup/2022-03-24T18:23:39+09:00.sql
```

이후 `psql`을 입력해 PostgreSQL 콘솔을 띄운다.
```
$ psql
psql (10.19 (Ubuntu 10.19-0ubuntu0.18.04.1))
Type "help" for help.

id=>
```

## 쿼리 입력
SQL 쿼리 작성법은 인터넷 검색으로 확인할 수 있다. ID에서 자주 사용하는 쿼리는 별도 문서를 참고하자.

### 테이블 정보 확인
`\d`를 입력하면 전체 테이블 목록을 확인할 수 있고, `\d table_name`을 입력하면 테이블 `table_name`의
스키마를 확인할 수 있다.

```
id=> \d users
                                           Table "public.users"
       Column       |           Type           | Collation | Nullable |              Default
--------------------+--------------------------+-----------+----------+------------------------------------
 idx                | integer                  |           | not null | nextval('users_idx_seq'::regclass)
 username           | text                     |           |          |
 password_digest    | text                     |           |          |
 name               | text                     |           | not null |
 uid                | integer                  |           | not null |
 shell              | text                     |           | not null |
 preferred_language | language                 |           | not null |
 activated          | boolean                  |           | not null | true
 created_at         | timestamp with time zone |           |          | now()
 last_login_at      | timestamp with time zone |           |          |
Indexes:
    "users_pkey" PRIMARY KEY, btree (idx)
    "users_uid_key" UNIQUE CONSTRAINT, btree (uid)
    "users_username_key" UNIQUE CONSTRAINT, btree (username)
Check constraints:
    "users_name_check" CHECK (name <> ''::text)
    "users_username_check" CHECK (username <> ''::text)
Foreign-key constraints:
    "users_shell_fkey" FOREIGN KEY (shell) REFERENCES shells(shell)
Referenced by:
    TABLE "email_addresses" CONSTRAINT "email_addresses_owner_idx_fkey" FOREIGN KEY (owner_idx) REFERENCES users(idx) ON DELETE CASCADE
    TABLE "password_change_tokens" CONSTRAINT "password_change_tokens_user_idx_fkey" FOREIGN KEY (user_idx) REFERENCES users(idx) ON DELETE CASCADE
    TABLE "pending_user_memberships" CONSTRAINT "pending_user_memberships_user_idx_fkey" FOREIGN KEY (user_idx) REFERENCES users(idx) ON DELETE CASCADE
    TABLE "reserved_usernames" CONSTRAINT "reserved_usernames_owner_idx_fkey" FOREIGN KEY (owner_idx) REFERENCES users(idx) ON DELETE SET NULL
    TABLE "student_numbers" CONSTRAINT "snuids_owner_idx_fkey" FOREIGN KEY (owner_idx) REFERENCES users(idx) ON DELETE CASCADE
    TABLE "user_memberships" CONSTRAINT "user_memberships_user_idx_fkey" FOREIGN KEY (user_idx) REFERENCES users(idx) ON DELETE CASCADE
```

### 트랜잭션
데이터베이스를 수정하는 쿼리를 실행하기 전에는 **꼭** 트랜잭션을 사용하도록 하자. 실수를 방지하기
위해서이다.

트랜잭션은 `begin`으로 시작한다.
```
id=> begin;
BEGIN
```

이후 평소대로 쿼리를 실행한다. 수정 쿼리도 해당 세션에서는 반영되어 있지만 실제 데이터베이스에 바로
적용되지는 않는다.

쿼리를 잘못 실행해서 의도치 않은 데이터 변경이 발생했거나, 쿼리 실행 중 문법 오류 등이 발생한 경우
트랜잭션을 취소하고 다시 시작해야 한다. 트랜잭션을 취소할 때는 `rollback`을 사용한다.
```
id=> rollback;
ROLLBACK
id=> begin;
BEGIN
```

수정 내용이 만족스럽다면 `commit`을 사용해 수정 내용을 데이터베이스에 반영시킬 수 있다.
```
id=> commit;
COMMIT
```

### 여러 줄 쿼리 입력
`\e`를 사용하면 쿼리를 텍스트 에디터를 사용해 입력할 수 있다. 기본으로 이전에 실행한 쿼리가
표시된다.

## 부록
<details><summary>id-fetch-user</summary>

```sh
#!/bin/bash
set -euo pipefail
execname="$0"

error() {
  echo "${execname}: $1" >&2
}

usage() {
  echo "Usage: ${execname} [QUERIES]..." >&2
  echo >&2
  #       012345670123456701234567
  echo '  -n NAME         search by name' >&2
  echo '  -u USERNAME     search by username' >&2
  echo '  -s STUDENT_NUMBER' >&2
  echo '                  search by student number' >&2
}

# https://stackoverflow.com/a/17841619
joinby() {
  local d=${1-} f=${2-}
  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

if [[ $# -le 0 ]]; then
  error "no queries given"
  usage
  exit 1
fi

names=()
usernames=()
stdnums=()

while getopts ':hn:u:s:' o; do
  case "$o" in
    n) names+=( "'$OPTARG'" );;
    u) usernames+=( "'$OPTARG'" );;
    s) stdnums+=( "'$OPTARG'" );;
    h) usage; exit;;
    *) error "unknown option $o"; usage; exit 1;;
  esac
done

namelist="$(joinby ', ' "${names[@]}")"
usernamelist="$(joinby ', ' "${usernames[@]}")"
stdnumlist="$(joinby ', ' "${stdnums[@]}")"

where_clauses=()
if [[ $namelist ]]; then
  where_clauses+=( "u.name in (${namelist})" )
fi
if [[ $usernamelist ]]; then
  where_clauses+=( "u.username in (${usernamelist})" )
fi
if [[ $stdnumlist ]]; then
  where_clauses+=( "sn.student_number in (${stdnumlist})" )
fi

sudo -u postgres psql id <<EOF
select
    u.username, u.name, sn.student_number, ea.address_local, ea.address_domain, um.group_idx
  from users u
    left outer join user_memberships um on um.user_idx = u.idx
    left outer join email_addresses ea on ea.owner_idx = u.idx
    left outer join student_numbers sn on sn.owner_idx = u.idx
  where $(joinby ' or ' "${where_clauses[@]}");
EOF
```
</details>
