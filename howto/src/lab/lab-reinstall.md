# 실습실 재설치

## 0. Notes

- `CHANGEME`는 특별한 주의가 필요한 내용이다. 복붙하면 안된다.
- rootfs를 다시 만들고 bootloader 까지 재설치하는 기준으로 작성했는데, rootfs를 유지하는 경우에는 작업 후 6번 (Deploy) 부터 따라하면 된다.

## 1. Timeline

다음 태이블은 rough recommendation이다.

date | event
---- | -----
학기 시작 2~3주 전 | 실습환경 접수 설문 발송
학기 시작 1주 전 | 실습환경 접수 설문 마감
학기 시작 이전 주, 배포 이후 | 실습실 설정 확인 요청
(봄학기) 6월 말일 / (가을학기) 12월 말일 | 실습환경 사용기한

### 1.1 실습환경 접수

- `lab@cse.snu.ac.kr` 이메일로 실습환경 접수 설문 링크를 보낸다.
- 설문은 이전 학기 구글 폼을 복사해서 수정하면 된다.
- 날짜, 특히 사용 기한을 업데이트한다.
  - 사용기한은 다음 재설치에 필요한 시간을 고려하여 6월/12월 말일 정도로 설정한다.
- VM에 기본으로 설치되는 버전도 최신 버전으로 업데이트한다.
  - VM 관련 상세 내용은 [실습용 VM 발급](lab-vm.md) 문서 확인.
- 접수 마감 후 응답을 확인하고, 일반적으로 특정 설정을 요구하는 수업에서 해당 설정을 요청하지 않은 경우 확인 이메일을 보낸다.
  - 예: 논리설계 수업에서 Xilinx 소프트웨어를 요청하지 않은 경우.

## 2. Partitioning

- 보통 full 재설치를 하는 경우에도 partitioning을 다시 할 필요는 없다.
  - 주로 이미 있는 partition에 새로운 OS만 설치하는 식.
- 일부 실습실 켬퓨터에는 swap partition이 있는데, 사용하지 않는다.

label | size | filesystem
----- | ---- | ----------
bacchus-esp | 512Mi | vfat
bacchus-root | all remaining space | btrfs

### 2.1. btrfs volume layout

`[]` 으로 감싸져있는 label은 subvolume, 그렇지 않으면 일반 directory.

```
/             - mounted on /root/btrfs-root
├── [root]    - mounted on /
├── snapshots - read-only snapshots for deployment
│   └── [$(date -Isecond)]-$name]
├── trash     - subvolumes to be deleted, used during root switching
├── [csehome] - mounted on /csehome
└── [log]     - mounted on /var/log
```

## 3. Bootstrap

- 빈 directory에 debian을 설치하는 단계.
- `btrfs-root/root` 에 설치하는데, 이미 있는 경우 (실습실에서 작업하는 경우) 기존 root를 trash로 옮기고 빈 btrfs subvolume을 생성하면 된다.
- mmebstrap을 사용한다. `apt install mmdebstrap`

