# ID 관련 문서

## 통합계정 가입 중 에러 문의 처리
가입 중에 에러가 나는 경우는 크게 다음 두 가지 경우 중 하나이다.
- 이미 가입되어 있는 경우
- 모종의 이유로 이메일 인증을 여러 번 시도한 경우

먼저 `id-fetch-user`를 사용해 이미 가입된 유저인지 확인해 본다. 검색 결과가 있는 경우 이미 가입되어
있음을 알려주고, 비밀번호를 잊어버린 경우 비밀번호 재설정을 해 달라고 회신한다.

결과가 안 나오는 경우가 두 번째 원인에 해당한다. 이 경우는 데이터베이스에 접속해 이메일 정보를
확인해야 한다.

### 이메일 인증 상태 확인하기
유저의 이메일에 관련된 정보는 `email_addresses`와 `email_verification_tokens` 테이블에 저장되어
있다. 먼저 `email_addresses`에 쿼리를 날려 가입 신청한 이메일 주소가 데이터베이스에 존재하는지
확인한다. (존재할 것이다.)
```sql
select * from email_addresses
  where address_local = $?    -- 이메일의 @ 앞부분
    and address_domain = $?;  -- 이메일의 @ 뒷부분
```

대부분 `address_domain`은 `snu.ac.kr`일 것이므로 해당 부분을 생략한 다음 쿼리도 가능하다.
```sql
select * from email_addresses
  where address_local = $?;  -- 이메일의 @ 앞부분
```

쿼리 실행 예시는 다음과 같다. (`address_local` 부분은 지웠다.)
```
id=> select * from email_addresses
id->   where address_local = '[redacted]';
 idx  | owner_idx | address_local | address_domain
------+-----------+---------------+----------------
 4121 |           | [redacted]    | snu.ac.kr
(1 row)

```

이후의 대응은 `owner_idx`가 비어있는지 아닌지에 따라 다르다.

#### `owner_idx`가 비어있는 경우
문의의 대부분을 차지하는 이 경우는 모종의 이유로 인증 메일을 받지 못하고 있는 상황을 의미한다. 먼저
`email_verification_tokens` 테이블에서 `idx` 값으로 검색한다.
```sql
select * from email_verification_tokens
  where email_idx = $?;  -- idx에 적힌 값
```

아래는 예시 결과이다(데이터는 임의로 생성함).
```
 idx  | email_idx |                              token                               |          expires           | resend_count
------+-----------+------------------------------------------------------------------+----------------------------+--------------
  573 |      3080 | e4542bad81a097db89e28fee00b7800c832d2ba04fb4a50ca2a63fe39c33d52b | 2022-05-20 02:34:54.505+00 |           11
(1 row)

```

이제 두 가지 방법으로 문의를 처리할 수 있다.
- **테이블에서 레코드 지우기**: `idx`를 확인하고 해당 레코드를 지운다.
  ```sql
  delete from email_verification_tokens
    where idx = $?;  -- 확인한 idx
  ```
  이후 다시 가입을 요청한다.
- **인증 주소 직접 보내주기**: `expires`가 현재 시각을 지나지 않은 경우, `token`을 사용해 인증
  주소를 만들어 직접 전달할 수 있다.
  ```
  https://id.snucse.org/sign-up?token=e4542bad81a097db89e28fee00b7800c832d2ba04fb4a50ca2a63fe39c33d52b
  ```

#### `owner_idx`가 비어있지 않은 경우
만약 `owner_idx` 값이 있다면 해당 이메일에 연결된 계정이 있다는 뜻이다. 이때는 해당 값으로 `users`
테이블에서 검색하면 유저명을 알아낼 수 있다.
```sql
select username, name from users
  where idx = $?;  -- owner_idx에 적힌 값
```

## 수업용 그룹 생성
수업용 그룹 신청을 받은 경우, 다음 두 개의 그룹을 만들어줘야 한다.
- 실제 수강생이 가입 신청을 하는 **수강생 그룹**
- 가입 신청을 처리할 관리자(보통 조교)가 들어갈 **관리자 그룹**

### 그룹 생성하기
그룹은 `groups` 테이블에 저장된다. 새 그룹을 만들 때는 다음 4개의 컬럼 값을 반드시 지정해야 한다.
- `name_ko`, `name_en`: 그룹 이름 (한국어, 영어)
- `description_ko`, `description_en`: 그룹 설명 (한국어, 영어)
- `identifier`: OIDC등 외부 시스템에서 이 그룹을 칭하는 이름.

