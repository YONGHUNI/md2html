# GPU 서버 재설치

## 목차
```
1. 시스템 재설치
    1.1. 재설치에 필요한 패키지 설치
    1.2. 파일시스템 구성
        1.2.1. btrfs 구조
        1.2.2. 디스크 파티션 구조
        1.2.3. btrfs 작업
    1.3. Arch Linux 재설치
        1.3.1. nscd 정지
        1.3.2. 파일 시스템 마운트
        1.3.3. Arch Linux 설치
        1.3.4. 시스템 세팅
    1.4. bootloader 구성
        1.4.1. GRUB 설치
        1.4.2. config 파일 작성
    1.5. `/host-specific` 마운트
        1.5.1. initcpio hook 작성
        1.5.2. initramfs 이미지 생성
    1.6. 재부팅
    1.7. 기존 subvolume 정리하기
2. 설치 후 작업
    2.1. mirrorlist 정리하기
    2.2. yay 설치
    2.3. anaconda 설치
    2.4. 통합계정 연동
        2.4.1. libnss-cache 설치 및 설정
        2.4.2. pam-bacchus 설치 및 설정
        2.4.3. nfs 마운트
    2.5. ssh 키 고정하기
    2.6. fail2ban 활성화
    2.7. 뒷정리
    2.8. 나머지 서버 재설치
부록
```

## 작업 과정

### 1. 시스템 재설치
#### 1.1. 재설치에 필요한 패키지 설치
기존에 돌고 있던 환경에 재설치를 위해 필요한 패키지를 아래와 같이 설치합니다.
```sh
pacman -S arch-install-scripts
```

#### 1.2. 파일시스템 구성
##### 1.2.1. btrfs 구조
GPU 서버는 btrfs 파일시스템을 이용하며 재설치 완료 후 아래와 같은 구조를 갖게 됩니다.
```
┬  / (btrfs top level)
├  root (subvolume)
├  home (subvolume)   # home directory for bacchus
├  host-specific (subvolume)
└  snapshots (directory)
```

`root` subvolume은 `/`에 마운트 되며 시스템 업그레이드 시 btrfs의 send/receive 기능을 이용하여 업데이트 됩니다.  
따라서 이 subvolume은 모든 GPU 서버에서 동일한 내용을 가져야 하며, 리눅스 커널, initramfs 등을 포함해야 합니다.

host에 따라 달라져야 하는 파일들(hostname, ip 설정 등)은 `host-specific` subvolume에 놓습니다.  
그리고 subvolume을 `/host-specific`에 마운트 한 후 파일들의 심볼릭 링크를 만듭니다.

##### 1.2.2. 디스크 파티션 구조
모든 host마다 파티션의 UUID가 다르므로, 모든 host가 동일한 방법으로 파티션을 마운트할 수 있도록 아래와 같이 라벨을 붙였습니다.
EFI 파티션은 root 파티션이 커널과 initramfs를 포함하도록 `/boot/efi`에 마운트 되어야 합니다.

partition | format | label | mount point
-- | -- | -- | --
/dev/sda1 | FAT32 | EFI | /boot/efi
/dev/sda2 | swap | swap | [swap]
/dev/sda3 | btrfs | gpu-server-btrfs | /, /home, /host-specific

##### 1.2.3. btrfs 작업
btrfs의 toplevel을 마운트한 후 기존의 `root` subvolume의 이름을 바꾼 후 새로운 subvolume을 만듭니다.
```sh
mount -o discard,compress=lzo,subvol=/ /dev/disk/by-label/gpu-server-btrfs /root/btrfs-toplevel
btrfs property set -ts /root/btrfs-toplevel/root ro false
mount -o remount,rw /
mv /root/btrfs-toplevel/root /root/btrfs-toplevel/old-root
mv /root/btrfs-toplevel/home /root/btrfs-toplevel/old-home
mv /root/btrfs-toplevel/host-specific /root/btrfs-toplevel/old-host-specific
btrfs subvolume create /root/btrfs-toplevel/root
btrfs subvolume create /root/btrfs-toplevel/home
btrfs subvolume create /root/btrfs-toplevel/host-specific
```

#### 1.3. Arch Linux 재설치
##### 1.3.1. nscd 정지
nscd가 켜져 있으면 chroot 내에서의 사용자 생성이 정상적으로 되지 않아, nscd를 정지해야 합니다.
```sh
systemctl stop nscd
```