```bash
#!/usr/bin/env bash

args=(
    # install essential, important, required, and standard packages
    --variant=standard
    # we must run as true root to create a root filesystem with correct ownership
    --mode=root
    # create a bootable directory
    # also possible to do this on a separate system, without true root, with --format=tar
    --format=directory

    # install additional packages
    --components='main contrib non-free non-free-firmware'
    # make the system bootable
    # bootloader (systemd-boot) requires EFI to be mounted, so it must be installed later
    --include='linux-image-amd64 firmware-linux firmware-realtek btrfs-progs zstd'
    # nice to have
    --include='console-setup sudo vim'

    # set timezone
    --essential-hook='echo tzdata tzdata/Areas select Asia |
        chroot "$1" debconf-set-selections'
    --essential-hook='echo tzdata tzdata/Zones/Asia select Seoul |
    chroot "$1" debconf-set-selections'

    # set locale
    --essential-hook='echo locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8 |
        chroot "$1" debconf-set-selections'
    --essential-hook='echo locales locales/default_environment_locale select en_US.UTF-8 |
        chroot "$1" debconf-set-selections'

    # set keyboard layout
    --essential-hook='echo keyboard-configuration keyboard-configuration/layout select Korean |
        chroot "$1" debconf-set-selections'
    --essential-hook='echo keyboard-configuration keyboard-configuration/layoutcode select kr |
        chroot "$1" debconf-set-selections'
    --essential-hook='echo keyboard-configuration keyboard-configuration/variant select Korean |
        chroot "$1" debconf-set-selections'

    # mmdebstrap is mostly reproducible, except for:
    #   - timestamp (SOURCE_DATE_EPOCH)
    #   - /etc/resolv.conv
    #   - /etc/hostname
    # We don't actually need a reproducible build, but we still want a consistent hostname and resolv.conf

    # do not inherit settings from bootstrap system
    # dynamically configured by bacchus-pcdb later
    --customize-hook='rm -f $1/etc/hostname'
    # for firstboot, use hardcoded nameservers
    # after firstboot (once we have systemd) replaced with resolved's resolv-stub.conf
    --customize-hook='rm -f $1/etc/resolv.conf'
    --customize-hook='echo nameserver 1.1.1.1 >> $1/etc/resolv.conf'
    --customize-hook='echo nameserver 1.0.0.1 >> $1/etc/resolv.conf'

    # set apt sources
    --customize-hook='rm $1/etc/apt/sources.list'
    --customize-hook='echo deb http://mirror.snucse.org/debian bookworm main contrib non-free non-free-firmware >> $1/etc/apt/sources.list'
    --customize-hook='echo deb http://mirror.snucse.org/debian bookworm-updates main contrib non-free non-free-firmware >> $1/etc/apt/sources.list'
    --customize-hook='echo deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware >> $1/etc/apt/sources.list'

    # for firstboot, configure networking with ifupdown
    # after firstboot (once we have systemd) these settings will be managed by networkd

    # CHANGEME: ensure correct interface
    # In particuluar, lounge machines has "enp2s0" and hardware lab machines have "enp3s0".
    --customize-hook='echo auto enp2s0 >> $1/etc/network/interfaces.d/initial-network'
    --customize-hook='echo iface enp2s0 inet static >> $1/etc/network/interfaces.d/initial-network'
    # CHANGEME: also ensure correct address and gateway
    --customize-hook='echo address 147.46.127.127/24 >> $1/etc/network/interfaces.d/initial-network'
    --customize-hook='echo gateway 147.46.127.1 >> $1/etc/network/interfaces.d/initial-network'

    # install on root
    bookworm /root/btrfs-root/root http://mirror.snucse.org/debian
)

mmdebstrap "${args[@]}"
```

## 4. Post-bootstrap configuration

- ESP(`/boot/efi`), `/proc`, `/dev` 등 특수 filesystem이 필요하거나
- interactive하거나

등의 이유로 bootstrap에서 하기 어려운 절차는 여기서 진행한다.

### 4.1. chroot

```console
# bind mount special filesystems
mount --make-private --rbind /dev /root/btrfs-root/root/dev
mount --make-private --rbind /proc /root/btrfs-root/root/proc
mount --make-private --rbind /sys /root/btrfs-root/root/sys
mount -t tmpfs tmpfs /root/btrfs-root/root/tmp
mkdir -p /root/btrfs-root/root/boot/efi
mount /dev/sda1 /root/btrfs-root/root/boot/efi

# enter chroot
chroot /root/btrfs-root/root
```

### 4.2. Install bootloader

```console
# set kernel cmdline
echo 'root=LABEL=bacchus-root rootflags=subvol=root rw quiet' > /etc/kernel/cmdline

# configure fstab
cat <<EOF > /etc/fstab
LABEL=bacchus-esp	/boot/efi		vfat	noatime			0 2
LABEL=bacchus-root	/			btrfs	noatime,subvol=root	0 0
LABEL=bacchus-root	/csehome		btrfs	noatime,subvol=csehome	0 0
LABEL=bacchus-root	/var/log		btrfs	noatime,subvol=log	0 0
LABEL=bacchus-root	/root/btrfs-root	btrfs	noatime,subvol=/	0 0
EOF

# install bootloader
apt update
apt upgrade
apt install systemd-boot
```

