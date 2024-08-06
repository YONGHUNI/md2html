# SNUCSE GPU Service 재설치

## 0. 서버 준비

SNUCSE GPU Service는 쿠버네티스를 기반으로 운영됩니다.
이에 따라 Nvidia GPU Operator를 싱글노드 k0s 클러스터에 deploy하게 되는데, 이때 서버의 운영체제는 Ubuntu로 강제됩니다.
따라서 운영체제 재설치 시 Ubuntu를 준비해야 합니다.
기존 k0s가 설치되어 있는 경우에는 아래 명령어로 초기화할 수 있습니다.
```sh
sudo k0s stop
sudo k0s reset
sudo reboot
```

## 1. k0s 설치

먼저 k0s를 다운로드합니다. 이미 k0s가 있더라도 해당 명령어를 실행하면 k0s를 업그레이드할 수 있습니다.
```sh
curl -sSLf https://get.k0s.sh | sudo sh
```

싱글노드 클러스터의 경우 해당 노드가 controller이면서 동시에 worker 역할을 합니다. 이 클러스터를 만들기 위한 설정파일을 먼저 생성합니다. 보통 설정파일 경로는 `/etc/k0s/` 안에 만듭니다.
```sh
sudo mkdir -p /etc/k0s
k0s config create | sudo tee /etc/k0s/k0s.yaml > /dev/null
```

우리의 클러스터의 경우 추가적으로 https://id.snucse.org/ 의 OpenID Connect를 통해 접근할 수 있도록 해야하므로 `/etc/k0s/k0s.yaml` 파일에 아래 내용을 추가하여 수정합니다. 설정 내용은 SNUCSE ID 설정에 따라 달라질 수 있습니다. 아래는 예시입니다.
```yaml
spec:
  api:
    extraArgs:
      oidc-issuer-url: https://id.snucse.org/o
      oidc-client-id: snucse-gpu-service
      oidc-username-claim: "username"
      oidc-username-prefix: "oidc:"
      oidc-groups-claim: "groups"
      oidc-groups-prefix: "oidc:"
      oidc-signing-algs: "RS256,ES256"
status: {}
```

다음으로 runtime으로 사용할 containerd 역시 설정해야 합니다. k0s에서는 containerd의 기본 설정 권한을 k0s가 가집니다. 그러나 추후에 설치할 Nvidia GPU Operator의 경우 설정 파일에 일부 nvidia runtime 정보를 추가하게 되는데, k0s에서 권한을 가지게 되면 이를 우회하기 때문에 Nvidia GPU Operator가 제대로 동작하지 않습니다. 따라서 아래와 같이 기본 설정 파일을 생성하여 권한을 가져오도록 해야 합니다.
containerd bin 파일이 없으면 먼저 controller를 설치해서 containerd를 생성시킨 후 다시 k0s를 stop하고 containerd를 마저 설정해도 괜찮습니다.
```sh
sudo /var/lib/k0s/bin/containerd config default | sudo tee /etc/k0s/containerd.toml > /dev/null
```
그리고나서 일부 내용을 k0s에 맞게 고칩니다.
```yaml
version = 2
root = "/var/lib/k0s/containerd"
state = "/run/k0s/containerd"
...

[grpc]
  address = "/run/k0s/containerd.sock"
```

다음으로 클러스터를 설치하기 전에 주의할 점이 있습니다.
컨테이너 이미지, 로그 파일, kubelet 정보 등의 데이터가 저장될 경로가 있는데 기본값은 `/var/lib/k0s`입니다. 이 경로는 설치 이후에는 바꿀 수 없으므로 신중하게 정해야 합니다.

23년 8월 2일 재설치 시에는 사용자들에게 PVC로 제공될 ZFS 기반의 `zpool`이라는 볼륨을 `/var/lib/k0s`에 마운트하는 식으로 처리했습니다. 이때 k0s는 기본적으로 ZFS-based systems에서 시작할 수 없습니다. 따라서 `/etc/k0s/containerd.toml`에서 snapshotter 부분을 "overlayfs"에서 "zfs"로 고쳐야합니다.
```yaml
...
    [plugins."io.containerd.grpc.v1.cri".containerd]
      snapshotter = "zfs"
...
```
또한 zfs snapshot을 저장할 볼륨을 생성해야 합니다.
```sh
sudo zfs create -o mountpoint=/var/lib/k0s/containerd/io.containerd.snapshotter.v1.zfs zpool/containerd
# zpool 대신 다른 이름을 사용했으면 해당 이름을 기입
```

데이터 경로에 대한 고려를 완료했으면 k0s controller를 설치합니다. `k0s install controller --help`에서 flag를 신중히 확인합니다.
```sh
sudo k0s install controller -c /etc/k0s/k0s.yaml --data-dir /var/lib/k0s --single
# `sudo k0s install controller --single`와 동일함
sudo k0s start
```

## 2. Argo CD 연결

해당 클러스터는 이제 적절히 유저 세팅을 하여 admin 자격으로 외부에서 kubectl로 접근할 수 있다고 가정하고 설정하겠습니다.

Argo CD와의 연결을 통해 다양한 기능들을 배포할 수 있습니다. 다양한 방법이 있지만 그 중 ferrari 노드와 EKS의 Argo CD를 연결하는 걸 예시로 들겠습니다.
연결을 위해 먼저 argo가 사용할 계정을 클러스터에 생성해야 합니다. 
```sh
git clone https://github.com/bacchus-snu/cd-manifests.git
kubectl apply -f cd-manifests/projects/ferrari-bootstrap/serviceaccount.yaml
```
그 후 secret 정보를 다음을 통해 알아냅니다.
```sh
kubectl get secrets -ojson argo -n kube-system
```
해당 정보 중 "data"의 값을 AWS System Manager의 파라미터 스토어 안, `/infra/ferrari/argo`에 넣습니다.
EKS에서 secret 정보를 갱신해줘야 하므로 기존 secret이 있으면 삭제해줍니다. **이때 접근하는 클러스터는 AWS EKS 클러스터입니다.**
```sh
kubectl delete -n argo secret/ferrari
```
아마 EKS 설정에 따라 자동으로 다시 secret/ferrari가 새로운 정보와 함께 생성됐을 겁니다.
label을 지정해야 합니다.
```sh
kubectl label -n argo secrets/ferrari argocd.argoproj.io/secret-type=cluster
```
그러면 Argo CD와의 동기화가 시작되며 다음과 같은 app들이 설치됩니다.
1. ferrari-bootstrap
1. ferrari-cert-manager
1. ferrari-gpu-controller
1. ferrari-gpu-operator
1. ferrari-ingress-nginx
1. ferrari-kube-state-metrics
1. ferrari-node-exporter
1. ferrari-openebs

동기화 순서, secret 등으로 인해 약간의 문제가 있을 수 있습니다.
다른 클러스터도 위와 같은 방식으로 설정하면 되겠습니다. 자세한 건 cd-manifests repo를 참고하세요.
driver가 설치되기 때문에 모든 설치가 완료되면 재부팅을 해야 합니다.
