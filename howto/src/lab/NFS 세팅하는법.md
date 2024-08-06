NFS 서버 세팅하는법
========
> 김지현 노윤미

1.  NFS 서버 프로그램을 설치해준다.

    ```bash
    sudo apt-get install nfs-kernel-server
    ```

1.  NFS로 공유시킬 디렉토리를 원하는곳에 만든다.

    ```bash
    sudo mkdir -p /csehome
    ```

1.  NFS 환경설정 파일인 `/etc/exports` 파일을 아래와 같이 고친다.

    ```
    # 소실/하실 IP 목록
    /csehome 147.46.78.45(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.44(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.43(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.42(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.41(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.40(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.39(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.38(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.242.253(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.242.251(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.242.246(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.242.224(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.242.220(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.242.183(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.242.192(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.242.191(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.242.190(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.242.189(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.48(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.242.151(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.240.251(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.240.221(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.240.217(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.240.213(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.240.207(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.240.205(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.240.132(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.240.117(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.240.65(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.240.69(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.240.58(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.161(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.111(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.110(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.109(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.108(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.107(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.106(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.105(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.53(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.104(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.103(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.102(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.101(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.100(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.99(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.98(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.97(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.96(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.95(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.94(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.93(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.92(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.91(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.90(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.89(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.88(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.87(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.86(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.241.85(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.190(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.191(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.192(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.193(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.194(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.195(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.196(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.197(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.198(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.199(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.200(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.201(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.202(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.203(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.204(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.205(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.206(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.207(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.208(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.209(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.210(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.211(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.212(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.213(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.214(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.215(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.216(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.217(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.218(rw,sync,no_subtree_check,no_root_squash)
    /csehome 147.46.78.219(rw,sync,no_subtree_check,no_root_squash)
    ```

    각 라인은 아래와 같은 의미를 가지고있다.
    ```
    <공유할 디렉토리 경로> <접속을 허용할 IP>(옵션1,옵션2,옵션3)
    ```

    ###### References
    - [`man 5 exports`](http://linux.die.net/man/5/exports)
    - [왜 `no_subtree_check` 옵션을 줘야하나요?](http://nfs.sourceforge.net/#faq_c7)

1.  아래 커맨드를 실행하여, `/etc/exports` 파일의 수정사항을 리로드해준다.

    ```bash
    sudo service nfs-kernel-server reload
    ```


# NFS 클라이언트 세팅하는 법
> 이소희 이은서
<br>

- NFS(Network File System)은 클라이언트 컴퓨터에서 네트워크 상의 파일을 로컬 파일처럼 접근할 수 있도록 해주는 파일 시스템 프로토콜이다.
- 이 문서는 NFS를 통해 Arch Linux 클라이언트에서 Ubuntu 서버 상의 홈 디렉토리에 접근할 수 있도록 하기 위해 작성되었다. 
- 이 문서에서는  Arch Linux 클라이언트에 NFS를 설치하고 설정하는 방법에 대해서 다룰 것이다.

## 1. 설치

`nfs-utils` 패키지를 설치한다.
```bash
sudo pacman -S nfs-utils
```

클라이언트/서버 시간이 동기화 되지 않으면 딜레이가 발생할 수 있으므로 [ntp](https://www.archlinux.org/packages/?name=ntp)를 통해 동기화 하는 것이 바람직하나, 클라이언트/서버가 네트워크 시간과 각각 동기화하고 있으므로 생략한다.
<br>

## 2. 설정

먼저 `rpcbind`, `nfs-client.target` 그리고 `remote-fs.target`을 start 한 후, 부팅 시마다 start 되도록 모두 enable 한다.
```bash
sudo systemctl start rpcbind nfs-client.target remote-fs.target
sudo systemctl enable rpcbind nfs-client.target remote-fs.target
```

그 후 마운트 설정이 영구적으로 저장되도록 `/etc/fstab` 파일을 수정한다. `/etc/fstab` 파일 끝에 설정을 한 줄 덧붙이면 된다.
여러 방법이 있지만 그 중 systemd의 `automount` 서비스를 이용하는 방법을 사용한다.

```
servername:/home   /mountpoint/on/client  nfs  noauto,x-systemd.automount,x-systemd.device-timeout=10,timeo=14,x-systemd.idle-timeout=1min 0 0
```
실제 사용 시에는 sherry를 서버로, '/csehome'이 NFS를 통해 접근할 디렉토리이므로 다음과 같이 덧붙였다.
```
sherry.snucse.org:/csehome /csehome nfs  noauto,x-systemd.automount,x-systemd.device-timeout=10,timeo=14,x-systemd.idle-timeout=1min 0 0
```
`/etc/fstab` 파일의 변경사항을 systemd가 인식하도록 하려면 재부팅을 하는 것이 좋다.
<br>

## 참고 문서
[NFS - ArchWiki](https://wiki.archlinux.org/index.php/NFS)