##### 1.3.2. 파일 시스템 마운트
```sh
mount -o discard,compress=lzo,subvol=/root /dev/disk/by-label/gpu-server-btrfs /mnt
mkdir /mnt/home
mkdir /mnt/host-specific
mount -o discard,compress=lzo,subvol=/home /dev/disk/by-label/gpu-server-btrfs /mnt/home
mount -o discard,compress=lzo,subvol=/host-specific /dev/disk/by-label/gpu-server-btrfs /mnt/host-specific
mkdir -p /mnt/boot/efi
mount -o discard /dev/disk/by-label/EFI /mnt/boot/efi
mkdir /mnt/var
mkdir /mnt/host-specific/var
mount --bind /mnt/host-specific/var /mnt/var
mkdir /mnt/pacman
mkdir -p /mnt/var/lib/pacman
mount --bind /mnt/pacman /mnt/var/lib/pacman
```

##### 1.3.3. Arch Linux 설치
아래와 같이 base 패키지를 설치하고 fstab 파일을 만듭니다. 이후 fstab를 열어 host마다 다를 수 있는 btrfs의 마운트 옵션 중 subvol id 부분을 지우고 subvol만 남겨둡니다.
사용한 fstab 파일은 아래 부록에 있습니다.

```sh
pacstrap /mnt base base-devel intel-ucode python-pip vim
genfstab -L /mnt >> /mnt/etc/fstab
```

##### 1.3.4. 시스템 세팅
`arch-chroot /mnt` 후 시스템 세팅을 진행합니다. 먼저 `linux-lts` 를 비롯한 필요한 패키지들을 설치합니다.
```sh
arch-chroot /mnt
pacman -S linux-lts nvidia-lts grub efibootmgr openssh man-pages man-db \
   git cmake htop tmux unzip p7zip btrfs-progs nfs-utils fail2ban \
   python-tensorflow-cuda python-pytorch-cuda clinfo
```

그 다음 네트워크 설정을 진행합니다. 이는 host마다 달리지는 설정이므로 `/host-specific` 폴더 내에 파일을 만든 후 심볼릭 링크를 걸어줍니다.
link | target
-- | --
/etc/hostname | ../host-specific/hostname
/etc/systemd/network/50-snunet.network | ../../../host-specific/50-snunet.network

`/etc/locale.gen` 파일에서 `en_US.UTF-8 UTF-8`과 `ko_KR.UTF-8 UTF-8` 문장의 주석을 푼 후 `locale-gen`을 실행합니다. 그리고 `/etc/locale.conf` 파일을 생성합니다.
```sh
vim /etc/locale.gen
(필요한 locale을 uncomment)
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
```

`bacchus` 계정을 생성한 후 `wheel` 그룹에 추가하여 `sudo` 권한을 부여합니다.
```sh
useradd -m -G wheel bacchus
passwd bacchus
(패스워드 입력)
echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
```

#### 1.4. bootloader 구성
커널과 initramfs가 btrfs 파일시스템 안에 있으므로 btrfs를 지원하는 bootloader를 사용해야 합니다. 

##### 1.4.1. GRUB 설치
아래와 같이 GRUB을 설치합니다.
```sh
grub-install --target=x86_64-efi --efi-directory=/boot/efi/ --bootloader-id=grub --recheck
```

##### 1.4.2. config 파일 작성
GRUB의 config 파일은 `/boot/grub/grub.cfg`에 저장됩니다. 이 파일을 자동으로 생성해주는 `grub-mkconfig`라는 툴이 있고, 일반적으로 이를 사용합니다. 하지만 이 툴을 사용하면 root 파일시스템을 찾을 때 UUID를 사용하도록 설정되므로 파일시스템의 라벨을 이용하도록 직접 config 파일을 작성하였습니다. 작성한 config 파일은 문서의 아래 부록에 있습니다.

#### 1.5. `/host-specific` 마운트
`/host-specific`은 부팅에 필요한 정보를 담고 있으므로 init 프로세스(systemd)가 실행되기 전에 마운트되어야 합니다. 따라서 `/host-specific`의 마운트는 initramfs에서 수행하도록 설정합니다.

##### 1.5.1. initcpio hook 작성
> 주의
>
> 이 방법은 Arch Linux에서 사용 가능한 방법으로, 다른 배포판에 적용하려면 다른 방법을 사용해야 할 수 있습니다.