그룹을 생성할 땐 `insert`를 사용한다. **만들기 전에 트랜잭션을 시작했는지 확인할 것!**
```sql
insert into groups (name_ko, name_en, description_ko, description_en, identifier)
  values ('한국어 이름', 'Name in English', '한국어 설명', 'Description in English', 'group-identifier')
  returning idx;
```

실행 결과로 만들어진 그룹의 ID가 출력된다. 아래 실행 결과에서는 ID가 105이다.
```
id=> insert into groups (name_ko, name_en, description_ko, description_en, identifier)
id->   values ('한국어 이름', 'Name in English', '한국어 설명', 'Description in English', 'group-identifier')
id->   returning idx;
 idx
-----
 105
(1 row)

INSERT 0 1
```

수강생 그룹과 관리자 그룹의 ID를 확인했다면, 수강생 그룹의 관리자 그룹이 무엇인지 설정해줘야 한다.
이때는 `update`를 사용한다.
```sql
update groups
  set owner_group_idx = $?  -- 관리자 그룹 ID
  where idx = $?;           -- 수강생 그룹 ID
```

예시 실행 결과는 다음과 같다.
```
id=> update groups
id->   set owner_group_idx = 108
id->   where idx = 109;
UPDATE 1
```

잘 했다면 `UPDATE 1`이라고 떠야 한다. 1보다 크다면 뭔가 잘못 입력해서 다른 row까지 수정된 것이므로
침착하게 `rollback`하고 다시 시작하자.

### 권한 부여하기
물론 그룹만 만들어서는 실습실 로그인 권한을 부여해줄 수 없다. 그룹에 속한 유저들에게 특별한 권한이
필요한 경우, `group_relations`를 수정해 새로 만든 그룹과 권한을 가진 그룹 사이의 관계를 설정해줘야
한다.

`groups` 테이블을 보면 권한 부여용 그룹들이 있다. 전체 결과 중 몇 개만 표시했다.
```sql
select idx, name_ko from groups;
```

```
 idx |                  name_ko                  |              description_ko
-----+-------------------------------------------+------------------------------------------
   7 | 실습 서버 사용자                          | 실습 서버 사용자 그룹
   8 | 스누씨 사용자                             | 스누씨 웹 서비스 사용자 그룹
  13 | 하드웨어 실습실 사용자                    | 하드웨어 실습실 사용자 그룹
   6 | 소프트웨어 실습실 사용자                  | 소프트웨어 실습실 사용자 그룹
   9 | GPU 서버 사용자                           | GPU 서버 사용자 그룹                    +
     |                                           | https://bacchus.snucse.org/ 참고
```

이 중에서 필요한 권한을 가진 그룹을 찾아, 다음 쿼리를 사용해 권한을 부여한다.
```sql
insert into group_relations (subgroup_idx, supergroup_idx)
  values ($?, $?);  -- 순서대로 "권한을 가진 그룹 ID", "새 그룹 ID"
```

> 엥? 반대 아닌가요?

그렇다, 이름이 헷갈린다. (작성자도 실시간으로 헷갈려하고 있다.) 이게 맞으니 그냥 보고 따라
입력해줬으면 한다.

### 실습실 로그인 제한하기
시험을 칠 때와 같이 특정 권한을 가진 유저를 제한할 필요가 있을 땐 `permission_requirements` 테이블을
수정한다. `permission_requirements` 테이블에는 권한 ID와 그 권한을 갖기 위해 유저가 속해야 할 그룹
ID가 적혀 있다. 여기에 적힌 조건은 모두 AND 연산이 적용된다. 즉, 권한과 연결된 그룹이 여러 개라면
유저는 그 그룹 모두에 속해야 한다. 이 특성을 이용해 시험용 계정 그룹을 만든 뒤
`permission_requirements` 테이블에 "하드웨어 실습실을 사용하려면 이 그룹에 속해야 한다"고 적어주면
로그인 제한을 쉽게 걸 수 있다.

권한 ID는 `permissions` 테이블에서 확인할 수 있다. **그룹 ID와는 다르다는 것에 주의!**
```sql
select idx, name_ko, description_ko from permissions;
```

