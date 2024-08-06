Clonezilla를 이용한 데스크톱 복사
---

### 작업 전 주의사항
- 타켓 컴퓨터의 저장소가 소스 컴퓨터에 저장된 내용으로 덮어씌워지므로 타겟 컴퓨터의 자료를 미리 백업한다.

### 작업 과정
1. 소스가 될 컴퓨터에 OS 설치 및 환경 설정 작업을 진행한다.
1. 소스 컴퓨터에 Clonezilla USB를 꽂고 부팅한다.
    - EFI 부팅이 아닌 경우에는 Other modes of Clonezilla live -> Clonezilla live (To RAM. Boot media can be removed later) 선택
    - EFI 부팅인 경우에는 바로 보이는 Clonezilla live (To RAM. Boot media can be removed later) 선택
1. Start Clonezilla를 선택한 후 device-device를 선택한다.
1. Beginner와 Expert 중 적당한 항목을 선택한다.
1. disk_to_remote_disk를 선택한다.
1. 사용환경에 맞게 네트워크를 설정한다.
    - 바쿠스방 내에서만 작업하는 경우 중앙전산원까지 데이터가 올라가지 않게 IP : 192.168.0.xxx, 기본 게이트웨이 : 없음 등으로 설정하면 좋다.
1. Clonezilla를 통해 복사할 디스크를 선택하고 옵션을 선택해준다.
1. Waiting for the target machine to connect... 가 뜨면 USB를 분리하고 타겟이 될 컴퓨터를 Clonezilla로 부팅한다.
1. 타겟 컴퓨터에서 Enter_shell을 선택하고 `sudo ocs-live-netcfg`를 입력하여 소스 컴퓨터에서와 같은 방법으로 네트워크를 설정한다.
1. `sudo ocs-onthefly -s "소스 컴퓨터 IP" -t "대상 장치"`를 입력한다.
    - `lsblk` 명령어를 이용하여 컴퓨터에 연결된 블록 장치들을 확인할 수 있으며 이들 중 소스 컴퓨터의 내용으로 덮어 쓰고 싶은 장치를 대상 장치로 입력한다.
    - 예) sudo ocs-onthefly -s 192.168.0.2 -t sda
1. Partclone 창이 나오며 복사가 시작된다.
    - 작업이 진행되는 동안 소스 컴퓨터는 Waiting for the target machine to connect... 에서 멈춰 있는 것이 정상이다.
1. 복사 완료 후 개별 컴퓨터에서 해줘야 할 작업을 수행한다. (컴퓨터 이름 설정 등)