`/etc/initcpio/hooks/host-specific`, `/etc/initcpio/install/host-specific` 파일을 작성하여 `host-specific`이란 이름의 hook을 만듭니다. 두 hook 파일의 내용은 아래 부록에 있습니다. 그 다음 `/etc/mkinitcpio.conf` 파일을 열어 `host-specific` hook을 추가해줍니다.
```
HOOKS=(base udev autodetect modconf block filesystems host-specific keyboard fsck)
```

##### 1.5.2. initramfs 이미지 생성
설정을 완료한 후 아래와 같이 새로운 initramfs 이미지를 생성합니다.
```sh
mkinitcpio -p linux-lts
```

#### 1.6. 재부팅
먼저 ssh 활성화 및 네트워크 설정을 완료합니다.
```sh
systemctl enable sshd
systemctl enable systemd-networkd
systemctl enable systemd-timesyncd
systemctl enable systemd-resolved
```

그 다음 `exit`을 통해 새로운 시스템을 빠져나온 다음, btrfs의 default subvolume을 `root`로 변경합니다.
```sh
exit
(정상적으로 빠져나왔는지 확인하기)
btrfs subvolume set-default /root/btrfs-toplevel/root
```

마지막으로 `reboot` 을 진행합니다. 약 1~2분 정도의 시간이 소요됩니다. 만약 ssh가 붙지 않는다면 침착하게 usb 부팅 디스크를 가지고 서버실로 향하도록 합시다.

#### 1.7. 기존 subvolume 정리하기
부팅이 정상적으로 되었다면 더 이상 사용하지 않는 subvolume을 정리합니다.
```sh
mkdir /root/btrfs-toplevel
mount -o subvol=/ /dev/sda3 /root/btrfs-toplevel/
btrfs subvolume delete /root/btrfs-toplevel/old-root
btrfs subvolume delete /root/btrfs-toplevel/old-host-specific
btrfs subvolume delete /root/btrfs-toplevel/old-home
```

### 2. 설치 후 작업

#### 2.1. mirrorlist 정리하기
`/etc/pacman.d/mirrorlist` 에는 pacman이 사용하는 mirror 서버의 리스트가 들어있습니다.  
미러 리스트를 많이 들고 있을 필요는 없으므로 2~3개만 남겨두고 지웁니다. 여기서는 `premi.st`와 `lanet.kr`을 남겨두었습니다.