### 4.3. Basic configuration

```console
update-alternatives --set editor /usr/bin/vim.basic
adduser bacchus # CHANGEME: interactive, set password
adduser bacchus sudo
```

### 4.4. Reboot

```console
# leave chroot
exit

# unmount all and reboot
umount -R /root/btrfs-root/root/{dev,proc,sys,tmp,boot/efi}
sync
reboot
```

## 5. Post-boot configuration

- 이제부턴 정상적으로 부팅된 시스템이기 때문에 systemd 등을 사용할 수 있다.

### 5.1. First-boot configuration

```console
# install openssh
apt install task-ssh-server

# misc. configuration
apt install bacchus-misc

# configure network
apt install bacchus-pcdb
rm /etc/network/interfaces.d/initial-network
# these steps may hang due to network dependencies, etc.
# just interrupt and try again, reboot if needed
apt install systemd-resolved
systemctl enable systemd-networkd.service
systemctl restart systemd-networkd.service systemd-resolved.service

# install desktop environment
# CHANGEME: choose "lightdm" when prompted for display manager
apt install bacchus-desktop-theme

# install development environment
apt install bacchus-development
bacchus-development

# install profile integration
apt install bacchus-auth

# enable home autocreation
pam-auth-update --enable mkhomedir

# CHANGEME: configure lab-vpn
# CHANGEME: configure /csehome ceph mount

# CHANGEME: edit nsswitch, add "cache" to passwd and groups, like so:
#   passwd: files systemd cache
#   group:  files systemd cache

# install node_exporter
apt install prometheus-node-exporter

# configure firewall
apt install ufw
ufw allow 22/tcp
ufw allow 9100/tcp
ufw enable
```

