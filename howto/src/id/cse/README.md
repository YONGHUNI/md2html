# cse.snu.ac.kr 계정 처리

## 개요

- cse.snu.ac.kr 은 예전에 SNUCSE 2.0 시스템과 연동되어 있었으나, 이제 SNUCSE 2.0 (old.snucse.org) 는 서비스를 중단한 상태이다. 또한, id.snucse.org 와 cse.snu.ac.kr 은 현재 연동되지 않는 상태이다.
- 그러나 cse.snu.ac.kr 의 실습실·세미나실 예약 기능을 대학원생들이 필요로 하기 때문에, 계정 발급과 유지가 필요하다.

## 업무처리기준

### 계정 요청을 받아들일지 판단하기

- 모든 요청 이메일은 `@snu.ac.kr` 메일로만 받는다. (`@aces.snu.ac.kr` 와 같은 연구실 도메인 메일 역시 받아들이지 않는다.) 또한, 요청 메일에는 소속 연구실 이름과 지도교수 이름이 포함되어야 한다. (이는, 추후에 문제가 생길 경우 당사자에게 확실히 연락할 수 있는 수단을 확보하기 위함이다.)
- cse.snu.ac.kr 계정의 ID는 id.snucse.org에 등록된 동일인물의 계정 ID와 일치해야 한다.
- 또한 id.snucse.org 의 계정은 "컴퓨터공학 전공" 그룹에 가입되어 있어야 한다.
- 모든 요청 이메일을 `@snu.ac.kr` 메일로만 받는데, 그 주소는 id.snucse.org 에 등록된 이메일 주소와 일치해야 한다.
  - 예외: SNUCSE 2.0 과 연동한 기록이 있는 계정은 이 검사를 수행하지 않는다. SNUCSE 2.0은 `@snu.ac.kr` 외의 다른 이메일로도 가입을 허용했기 때문이다.

### 계정 요청을 받아들이기로 했다면...

- 이미 cse.snu.ac.kr 에 해당 사용자의 계정이 있다면
  - SNUCSE 2.0 시스템과의 연동용 레코드가 살아있다면 DB에서 이를 제거한다.
  - cse.snu.ac.kr 계정의 패스워드를 랜덤하게 초기화한다.
- 계정이 이미 있지 않았다면, cse.snu.ac.kr 에 신규 계정을 추가한다. (패스워드는 랜덤한 값으로 초기 설정한다)

### 기타 주의사항

- 처리 완료 후 사용자에게 보내는 메일은 contact@bacchus.snucse.org 에도 공유한다.
- 다만 패스워드는 contact@bacchus.snucse.org 로 보낼때 마스킹해야 한다.

## 자동화 스크립트

위와 같은 업무처리기준을 따라 자동화한 스크립트를 실행할 수 있다. [여기](https://github.com/bacchus-snu/work/tree/master/howto/src/id/cse) 에서 확인할 수 있다.

### 이메일 설정하기

`sendmail.sh` 에서 아래 값을 적절하게 수정해야 한다.

```bash
SENDER=jangho@bacchus.snucse.org
SMTP_SERVER=smtp.jangho.io:587
SMTP_USER=jangho@mango.jangho.io
SMTP_PASSWORD=$(pass system/hosts/mango/smtp.jangho.io/jangho@mango.jangho.io)
```

설정 후

```bash
echo 'test' | ./sendmail.sh me@example.com 'test'
```

를 통해 메일 발송이 잘 되는지 테스트하자. (`me@example.com` 은 자기 자신의 메일 주소로 수정한다.)

### 실행하기

만약 받은 계정 요청 메일에서, id.snucse.org 계정을 `accountName` 으로 했다고 하자. 또한 메일은 `requester@snu.ac.kr` 에서 왔다. 그러면 아래와 같이 실행한다.

```bash
./account.sh accountName requester@snu.ac.kr
```

만약, `@snu.ac.kr` 을 통해 오지 않은 메일이라 해도, 그 메일주소를 그대로 사용한다 (@snu.ac.kr 메일을 사용하라는 답변을 자동으로 써준다.)

```bash
./account.sh accountName requester@example.com
```

최초 실행시 id.snucse.org 와 cse.snu.ac.kr 로의 ssh 커넥션을 설정한다. 만약 처리해야 할 요청 메일이 여러개라면, 스크립트를 여러번 실행하면 된다. 이 때, 한 번 설정된 ssh 커넥션은 재사용된다.
