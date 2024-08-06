locale 생성과 설정
========

OS별로 locale 설정하는 법이 다르다. 컴공과에서 접속하면 보통은 `ko_KR.UTF-8` locale을 요구할 것이므로, 서버에서 미리 이를 만들어 주는 것이 좋다.

### Ubuntu
```bash
sudo locale-gen ko_KR.UTF-8
```

### Arch
Arch Linux에서는 먼저 `/etc/locale.gen`을 수정한다. `vim` 등의 에디터를 사용해 `/etc/locale.gen`을 연 뒤, `ko_KR.UTF-8`이 있는 줄을 찾아 맨 앞에 있는 주석 표시(`#`)를 지운다. 그 후 다음 명령어를 실행한다.

```sh
sudo locale-gen
```