```
 idx |        name_ko         |         description_ko
-----+------------------------+--------------------------------
   1 | 스누씨 권한            | 스누씨 사용가능 권한
   3 | 실습서버 권한          | 실습서버 사용 권한
   4 | GPU 서버               | GPU 서버 사용 권한
   5 | 하드웨어 실습실 권한   | 하드웨어 실습실 사용 권한
   6 | 과방 권한              | 과방 PC 사용 권한
   2 | 소프트웨어 실습실 권한 | 소프트웨어 실습실 사용 권한
   7 | 예약 시스템 관리자     | 예약 시스템 관리자 권한을 부여
   9 | 민상렬홀 출입          | 민상렬홀에 출입 가능
```

제한하고자 하는 권한의 ID를 확인한 후, 아래 쿼리를 사용해 요구조건을 추가한다.
```sql
insert into permission_requirements (permission_idx, group_idx)
  values ($?, $?)  -- 순서대로 "권한 ID", "권한이 요구하는 그룹 ID"
  returning idx;
```

위 쿼리를 실행하면 만들어진 요구조건의 ID가 출력된다. 나중에 삭제하기 쉽도록 이 ID를 기록해 놓는
것을 추천한다.

시험이 끝났다면 권한 제한을 해제해야 한다. 앞에서 기록한 요구조건의 ID를 사용해 `delete`로
테이블에서 지운다.
```sql
delete from permission_requirements
  where idx = $?;  -- 앞에서 기록한 요구조건 ID
```

## 계정 일괄 발급
시험용 계정을 만들어야 하는 경우 등 한번에 많은 계정을 만들어야 할 때를 위해, 계정 일괄 발급을
도와주는 스크립트가 있다.
```
bacchus@id:~$ i
[sudo] password for bacchus:
간이 백업 시스템: 뭔가 라이브 DB에 쿼리 때리기 전에 'b' 라고 입력하세요. DB가 백업됩니다.
id@id:~$ ls -l id/mkuser/mkuser
-rwxr-xr-x 1 id nogroup 902 Jul 18  2021 id/mkuser/mkuser
```

[`mkuser`] 스크립트는 표준 입력으로 유저명 목록을 받아, 임의의 비밀번호를 생성한 뒤 `psql`에 바로
넣을 수 있는 SQL 스크립트를 출력한다. 스크립트 인자로는 **유저가 속할 그룹 ID**와 **첫 번째 유저의
UID**를 받는다.

[`mkuser`]: https://github.com/bacchus-snu/id/tree/master/mkuser

### UID 결정하기
아직 사용되지 않은 UID 영역을 고르는 것이 중요하다. 사용되지 않은 영역을 찾기 위해 ID 데이터베이스에
접속해 다음 쿼리를 실행한다.
```sql
select username, uid from users
  order by uid desc
  limit 1;
```

```
   username    |  uid
---------------+--------
 sffinalexam25 | 210025
(1 row)
```

존재하는 UID 중 최댓값을 가진 유저가 반환된다. 여기에 적당한 수를 더해 시작 UID를 결정한다. 여기서는
`211000`이라 하자.

### 그룹 생성하기
귀찮으면 권한 부여용 그룹을 그대로 사용해도 되지만, 수업 또는 시험마다 새 그룹을 만들어 앞에서
설명한 것과 같이 `group_relations`를 사용해 권한을 부여하는 것이 권장된다. 권한 제어에 더 유리하고
자원 회수를 진행하기도 편하기 때문이다.

위의 "수업용 그룹 생성" 과정을 따라해 임시 계정이 속할 그룹을 생성한 뒤, 그룹 ID를 기록해 둔다.
여기서는 105라고 하자.

### SQL 생성하기
이제 필요한 정보가 모두 갖추어졌으므로 `mkuser`를 사용해 유저 생성 SQL을 만든다. 유저들이 공통으로
가질 접두사를 하나 정한다. 시험용 계정의 경우 수업의 영문명과 중간/기말고사로부터 따 와서
`swppfinalexam`, `sfmidexam`과 같이 정하는 경우가 많다. 여기서는 `example`이라고 정했다.
```sh
# 10: 만들 계정 개수, 105: 그룹 ID, 211000: 시작 UID
echo example{01..10} | tr ' ' '\n' | ./id/mkuser/mkuser 105 211000 >example-users.sql
```

