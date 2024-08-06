# bartender (Proxmox)

- 신규(신양 서버실) 클러스터에 대해서만 다룬다
- 노드:
  - [fizz](https://fizz.snucse.org:8006)
  - [gin](https://gin.snucse.org:8006)
  - [ramos](https://ramos.snucse.org:8006)
- 로그인:
  - Realm: "bacchus-dex" 선택 후 바쿠스 구글계정으로 로그인
    - 첫 로그인 후 권한 설정 필요:  Datacenter -> Permission -> Users -> 유저
      선택 -> Group 에 regular-members (정회원) 이나 intern-members (준회원) 설정
    - 이미 계정 설정 완료한 정회원 아무나 불러서 설정
  - bacchus-dex가 죽은 경우 "Linux PAM standard authenticatin" 선택하고
    `root / 리눅스 서버 비번`으로 로그인
  - SSH: `root / 리눅스 서버 비번`

## 네트워크

- `vmbr0`: SNUNet (VLAN 1)
  - 외부망에 바로 여는 경우
  - 수업용 VM 등
- `vmbr0.89`: BacchusNet (VLAN 89)
  - BacchusNet 내부 리소스에 접근해야 하는 경우
    - Ceph, waiter, 등등
  - 외부 트래픽은 모두 gateway를 통한다
- gateway(kerkoporta)는 둘 다 설정

### 업그래이드

1. 노드 중 하나를 선택하고, Updates -> Refresh, Updates -> Upgrade (root
   계정으로만 가능)
2. 리부팅 필요한 경우 Reboot
   - HA 설정을 하지 않은 VM이 있는 경우 미리 다른 노드로 migrate한다
   - HA 설정을 한 경우 자동으로 migrate된다
   - 접근중인 노드는 다른 노드로 옮겨가서 로그인 후 거기서 재부팅한다
3. 노드가 돌아올때까지 기다라기
   - HA 설정을 하지 않은 VM은 다시 migrate해서 돌려놓는다
   - HA 설정을 한 VM은 자동으로 migrate되어서 돌아온다
4. Ceph 창에서 Status `HEALTH_OK`인걸 확인하고 다음 노드 업데이트

### 종료 (정전 등)

1. VM은 모두 종료한다! (Bulk Actions -> Bulk Shutdown)
2. VM이 모두 꺼진 이후 노드 하나씩 종료
   - 당연하지만 접근중인 노드는 마지막으로 종료한다

### 부팅 (정전 후 등)

1. IPMI에 로그인한다 (호스트 시트 확인)
   - `https://<IPMI 주소>`: `ADMIN / IPMI 비번`
2. Power Control -> Power on
   - 약 5~10분 걸린다

## Ceph

- VM 클러스터에서 공유하는 스토리지 클러스터
- 노드마다 2TB SSD가 2개씩 설정중
- Pool 설정
  - `barrel`: Proxmox VM 디스크용 스토리지
  - `kubernetes`: waiter의 ceph-csi용 스토리지. 계정은 ceph CLI를 사용해서
    수동으로 설정했다
- CephFS: 백업, ISO 등 저장용