#### 2.2. yay 설치
GPU 서버에 필요한 패키지들을 설치하다보면 AUR 패키지를 이용하는 경우가 있습니다.  
이러한 패키지들을 쉽게 설치하기 위해 [`yay`](https://github.com/Jguer/yay)라는 pacman wrapper를 설치합니다.
```sh
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

#### 2.3. anaconda 설치
Arch Linux의 정책 상 GPU 서버는 모든 패키지를 일괄적으로 최신 버전으로 유지하는 것을 목표로 합니다.  
다만 ML 프레임워크는 빠르게 버전업이 진행되고 있으며, 유저에 따라서 요구하는 프레임워크의 버전이 다른 경우가 있을 수 있습니다.  
이를 해결하기 위해 `anaconda`를 설치한 후, 유저가 필요한 경우 anaconda를 이용하여 가상환경을 구축하도록 안내합니다.  
```sh
yay -S anaconda
```

#### 2.4. 통합계정 연동
##### 2.4.1. libnss-cache 설치 및 설정
먼저 `libnss-cache` 패키지를 설치합니다.
```sh
yay -S libnss-cache
```

그 다음 `/etc/nsswitch.conf` 파일의 `passwd` 라인과 `group` 라인에 `cache` 모듈을 추가합니다.
```
passwd: files mymachines systemd cache
group: files mymachines systemd cache
```

마지막으로 `id` 서버의 `nss` API endpoint로 요청을 날려 `passwd.cache`와 `group.cache` 파일을 가져옵니다.  
이 파일들은 주기적으로 동기화가 되어야하므로, `/host-specific` 폴더 내에 파일을 만든 후 심볼릭 링크를 걸어줍니다.

```sh
mkdir /host-specific/nsscache
curl https://id.snucse.org/api/nss/passwd > /host-specific/passwd.cache
curl https://id.snucse.org/api/nss/group > /host-specific/group.cache
cd /etc
ln -rsf ../host-specific/nsscache/passwd.cache
ln -rsf ../host-specific/nsscache/group.cache
```

위의 과정을 마쳤다면 `getent passwd`를 실행하여 계정 정보가 정상적으로 들어갔는지 확인합니다.

##### 2.4.2. pam-bacchus 설치 및 설정
먼저 `pam-bacchus` 패키지를 설치합니다.
```sh
git clone https://github.com/bacchus-snu/arch-packaging.git
cd arch-packaging/pam_bacchus
makepkg -si
```

그 다음 `/etc/pam.d/system-auth` 파일을 열고 제일 위에 다음 두 줄을 추가합니다.
```
auth       sufficient                  pam_bacchus.so       url=https://id.snucse.org/api/login/pam
account    sufficient                  pam_succeed_if.so    quiet user ingroup cseusers
```

설정을 마쳤다면 서버 로그인을 시도해봅니다. 로그인이 정상적으로 진행되지 않는다면 위 과정을 다시 점검해봅니다.

##### 2.4.3. bacchus-nss-sync 설치 및 설정
먼저 `bacchus-nss-sync` 패키지를 설치합니다.  
이 패키지는 위에서 추가한 `passwd.cache` 파일과 `group.cache` 파일을 주기적으로 동기화를 하는 역할을 합니다.
```sh
cd ../bacchus-nss-sync
makepkg -si
```

패키지를 설치하였으면 다음을 실행하여 타이머를 enable 합니다.
```sh
systemctl enable --now bacchus-nss-sync.timer
```

##### 2.4.4. nfs 마운트
GPU 서버 유저가 사용할 홈 폴더인 `/csehome`을 `oloroso` 서버의 `/csehome`으로 nfs 마운트를 합니다.
`/etc/systemd/system/csehome.mount` 파일을 추가해줍니다. 파일의 내용은 아래 부록에 있습니다.  
파일을 추가하였으면 다음을 실행하여 nfs 마운트가 부팅 시 자동으로 되도록 등록합니다.
```sh
systemctl enable --now csehome.mount
```

다시 로그인을 진행하여 사용자가 정상적으로 `/csehome` 폴더를 접근하는지 확인합니다.

#### 2.5. ssh 키 고정하기
ssh 키는 `/etc/ssh` 에 저장되는데, 이 키들 역시 머신마다 고유한 파일이므로 `/host-specific` subvolume에 넣습니다.
```sh
mkdir /host-specific/ssh
cp /etc/ssh/ssh_host_* /host-specific/ssh
```

그 다음 `/etc/ssh/sshd_config` 파일을 열어서 다음 네 줄을 추가합니다.
```
HostKey /host-specific/ssh/ssh_host_rsa_key
HostKey /host-specific/ssh/ssh_host_ecdsa_key
HostKey /host-specific/ssh/ssh_host_ed25519_key
HostKey /host-specific/ssh/ssh_host_dsa_key
```

#### 2.6. fail2ban 활성화
`/etc/fail2ban/jail.local` 파일을 작성한 후 fail2ban을 활성화합니다. 만일의 경우를 대비해 바쿠스 동아리방 공유기 IP는 차단 대상에서 제외합니다.  
```sh
systemctl enable --now fail2ban
```

#### 2.7. 정리정돈

bacchus 계정의 홈 디렉토리에 받은 각종 파일들을 모두 삭제합니다. 그리고 root 계정을 잠급니다.
```sh
passwd -dl root
```

그 다음 `root` subvolume의 read-only property를 true로 설정합니다. 이는 관리자가 실수로 특정 서버에만 패키지를 설치하거나 업데이트를 하지 않도록 거는 안전장치입니다.
```sh
btrfs property set -ts /root/btrfs-toplevel/root ro true
```

마지막으로 `reboot`을 다시 실행하여 재설치를 마칩니다.

#### 2.8 나머지 서버 재설치

위의 과정을 나머지 서버 5대에 대해서도 동일하게 진행합니다.  
만약 btrfs subvolume의 구조가 동일하고 `host-specific` subvolume 내의 파일이 바뀔 이유가 없다면 btrfs send/receive를 이용하여 `root` subvolume을 배포하면 됩니다. 자세한 내용은 [GPU 서버 관리 및 업데이트](https://github.com/bacchus-snu/work/blob/master/howto/GPU%20%EC%84%9C%EB%B2%84%20%EA%B4%80%EB%A6%AC%20%EB%B0%8F%20%EC%97%85%EB%8D%B0%EC%9D%B4%ED%8A%B8.md) 문서를 참고하십시오.

## 부록
### 파일들
* `/etc/fstab`
```
# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>
LABEL=gpu-server-btrfs  /               btrfs           rw,relatime,compress=lzo,ssd,discard,space_cache,subvol=/root   0 0
LABEL=EFI               /boot/efi       vfat            rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro,discard       0 2
LABEL=gpu-server-btrfs  /home           btrfs           rw,relatime,compress=lzo,ssd,discard,space_cache,subvol=/home   0 0
LABEL=gpu-server-btrfs  /host-specific  btrfs           rw,relatime,compress=lzo,ssd,discard,space_cache,subvol=/host-specific  0 0
LABEL=gpu-server-btrfs  /local          btrfs           rw,relatime,compress=lzo,ssd,discard,space_cache,subvol=/local  0 0
LABEL=gpu-server-btrfs  /root/btrfs-toplevel    btrfs           rw,relatime,compress=lzo,ssd,discard,space_cache,subvol=/,noauto        0 0
LABEL=swap              none            swap            defaults        0 0
/host-specific/var      /var            none            bind            0 0
/pacman                 /var/lib/pacman none            bind            0 0
```

* `/boot/grub/grub.cfg`
```
insmod part_gpt
insmod btrfs

if [ "${next_entry}" ] ; then
   set default="${next_entry}"
   set next_entry=
   save_env next_entry
   set boot_once=true
else
   set default="0"
fi

if [ "${prev_saved_entry}" ]; then
  set saved_entry="${prev_saved_entry}"
  save_env saved_entry
  set prev_saved_entry=
  save_env prev_saved_entry
  set boot_once=true
fi

function load_video {
  if [ x$feature_all_video_module = xy ]; then
    insmod all_video
  else
    insmod efi_gop
    insmod efi_uga
    insmod ieee1275_fb
    insmod vbe
    insmod vga
    insmod video_bochs
    insmod video_cirrus
  fi
}

terminal_input console
terminal_output gfxterm
if [ x$feature_timeout_style = xy ] ; then
  set timeout_style=menu
  set timeout=1
# Fallback normal timeout code in case the timeout_style feature is
# unavailable.
else
  set timeout=1
fi

menuentry 'Arch Linux' {
  load_video
  set gfxpayload=keep
  insmod gzio
  search --set=root --label gpu-server-btrfs

  echo  'Loading Linux linux-lts ...'
  linux  /root/boot/vmlinuz-linux-lts root=LABEL=gpu-server-btrfs rw rootflags=compress=lzo,subvol=/root
  echo  'Loading initial ramdisk ...'
  initrd  /root/boot/intel-ucode.img /root/boot/initramfs-linux-lts.img
}
```

* `/etc/initcpio/hooks/host-specific`
```
#!/usr/bin/ash

run_latehook() {
    mount -o discard,compress=lzo,subvol=/host-specific /dev/disk/by-label/gpu-server-btrfs /new_root/host-specific
}
```

* `/etc/initcpio/install/host-specific`
```
#!/bin/bash

build() {
    add_runscript
}

help() {
    cat <<HELPEOF
This hook mounts host-specific directory for gpu server via a late running hook.
HELPEOF
}
```

* `/etc/systemd/system/csehome.mount`
```
[Unit]
Description="Home directory for cseusers"
After=network.target

[Mount]
What=147.46.241.60:/csehome
Where=/csehome
Type=nfs4
Options=rsize=32768,wsize=32768

[Install]
WantedBy=multi-user.target
```

* `/etc/fail2ban/jail.local`
```
[DEFAULT]
# "bantime" is the number of seconds that a host is banned.
bantime  = 2d
# A host is banned if it has generated "maxretry" during the last "findtime" seconds.
findtime  = 1d
# "maxretry" is the number of failures before a host get banned.
maxretry = 10
# "ignoreip" can be a list of IP addresses, CIDR masks or DNS hosts. Fail2ban
# will not ban a host which matches an address in this list. Several addresses
# can be defined using space (and/or comma) separator.
ignoreip = 147.46.113.120

[sshd]
enabled = true
```
