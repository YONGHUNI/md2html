repo.snucse.org 관리
---

> 작성자: 한진제

## 인프라

[바쿠스 내부 패키지](https://github.com/bacchus-snu/bacchus-deb-packaging)들은 repo.snucse.org에서 호스팅하고 있다. 이 서비스는 waiter 안에서 [bacchus-repo](https://github.com/bacchus-snu/cd-manifests/tree/bacchus-repo/argocd/waiter/bacchus-repo)라는 이름으로 돌아가고 있다.

bacchus-repo에서는 Debian 패키지들을 [Reprepro](https://wikitech.wikimedia.org/wiki/Reprepro)로 관리하고 [Caddy](https://caddyserver.com/)로 호스팅한다. Manifest 파일을 보면 하나의 pod 안에 Reprepro 컨테이너와 Caddy 컨테이너가 하나씩 떠 있고 같은 volumn에 mount되어 있는 것을 볼 수 있는데, Reprepro 컨테이너에 패키지를 업로드하면 Caddy 컨테이너에서 호스팅하는 방식이다. 업로드된 패키지는 재부팅했을 때 사라지지 않도록 Persistent Volume Claim 안에 저장되어 있어야 하기 때문에 pod는 [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)으로 관리한다.

Waiter에서 `bacchus-repo` namespace를 선택하면 이렇게 생성된 리소스들을 볼 수 있다.

## 서비스 관리

### GPG key 추가

Reprepro에 패키지들을 업로드하려면 우선 GPG key를 추가해야 한다. Reprepro 컨테이너에 접속해서 `gpg --import` 커맨드를 입력하고, Vault의 `repo.snucse.org GPG key` 항목의 값을 그대로 붙여넣으면 GPG key가 추가된다. 이렇게 추가된 key는 `gpg -K` 커맨드를 통해 확인할 수 있다.

### Reprepro 설정

Reprepro 설정 파일들은 Reprepro 컨테이너의 `/srv/repos`에 mount되어 있다. `/srv/repos/debian/conf` 디렉토리 안에는 Reprepro의 설정 파일들이 들어가 있으며, 설정 파일은 [관련 문서](https://wiki.debian.org/DebianRepository/SetupWithReprepro#Configuring_reprepro)를 참조하여 수정한다. 설정 파일을 수정하였다면 `reprepro checkpool` 커맨드를 입력하여 문제가 없는지 확인한다.

만약 GPG key passphrase를 입력하라고 하면 vault에서 `리눅스 서버` 비밀번호를 복사해서 입력하면 된다.

### .deb 파일 등록

로컬에서 패키지를 빌드하여 `.deb` 파일을 만들었다면, 해당 파일을 Reprepro 컨테이너 안으로 가져온다. 그리고 `reprepro includedeb [Debian 릴리스 (ex: bookworm)] [.deb 파일 경로]`를 입력하면 해당 패키지를 Reprepro로 관리하게 된다. 등록된 패키지는 `/srv/repos/debian/pool/main` 디렉토리, 또는 https://repo.snucse.org/pool/main 에서 확인할 수 있다. `reprepro remove [패키지 이름]`을 입력하면 등록된 패키지를 삭제할 수도 있다.

### 테스팅

아무 실습실 컴퓨터에 `bacchus` 계정으로 접속하여 `sudo apt-get update` 커맨드를 입력하였을 때 문제 없이 돌아가는지 확인하면 된다.