`example-users.sql`을 출력해서 잘 생성됐는지 확인한다.
```
$ cat example-users.sql
-- PLEASE REVIEW THE QUERY BEFORE EXECUTING IT
begin;

with added_user as (
  insert into users (username, password_digest, name, uid, shell, preferred_language) values
--  example01 cmpzJhYvmZZgPopj
    ('example01', '$argon2id$v=19$m=65536,t=3,p=8$TVB3dm8wYzc4SDNqRlJJaQ$AB7uhbmqF064NIXODviHng', 'example01', '211000', '/bin/bash', 'ko')
--  example02 lDb9baCoJ/HPh5Yp
  , ('example02', '$argon2id$v=19$m=65536,t=3,p=8$akZqSG9xcmxRRjVaNnBUNg$dGIfDiJqaZBPjvgxQzDQig', 'example02', '211001', '/bin/bash', 'ko')
--  example03 ewsnl38D1dhjFx94
  , ('example03', '$argon2id$v=19$m=65536,t=3,p=8$a0s1Qmc5UDNiS3d6eXIxUA$b4IurK0iArTCwD4pdzZnCg', 'example03', '211002', '/bin/bash', 'ko')
--  example04 zvqtQ0480yAoRDdF
  , ('example04', '$argon2id$v=19$m=65536,t=3,p=8$UDRLbXoySlJOb1EwdDlWNw$H++U2jnWWA4lAsVkZkpNqQ', 'example04', '211003', '/bin/bash', 'ko')
--  example05 DGDaay9D7xifMwqF
  , ('example05', '$argon2id$v=19$m=65536,t=3,p=8$Q2FESWJWY0xIdDlKQkpDeA$DH7WP1JOZavu51wBpGSutQ', 'example05', '211004', '/bin/bash', 'ko')
--  example06 6FJr/Ow/8T32gYK5
  , ('example06', '$argon2id$v=19$m=65536,t=3,p=8$cnZmc1g5L2g3VE5GeWpONg$01wEJTKK8DqixLdMNFnm/Q', 'example06', '211005', '/bin/bash', 'ko')
--  example07 MPvUeJQ3IqB8LRZ7
  , ('example07', '$argon2id$v=19$m=65536,t=3,p=8$dm1SRjVyVk1BL0Q0WFZadA$JqUTZk4efGIIAQnx0zAMvA', 'example07', '211006', '/bin/bash', 'ko')
--  example08 gUXLPVRcLh9akOCt
  , ('example08', '$argon2id$v=19$m=65536,t=3,p=8$c1NUc2pFTHZrdGtwMTk5WQ$n3+c+NnFcvKBvtrCUPBNtw', 'example08', '211007', '/bin/bash', 'ko')
--  example09 BfZIq0Y3HPAqsNI/
  , ('example09', '$argon2id$v=19$m=65536,t=3,p=8$cU9FS1Z5ZkJsaUxFNkJ0VQ$nUEUJZ3Ykw9lGkU5nrUG9Q', 'example09', '211008', '/bin/bash', 'ko')
--  example10 pE/1zsJdp1vhLVGH
  , ('example10', '$argon2id$v=19$m=65536,t=3,p=8$ODM1UU9hZlpZNGt6dWJhTw$p1QpS67Q+72OZTdlRQi9og', 'example10', '211009', '/bin/bash', 'ko')
  returning idx
)
insert into user_memberships (user_idx, group_idx)
  select idx, 105 from added_user;

commit;
-- PLEASE REVIEW THE QUERY BEFORE EXECUTING IT
```

문제가 없어 보이면 `psql`을 사용해 이 SQL을 실행시킨다.
```
$ psql -f example-users.sql
BEGIN
INSERT 0 10
COMMIT
```

마지막으로 조교에게 전달할 때 사용하기 위해 계정명과 비밀번호만 적힌 파일을 만든다.
```sh
sed -ne 's/^--  //p' example-users.sql | tr ' ' '\t' >example-users.tsv
```

이렇게 만들어진 `example-users.tsv`를 조교에게 전달한다. 이후 해당 학기 자원회수 이슈에 과목명과
그룹 ID를 기록한다.

### 계정 삭제
임시 계정 사용이 끝나면 데이터베이스에서 해당 계정들을 지우는 것이 권장된다. **작업하기 전에 꼭
백업할 것!**

이슈 내용 등을 참고해 계정 발급에 사용한 그룹 ID가 무엇인지 확인한 뒤, 그것이 **계정 발급을 위해
새로 만든 그룹일 때만** 다음 쿼리를 실행한다.
```sql
begin;

delete from users
  using inner join user_memberships um on (um.user_idx = users.idx)
  where um.group_idx = $?;  -- 계정 발급에 사용한 그룹 ID
delete from groups
  where idx = $?;           -- 이것도, 계정 발급에 사용한 그룹 ID

commit;
```
