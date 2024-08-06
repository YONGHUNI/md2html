우분투 서버 설치 및 파티션 설정하기.
========
> 작성자 : 노윤미, 이은서, 성용운

> Ubuntu 18.04 기준

## 설치 전
- 재설치라면 중요한 데이터 백업부터 하자.
- 혹시 모르니 `/etc`도 백업해두는게 좋다.
- `rsync -aPvn "/${source_dir}/" "root@${destination_host}:${destination_dir}"`으로 확인한다. Trailing `/`에 유의.
	- `-a`는 왠만한 metadata(owner, permission, atime, mtime 등등)를 유지해준다. 양쪽에 root유저로 접속해야 한다.
- `rsync -aPv "/${source_dir}/" "${destination_host}:${destination_dir}"`로 파일을 옮긴다. 오래 걸릴 수 있으니 `tmux`같은거 안에서 돌리자.
	- 여러번 돌릴거면 `--delete`을 넣어주는게 좋다. `rsync(1)` 참고.

## 설치 시 주의사항
- `isolinux.bin missing or corrupt`라는 메시지가 나올 때는 `BIOS setting`에서 `USB Flash Drive Emulation Type`을 `auto`에서 `hard drive`로 바꿔줍니다.
- hostname : 서버 이름과 똑같이 한다.
- username : `bacchus`
- mirror: http://mirror.snucse.org/ubuntu/
- 내트워크:
	- 주소에는 서버 ip를 입력한다. [이 문서](https://drive.google.com/open?id=1P_fADVs9LJ1xee0VdylUlsEK5yBlYvpZ1nuvFPFqHhk)를 참고.
	- DNS는 `147.46.80.1,147.46.37.10`을 입력한다.
	- 안 쓰는 interface는 다 disable하도록 한다.

- 그 외 잡다한 것은 default 설정을 따라가도록 한다

## 파티션 설정: manual
- 그렇게 큰 / 중요한 서버가 아니면 automatic써도 문제없다.
- 가능하면 `/{cse}home`같이 아주 커질 수 있는 디렉터리는 따로 만들어주는게 좋다.
- 여러 유저가 쓰는 서버라면 `/var`도 따로 만들어두자. 50-100GiB정도면 충분하다.
- 위와 같이 파티셔닝했다면 `/`는 그렇게 클 필요가 없다. 50-100GiB정도면 충분하다.
- SWAP이나 `/boot`, EFI등은 알아서 다 해준다. 딱히 수동 설정할 이유가 없으면 따로 설정해줄 필요는 없다.

## 설치 후
- 시간대 설정: `timedatectl set-timezone Asia/Seoul`
- SSH hardening: `PermitRootLogin no`. 실수로 root 로그인 가능하게 설정할 수 없도록 필요할때만 켜두자.
- 패키지 업데이트 설치 & reboot
- locale: `/etc/locale.gen`에서 `ko_KR.UTF-8 UTF-8` 주석 없에주고 `locale-gen`
- 22번 포트 외부접속이 열려있는 서버라면 `apt install fail2ban`.

## ID 연동
NSS와 PAM를 따로 한다.

### NSS
- `apt install nsscache libnss-cache`
- nsscache 설정:

```
[DEFAULT]
source = http
maps = passwd, group
# 따로 만들어줘야한다
http_passwd_url = https://id.snucse.org/api/nss/passwd
http_group_url = https://id.snucse.org/api/nss/group
```

- NSS 설정: `/etc/nsswitch.conf`에서 passwd랑 group 뒤에 `cache` 추가.
- Systemd unit 추가:

```
# /etc/systemd/system/nsscache.service
[Unit]
Description=nsscache update service

[Service]
Type=oneshot
ExecStart=/usr/sbin/nsscache -v update

# /etc/systemd/system/nsscache.timer
[Unit]
Description=Update nsscache regularly

[Timer]
OnCalendar=hourly

[Install]
WantedBy=timers.target
```

- `systemctl start nsscache.{service,timer} && systemctl enable nsscache.timer`
- 확인: `getent passwd`

### PAM
- `apt-add-repository ppa:bacchus-snu/lab && apt install pam-bacchus`

```
# /etc/pam.d/common-auth
# here are the per-package modules (the "Primary" block)
auth	[success=2 default=ignore]	pam_unix.so nullok_secure # success=2 로 수정
auth	[success=1 default=ignore]	pam_bacchus.so url=https://id.snucse.org/api/login/pam # 추가
# here's the fallback if no module succeeds
auth	requisite			pam_deny.so
# [...]

# /etc/pam.d/common-account
# here are the per-package modules (the "Primary" block)
account	[success=2 new_authtok_reqd=done default=ignore]	pam_unix.so # success=2 로 수정
account	[success=1 default=ignore]	pam_succeed_if.so quiet user ingroup cseusers # 추가
# here's the fallback if no module succeeds
account	requisite			pam_deny.so
# [...]

# /etc/pam.d/common-session
# 홈디렉터리 만들어줘야하면
session	required	pam_mkhomedir.so umask=0077 # 멘 아레에 추가
```
