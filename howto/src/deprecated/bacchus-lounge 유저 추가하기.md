# bacchus-lounge 유저 추가하기

1. username을 신청 받고, pwgen을 이용해 password를 생성해놓는다.
    - 이하 신청받은 username을 _username_, 생성한 password를 _password_ 로 서술
1. https://znc.olmeca.snucse.org 에 접속한다.
    - user: bacchus
    - password: _Linux password_
1. `Manage users`에서 `Add`를 누른다.
    - __Authentication__
      - Username: _username_
      - Password: _password_
    - __IRC Information__
      - Nickname: _username_
      - Alt. Nickname: _username 뒤에 \_를 붙인다_
      - Ident: _username_
      - Realname: _username_
      - Quit Message: The Bacchus-Lounge - https://olmeca.snucse.org
    - __Channels__
      - Buffer size: 500
    - 다음과 같이 되게 하면 됨
      ![Authentication](img/bacchus-lounge-add-user-1.png)
      ![IRC-Information](img/bacchus-lounge-add-user-2.png)
1. `Create and Continue`를 눌러 일단 저장
1. `Networks`에서 `Add`를 누른다
    - __Network Info__
      - Network Name: UriIRC
      - 나머지는 user 생성할 때 적은 IRC Information으로 채워진다
1. `Hostname`, `Port` 등이 적힌 표 밑의 `Add`를 누른다.
    - 다음 hostname와 port를 추가한다.
      - `real.uriirc.org` 16667
      - `laika.uriirc.org` 16667
      - `evans.uriirc.org` 16667
    - 다음과 같이 되게 하면 됨
      ![Hostname](img/bacchus-lounge-add-user-3.png)
    > 이 howto를 작성할 당시에 UriIRC 서버의 인증서가 만료되어 접속이 안되는 상황이었다.  
    > 그럴 때는 `SHA-256 fingerprints of trusted SSL certificates of this IRC network`에 저 3 서버의 fingerprint를 입력해 override 해주자.
1. `Add network and Return`를 눌러 저장
1. olmeca에 접속해 `bacchus-lounge` 폴더에 들어간다. (`docker-compose.yml` 파일이 있는 폴더)
    ```bash
    $ docker-compose run thelounge thelounge add {USERNAME}
    20xx-xx-xx xx:xx:xx [PROMPT] Enter password: {PASSWORD}
    20xx-xx-xx xx:xx:xx [PROMPT] Save logs to disk? (yes) no
    20xx-xx-xx xx:xx:xx [INFO] User foouser created.
    ```
1. 크롬 secret tab 또는 파폭 private tab 등으로 https://olmeca.snucse.org 에 접속한다.
    - Username: _username_
    - Password: _password_
1. 접속이 되면 다음과 같이 설정한다.
    - Nick: _username_
    - Username: _username_/UriIRC
    - Password: _password_
    - Real name: _username_
    - 다음과 같이 하게 하면 됨
      ![thelounge-preference](img/bacchus-lounge-add-user-4.png)
1. UriIRC에 접속까지 성공시킨 채로 신청한 사람에게 발급 완료 메일을 보내면 된다.
