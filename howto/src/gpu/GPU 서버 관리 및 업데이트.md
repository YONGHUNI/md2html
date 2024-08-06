매 학기 GPU 서버 관리 및 업데이트 
---

## GPU 서버 관리

### 사전 준비

이전에 공고한 GPU 서버 사용 마감 기한 일주일 전, 계정을 발급받은 사용자들에게 이메일을 보내 사용 기한 및 필요한 자료는 미리 백업하라는 점을 안내합니다. 사용 기한이 마감되면, 다시 이메일을 보내 사용 기한이 마감되었음을 알립니다. 그 다음 ID 서버의 GPU 서버 사용자 그룹 관리 페이지에 들어가 사용자들을 그룹 멤버로부터 제외합니다.

### 재설치 진행

재설치가 필요한 경우 모르모트를 하나 잡고 [GPU 서버 재설치 문서](https://github.com/bacchus-snu/work/blob/master/howto/GPU%20%EC%84%9C%EB%B2%84%20%EC%9E%AC%EC%84%A4%EC%B9%98.md)를 보면서 재설치를 진행합니다.  
재설치가 필요없다면 모든 패키지를 최신 버전으로 업데이트한 후 다른 서버에 배포합니다.

### 유저 세션 종료 및 데이터 삭제

#### 1. 남아있는 유서 세션 종료

유저 데이터를 지우기 전, 모든 GPU 서버에서 혹시 남아있을 수 있는 유저 세션을 모두 종료합니다.

```
loginctl list-users \
	| head -n-2 | tail -n+2 \
	| awk '{print $2}' \
	| grep -v -e '^root$' -e '^bacchus$' \
	| xargs -n1 loginctl kill-user
```

#### 2. `/csehome` 백업

GPU 서버의 `/csecome` 디렉터리는 oloroso 서버에 저장되고 각 GPU 서버는 NFS를
통해서 마운트되어있습니다. 해당 데이터를 지우려면 oloroso에서 지우면
충분합니다.

oloroso에서 데이터를 지우기 전, 나중에 복구 요청이 있는 경우를 대비해서
snapshot을 찍습니다. 이 snapshot은 [백업 정책][policy-backup]에 따라 최소 2
분기동안 저장합니다.

```sh
# oloroso
mount /root/btrfs-toplevel
btrfs snapshot -r /root/btrfs-toplevel/csehome /root/btrfs-toplevel/backups/gpu/2023-03-13-wipe

# 2 분기 이상 오래된 snapshot이 있으면 삭제
btrfs subvol delete /root/btrfs-toplevel/backups/gpu/OLD_SNAPSHOT_NAME
```

> [백업 정책][policy-backup]을 따르려면 백업도 다른 머신에 저장해야 하지만 아직
> 준비되지 않았기 때문에 실행하지 않았습니다.

[policy-backup]: ../../policy/backup.html

#### 3. `/csehome`, `/local/.docker` 삭제

oloroso에서 `/csehome` 안 내용을 지웁니다. 지울 때는 `/csehome/bacchus`는
지우지 않도록 유의합니다.

추가로 각 서버 `/local/.docker/` 안 내용도 지웁니다. 여기서도 `root`, `bacchus`
유저의 디렉터리는 지우 않도록 유의합니다.

### 계정 신청 글 작성

GPU 서버의 계정 신청은 다음 두 단계를 거칩니다.  
* 설문조사 완료
* GPU 서버 사용자 그룹 신청

구글 드라이브에서 설문조사 폼을 만든 후, 바쿠스 홈페이지에 GPU 서버 계정 신청을 안내하는 글을 작성합니다.  
이 글에는 사용가능한 서버 및 스펙, 시용 기한, 신청 방법, 이용 약관 및 안내를 명시해야 합니다.  

### 계정 신청 승인

이후에는 주기적으로 새로운 신청을 들어오는지 확인합니다.  
계정 신청이 들어오면 설문조사에 이상이 없는지, GPU 서버 사용자 그룹에 신청을 하였는지 체크합니다. 만약 빠진 과정이 있다면 이메일을 보내 제대로 신청하도록 안내합니다.  

계정 신청을 승인하려면 GPU 서버 사용자 그룹에 들어가 해당하는 사용자를 선택한 후 승인 버튼을 누릅니다. 그리고 사용자에게 이메일을 보내 계정 발급이 완료되었음을 알립니다.

#### 도커 사용 신청이 있는 경우

GPU 서버는 여러 사용자가 사용하기 때문에, rootless Docker를 사용합니다. 보통 일반 사용자에게 도커 사용 권한을 부여하면 container escape 등으로 host 시스템의 root 권한을 얻는게 가능한데, [rootless docker]를 설정하면 도커 daemon이 사용자 권한으로 실행되기 때문에 root이나 다른 사용자 권한을 얻기 훨신 어려워집니다. [설정 절차][activity-docker-rootless]

[activity-docker-rootless]: https://github.com/bacchus-snu/work/blob/master/activity/2022-02-23-rootless-docker.md

이렇게 설정하는 경우 컨테이너는 사용자 권한으로 실행되지만, 컨테이너 안에서 여러 유저가 존재할 수 있기 때문에, 각 유저마다 컨태이너 안에서 사용할 subuid, subgid range 할당이 필요합니다. 각 서버에는 이미 `add-docker-user` 스크립트가 있기 때문에, 이 스크립트를 사용하면 됩니다.

ansible playbook 을 사용하면 쉽게 설정이 가능합니다. 다음 ansible playbook은 각 유저마다 subuid에 해당 유저 설정이 있는지 확인하고, 없는 겅우 btrfs root를 read-write 설정, 추가해야하는 유저마다 `add-docker-user` 실행, 그리고 btrfs root를 다시 read-only 설정합니다.

추가적으로 `/usr/local/sbin/add-me-to-docker-user` 스크립트가 추가됐습니다. `/etc/sudoers.d/docker-user`에 `%cseusers ALL=(root) NOPASSWD: /usr/local/sbin/add-me-to-docker-user`가 설정되어 있기 때문에, 모든 GPU 사용자는 sudo 권한 없이 해당 스크립트를 실행할 수 있습니다. 해당 스크립트 경로에 대한 안내만 있다면 앞서 언급한 subuid, subgid 할당 부분을 사용자에게 부담할 수 있어 관리자가 처리하지 않아도 됩니다.

```yaml
# playbook.yml
- name: Configure docker user subuid/subgids
  hosts: gpu
  vars:
    ansible_python_interpreter: /usr/bin/python3
  vars_files:
    - users.yml
  tasks:
    - name: 'Get user IDs'
      ansible.builtin.getent:
        database: passwd
        key: '{{ item }}'
      loop: '{{ docker_users }}'
      register: getent
    - name: Check if user is in /etc/subuid
      ansible.builtin.lineinfile:
        path: /etc/subuid
        regexp: '{{ item.ansible_facts.getent_passwd[item.item].1 }}:(.*)'
        state: absent
      check_mode: true
      register: subuid
      changed_when: not subuid.changed
      loop: '{{ getent.results }}'
    - name: Make root read-write
      become: true
      ansible.builtin.command: /usr/bin/btrfs property set -ts / ro false
      when: subuid.changed
    - name: Add docker user
      become: true
      ansible.builtin.command: /usr/local/sbin/add-docker-user {{ item.item.item }}
      when: item.changed
      loop: '{{ subuid.results }}'
    - name: Make root read-only
      become: true
      when: subuid.changed
      ansible.builtin.command: /usr/bin/btrfs property set -ts / ro true
```

```yaml
# hosts.yml
all:
  vars:
    ansible_user: bacchus
  children:
    gpu:
      hosts:
        asahi.snucse.org:
        bernini.snucse.org:
        cojito.snucse.org:
        derby.snucse.org:
        eggnog.snucse.org:
        faust.snucse.org:
```

```yaml
# users.yml
docker_users:
  - yseong
  - skystar
  # 등등
```

사용을 위해서는
1. ansible 패키지를 설치하고 [참조] (https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
2. 위에 언급된 3개의 파일들을 파일명에 맞게 저장한 후
3. `ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts.yml -k playbook.yml` 을 실행

[rootless Docker]: https://docs.docker.com/engine/security/rootless/

### 알아두면 좋은 점
GPU 서버 관리 시 알아두면 유용한 정보들에 대해 기술합니다.

#### anaconda 가상환경을 도입한 이유
Arch Linux의 정책을 따라 GPU 서버는 업데이트 시 모든 패키지를 일괄적으로 최신 버전으로 유지하는 것을 목표로 합니다. 다만 tensorflow, pytorch 등의 딥러닝 프레임워크는 cuda, cudnn, python 등 여러 프로그램의 버전 및 환경에 따라 작동이 달라질 수 있습니다. 따라서 유저마다 요구하는 프레임워크의 버전이나 환경이 다를 수 있습니다.

예를 들어, 유저가 딥러닝 논문의 구현체를 돌려보려고 하는데 이게 tensorflow 1.xx 버전으로 작성된 경우, GPU 서버에 설치된 버전은 2.xx 버전이라 이를 돌리는 것이 불가능합니다. 유저는 이 구현체를 돌리기 위해 별도의 컨버팅 과정으로 거쳐야하는데 이는 상당히 귀찮은 작업입니다. 

이를 해결하기 위하여 2020년 상반기부터 [`anaconda`](https://www.anaconda.com/)를 도입하여 사용자가 필요한 경우 가상환경을 로컬에 구축하도록 안내하고 있습니다.  
서버 관리자는 계정 발급 후 사용자에게 보내는 이메일에 `anaconda` 가상환경에 관한 사용법을 간략히 명시해주는 것이 좋습니다.

#### GPU를 사용 중인 사용자를 확인하는 방법
`nvidia-smi`를 실행하면 현재 GPU를 사용하고 있는 프로세스를 확인할 수 있습니다. 프로세스의 PID를 확인한 후 `htop`을 이용하여 사용자를 확인합니다.

## GPU 서버 업데이트
GPU 서버의 업데이트는 서버 한 대에서 실제 업데이트를 진행하고, 나머지 서버에서 업데이트 결과를 이미지로 받아 적용하는 식으로 이루어집니다.

### 실제 업데이트를 진행하는 서버

GPU 서버의 데이터를 수정하려면 먼저 `root` subvolume의 read-only property를 해제해야 합니다.
```sh
btrfs property set -ts / ro false
```

그 다음 패키지 설치와 같은 필요한 작업을 수행합니다.  
작업이 끝나면 다시 read-only property를 설정합니다.
```sh
btrfs property set -ts / ro true
```

snapshot name을 정합니다.
```sh
export snapshot_name=2021-02-28-gpu-reinstall
```

`root` subvolume을 스냅샷으로 만들고 이미지 파일을 `/csehome/bacchus/images` 폴더에 저장합니다.  
이 때 `-p <parent-subvolume>` 옵션을 사용하여 변경 사항만 이미지로 만들어 파일 크기를 줄이는 것을 권장합니다.
```sh
mount /root/btrfs-toplevel
btrfs subvolume snapshot -r /root/btrfs-toplevel/root "/root/btrfs-toplevel/snapshots/${snapshot_name}"
btrfs send -p "/root/btrfs-toplevel/snapshots/${parent_snapshot_name}" "/root/btrfs-toplevel/snapshots/${snapshot_name}" | zstd -T0 > "/csehome/bacchus/images/${snapshot_name}.zst"
```

참고로 스냅샷 전체를 이미지로 만들고 싶으면 -p <parent-subvolume> 옵션을 제거하면 됩니다.  

### 이미지를 받아 적용하는 서버

위에서 만든 이미지를 적용할 서버에 접속해 이미지를 스냅샷으로 가져옵니다.
```sh
export snapshot_name=2021-02-28-gpu-reinstall
mount /root/btrfs-toplevel
zstd -d -c -T0 "/csehome/bacchus/images/${snapshot_name}.zst" | btrfs receive /root/btrfs-toplevel/snapshots/
```

그 다음 기존 `root` subvolume을 `old-root` subvolume으로 옮기고 받은 스냅샷을 새로운 `root` subvolume으로 설정합니다.
```sh
btrfs subvolume delete /root/btrfs-toplevel/old-root
mv /root/btrfs-toplevel/root /root/btrfs-toplevel/old-root
btrfs subvolume snapshot -r "/root/btrfs-toplevel/snapshots/${snapshot_name}" /root/btrfs-toplevel/root
btrfs subvolume set-default /root/btrfs-toplevel/root
```

다음을 실행하여 subvolume의 기본값이 `root`로 되어있는지 확인합니다.
```sh
btrfs subvolume get-default /
```

잘 되어있다면 `reboot` 을 하여 재부팅을 합니다.
