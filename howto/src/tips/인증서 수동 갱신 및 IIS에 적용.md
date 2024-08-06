## 지침: 인증서 수동 갱신 및 IIS에 이를 적용하기

작성자: 서장호, 성용운

### 이 지침의 범위

아래 사항에 대해 다룹니다.

* 수동으로 DNS 인증을 통해 snucse.org 및 하위 도메인에 대한 인증서를 취득하는 방법
* IIS 서버에 이 인증서를 적용하는 방법

다만 인증서 취득 방법은 snucse.org 도메인 서버로 certbot dns challenge에 사용 가능한 서비스를 사용한다는 가정 하에 작성되었습니다.

**주의**: IIS는 https를 통해 여러 도메인으로 한 사이트에 접속할 수 있는 환경에서 (i.e. 한 사이트에 대한 https 바인딩이 여러개일 때) 바인딩별로 다른 인증서를 선택하는게 안됩니다. 그러므로 해당되는 모든 도메인에 사용할 수 있는 하나의 인증서를 발급받아야 합니다.

### 수동으로 DNS 인증을 통해 snucse.org 및 하위 도메인에 대한 인증서 취득하기

#### 개요

* 인증서를 사용할 호스트와 인증서를 취득하는 호스트가 달라도 됩니다. (즉, Windows Server에서 사용할 인증서를 우분투 서버에서 취득할 수 있습니다.)
* 인증서를 사용할 호스트와 인증서를 취득하는 호스트 모두, TCP 80번과 443번 포트가 개방되어 있을 필요가 없습니다.
* snucse.org 도메인에 대해 자유롭게 TXT 레코드를 생성할 수 있어야 합니다. (즉, 정보화본부 DNS 서버를 사용한다면 적용할 수 없는 방법입니다!)
* 준비물
  * certbot이 깔린 머신
  * DNS 서버

#### 방법

예시로, `old.snucse.org` 인증서 하나를 발급해보겠습니다.

certbot이 깔린 머신에서 다음 명령어를 실행합니다.

```bash
sudo certbot certonly --manual --preferred-challenges dns -d old.snucse.org
# using cloudflare: /root/.secrets/certbot-cloudflare에 https://certbot-dns-cloudflare.readthedocs.io/en/stable/#credentials 와 같은 정보를 입력해둡니다
sudo certbot certonly -a dns-cloudflare -d old.snucse.org --dns-cloudflare-credentials /root/.secrets/certbot-cloudflare
```

> cloudflare-dns 을 사용한 경우, 인증서가 바로 발급됩니다. 바로 "취득한 인증서를 IIS에 적용하기" 로 건너뛸 수 있습니다.

> 참고: `mimosa.snucse.org`에는 `\*.snucse.org` 인증서를 사용하기 때문에 이미 certbot-cloudflare 파일 및 플러그인이 설정되어 있습니다.

그러면 `_acme-challenge.old.snucse.org` 에 TXT 레코드를 생성하라는 알림이 뜰 것입니다.

DNS 서버에 접속해서 시키는 대로 합니다. 예를 들어 `_acme-challenge.old.snucse.org` 에 대해서,

만약 `old.snucse.org` 도메인 영역이 없으면, 생성합니다.

![도메인생성](./img/letsencrypt-dns-challenge-create-domain.png)

`_acme-challenge.old.snucse.org` TXT 레코드를 만들고 certbot이 제시한 값을 채워넣습니다.

![레코드생성](./img/letsencrypt-dns-challenge-create-record.png)

시키는 대로 다 했으면 certbot이 알아서 인증서를 발급해줍니다.

### 취득한 인증서를 IIS에 적용하기

certbot이 깔린 머신에서, 해당 인증서가 존재하는 디렉토리 (예: `/etc/letsencrypt/live/old.snucse.org`) 로 간 다음,

```bash
openssl pkcs12 -export -in cert.pem -inkey privkey.pem -out cert.pfx -certfile chain.pem
```

이후 `cert.pfx` 를 노력해서 IIS가 깔린 윈도우 서버로 옮깁니다.

이 시점 이후로는 인증서를 발급받은 서버에 이 파일을 남겨둘 이유가 없으므로, `sudo certbot delete --cert-name [인증서 이름]` 으로 파일을 모두 지웁니다. 지우지 않으면 인증서가 자동갱신되어 인증서 만료 이메일을 받지 못할 수도 있습니다 (인증서는 갱신되었지만 IIS에 deploy하지 않았으므로 인증서 오류가 생깁니다.)

IIS 서버에서

1. 받은 `cert.pfx`를 더블클릭합니다.
2. 인증서 설치 마법사를 진행합니다. 이 때 설치 장소를 `웹 호스팅`으로 잡습니다.
3. IIS 관리자를 열고, 사이트를 선택하고, 오른쪽 메뉴에서 `바인딩`을 누르면 https 바인딩에 대한 인증서를 선택할 수 있습니다. 새로 설치한 인증서를 골라줍니다.