바쿠스 패키지 설정은 [bacchus-deb-packaging](https://github.com/bacchus-snu/bacchus-deb-packaging) 참고.

## 6. Deploy

- rootfs 준비가 완료되었으니 rootfs를 중앙 서버에 업로드하고 다른 컴퓨터에서 받아서 사용하도록 하는 단계.
- ansible을 사용한다. `apt install ansible sshpass`

### 6.1. Commit

- 작업한 컴퓨터에서 rootfs snapshot을 찍고 sherry에 업로드하는 단계.

```yaml
# commit.yml
- name: Commit and push current root fs
  hosts: '{{ host }}'
  tasks:
    - name: Ensure temporary snapshot does not exist
      ansible.builtin.shell:
        removes: /root/btrfs-root/tmp-root
        cmd: btrfs subvolume delete /root/btrfs-root/tmp-root
    - name: Create temporary snapshot
      ansible.builtin.shell:
        creates: /root/btrfs-root/tmp-root
        cmd: btrfs subvolume snapshot /root/btrfs-root/root /root/btrfs-root/tmp-root

    - name: Delete machine-id from temporary snapshot
      ansible.builtin.file:
        path: /root/btrfs-root/tmp-root/etc/machine-id
        state: absent
    - name: Delete bacchus private signing key from temporary snapshot
      ansible.builtin.file:
        path: /root/btrfs-root/tmp-root/etc/bacchus/keypair/tweetnacl
        state: absent
    - name: Delete bacchus public signing key from temporary snapshot
      ansible.builtin.file:
        path: /root/btrfs-root/tmp-root/etc/bacchus/keypair/tweetnacl.pub
        state: absent
    - name: Delete lab-vpn configuration from temporary snapshot
      ansible.builtin.file:
        path: /root/btrfs-root/tmp-root/etc/wireguard/wg-lab.conf
        state: absent

    - name: Commit snapshot
      ansible.builtin.shell:
        creates: /root/btrfs-root/snapshots/{{ snapshot }}
        cmd: btrfs subvolume snapshot -r /root/btrfs-root/tmp-root '/root/btrfs-root/snapshots/{{ snapshot }}'
    - name: Push snapshot
      ansible.builtin.shell:
        creates: /sherry/.tmp/sends/{{ prev_snapshot }}_{{ snapshot }}.zst
        cmd: btrfs send -p '/root/btrfs-root/snapshots/{{ prev_snapshot }}' '/root/btrfs-root/snapshots/{{ snapshot }}' | zstd -T0 > '/sherry/.tmp/sends/{{ prev_snapshot }}_{{ snapshot }}.zst'

    - name: Delete intermediary snapshot
      ansible.builtin.shell:
        removes: /root/btrfs-root/tmp-root
        cmd: btrfs subvolume delete /root/btrfs-root/tmp-root
```

```console
# CHANGEME: ensure correct host and snapshot name
#
# In the case of initial deployment:
# Modify the playbook:
#   - remove the "-p .../{{ prev_snapshot }}" argument from the "btrfs send" command
ansible-playbook -e host=147.46.127.127 \
  -e prev_snapshot=initial-deployment -e snapshot="$(date -uIsecond)-CHANGEME" commit.yml

# if not initial deployment
ansible-playbook -e host=147.46.127.127 \
  -e prev_snapshot=CHANGEME-previous-snapshot -e snapshot="$(date -uIsecond)-CHANGEME" commit.yml
```

생성된 snapshot 이름은 기억하도록 한다.

### 6.2. Checkout

- 6.1에서 업로드한 rootfs를 다운로드받고 기존 root랑 교체하는 단계.

```yaml
# checkout.yaml
- name: Pull and checkout the given snapshot
  hosts: '{{ host }}'
  tasks:
    - name: Pull snapshot
      ansible.builtin.shell:
        creates: /root/btrfs-root/snapshots/{{ snapshot }}
        cmd: zstd -cdT0 '/sherry/.tmp/sends/{{ prev_snapshot }}_{{ snapshot }}.zst' | btrfs receive /root/btrfs-root/snapshots

    - name: Ensure root snapshot does not exist
      ansible.builtin.shell:
        removes: /root/btrfs-root/next-root
        cmd: btrfs subvolume delete /root/btrfs-root/next-root
    - name: Checkout snapshot
      ansible.builtin.shell:
        creates: /root/btrfs-root/next-root
        cmd: btrfs subvolume snapshot '/root/btrfs-root/snapshots/{{ snapshot }}' /root/btrfs-root/next-root

    - name: Copy machine-id from previous root
      ansible.builtin.copy:
        remote_src: true
        src: /root/btrfs-root/root/etc/machine-id
        dest: /root/btrfs-root/next-root/etc/machine-id
    - name: Copy bacchus private signing key from previous root
      ansible.builtin.copy:
        remote_src: true
        src: /root/btrfs-root/root/etc/bacchus/
        dest: /root/btrfs-root/next-root/etc/bacchus/
    - name: Copy lab-vpn configuration from previous root
      ansible.builtin.copy:
        remote_src: true
        src: /root/btrfs-root/root/etc/wireguard/wg-lab.conf
        dest: /root/btrfs-root/next-root/etc/wireguard/wg-lab.conf

    - name: Relocate current rootfs
      ansible.builtin.shell:
        removes: /root/btrfs-root/root
        cmd: mv /root/btrfs-root/root /root/btrfs-root/trash/{{ ansible_date_time.epoch }}-root
    - name: Replace rootfs
      ansible.builtin.shell:
        creates: /root/btrfs-root/root
        cmd: mv /root/btrfs-root/next-root /root/btrfs-root/root
```

```console
# CHANGEME: specify the snapshot name created in the previous step.
# In the case of initial deployment:
# Modify the playbook:
#   - Remove the three "Copy ... from previous root" tasks
ansible-playbook -e host=all \
  -e prev_snapshot=initial-deployment -e snapshot="CHANGEME" pull.yml

# if not initial deployment
ansible-playbook -e host=all \
  -e prev_snapshot=CHANGEME-previous-snapshot -e snapshot="CHANGEME" pull.yml
```
