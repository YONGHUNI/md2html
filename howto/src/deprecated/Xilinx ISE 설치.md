64-bit 아치리눅스에서 Xilinx ISE를 설치하는 방법을 기록한다.

## 준비 사항

`sudo vim /etc/pacman.conf` 에서 아래 부분을 주석 해제한다.

```
[multilib]
Include = /etc/pacman.d/mirrorlist
```

추가 패키지를 설치한다.

```
sudo pacman -Sy lib32-glibc lib32-ncurses
```

라이브러리 링크를 맞추어준다.

```
cd /usr/lib
ln -s libncursesw.so.6 libncurses.so.5
```

## 설치

아래 링크에서 ISE Design Suite - Full Installer for Linux 를 다운받는다.

https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive-ise.html

압축을 풀고 `sudo ./xsetup` 을 실행하여 설치한다.

## 실행 아이콘 만들기

관리자 권한으로 아래 내용을 `/opt/run_Xilinx_ise` 에 붙여넣고 `sudo chmod +x /opt/run_Xilinx-ise` 로 실행 가능하게 한다.

```
#!/usr/bin/env sh
source /opt/Xilinx/14.7/ISE_DS/settings64.sh
ise
```

관리자 권한으로 아래 내용을 `/usr/share/applications/xilinx-ise.desktop` 에 붙여넣는다.

```
[Desktop Entry]
Name=ISE Project Navigator
Comment=Xilinx ISE Project Navigator
Exec="/opt/run_Xilinx_ise"
Terminal=false
Type=Application
Icon=xilinx-ise.svg
StartupNotify=true
```

xilinx-ise.svg 아이콘은 Numix-circle 패키지를 설치할때 깔려있다고 가정한다.

`/opt/run_Xilinx_ise` 라는 파일명은 바꾸어도 상관은 없는데 (이 경우 Exec에 있는 값도 알맞게 바꾸어야 한다.) `xilinx-ise.desktop` 이라는 이름은 바꾸면 아이콘이 제대로 뜨지 않으므로 조심하자.

## 라이센스 활성화

라이센스 파일을 받아서 아래 경로에 넣는다.

```
/opt/Xilinx/14.7/ISE_DS/ISE/coregen/core_licenses/
```

## 설치 후 땜질

```
cd /opt/Xilinx/14.7/ISE_DS/ISE/lib/lin64/
mv libstdc++.so libstdc++.so-orig
mv libstdc++.so.6 libstdc++.so.6-orig
mv libstdc++.so.6.0.8 libstdc++.so.6.0.8-orig
ln -s /usr/lib/libstdc++.so
ln -s libstdc++.so libstdc++.so.6
ln -s libstdc++.so libstdc++.so.6.0.8

cd /opt/Xilinx/14.7/ISE_DS/common/lib/lin64
mv libstdc++.so libstdc++.so-orig
mv libstdc++.so.6 libstdc++.so.6-orig
mv libstdc++.so.6.0.8 libstdc++.so.6.0.8-orig
ln -s /usr/lib/libstdc++.so
ln -s libstdc++.so libstdc++.so.6
ln -s libstdc++.so libstdc++.so.6.0.8
```

## 참고자료

* https://wiki.archlinux.org/index.php/Xilinx_ISE_WebPACK
