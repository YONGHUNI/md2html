# 물리서버: 바쿠스 302동 서버실 서버랙 현황

## 문서의 현재 상태

- 마지막 현장 조사: 2023-02-12
- 마지막 원격 조사: 2023-09-16

## KVM 스위치에 대하여

KVM 모니터가 랙에 위치하며, 이를 이용하여 서버에 접근할 수 있다. (glennfidich와 jackdaniels는 불가능하며, 모니터를 수동으로 연결하는 매우 번거로운 작업이 필요하다.)

KVM 키보드에서 CapsLock+CapsLock+SpaceBar 를 입력하면 서버 선택 화면이 뜨며, 여기서 원하는 서버를 선택하여 이동할 수 있다.

일부 KVM 포트는 다른 단체(UPnL의 sodrak 등) 가 점유하고 있다.

## 하드웨어실습실 첫번째 서버랙

서버실 입구에서 가장 가까운 서버랙이다.
앞면에 4대, 뒷면에 2대, 총 6대의 데스크탑 형태의 서버가 있다.
6대 모두 구성이 같다.

### asahi

- 위치: 뒷면 위
- KVM 포트: 
- 제품: 
- 마더보드: ASRock B250M-HDV
- CPU: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz (4 cores, 8 vCPUs)
- 메모리: Samsung 16GB DDR4 2133MT/s
- OS 스토리지: WDC WDS240G1G0A-00SS50 2.5'' SATA3 SSD 240GB
- 데이터 스토리지: 
- 스토리지 컨트롤러: 
- GPU: NVIDIA GeForce GTX 1080
- 네트워크 인터페이스
  - 2: enp0s31f6: MAC 70:85:c2:32:5d:cb, inet 147.46.240.213/24
- 확장성: 싱글 소켓 1151, DDR4 2400 (7세대) / 2133 (6세대), 최대 메모리 32GB, 메모리 슬롯 2개, 6 SATA3, 1 PCIe3.0x4 M.2

### bernini

- 위치: 앞면 왼쪽 아래
- KVM 포트: 
- 제품: 
- 마더보드: ASRock B250M-HDV
- CPU: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz (4 cores, 8 vCPUs)
- 메모리: Samsung 16GB DDR4 2133MT/s
- OS 스토리지: WDC WDS240G1G0A-00SS50 2.5'' SATA3 SSD 240GB
- 데이터 스토리지: 
- 스토리지 컨트롤러: 
- GPU: NVIDIA GeForce GTX 1080
- 네트워크 인터페이스
  - 2: enp0s31f6: MAC 70:85:c2:32:5d:89, inet 147.46.240.245/24
- 확장성: 싱글 소켓 1151, DDR4 2400 (7세대) / 2133 (6세대), 최대 메모리 32GB, 메모리 슬롯 2개, 6 SATA3, 1 PCIe3.0x4 M.2

### cojito

- 위치: 앞면 오른쪽 아래
- KVM 포트: 
- 제품: 
- 마더보드: ASRock B250M-HDV
- CPU: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz (4 cores, 8 vCPUs)
- 메모리: Samsung 16GB DDR4 2133MT/s
- OS 스토리지: WDC WDS240G1G0A-00SS50 2.5'' SATA3 SSD 240GB
- 데이터 스토리지: 
- 스토리지 컨트롤러: 
- GPU: NVIDIA GeForce GTX 1080
- 네트워크 인터페이스
  - 2: enp0s31f6: MAC 70:85:c2:32:5d:c9, inet 147.46.240.221/24
- 확장성: 싱글 소켓 1151, DDR4 2400 (7세대) / 2133 (6세대), 최대 메모리 32GB, 메모리 슬롯 2개, 6 SATA3, 1 PCIe3.0x4 M.2

### derby

- 위치: 앞면 오른쪽 위
- KVM 포트: 
- 제품: 
- 마더보드: ASRock B250M-HDV
- CPU: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz (4 cores, 8 vCPUs)
- 메모리: Samsung 16GB DDR4 2133MT/s
- OS 스토리지: WDC WDS240G1G0A-00SS50 2.5'' SATA3 SSD 240GB
- 데이터 스토리지: 
- 스토리지 컨트롤러: 
- GPU: NVIDIA GeForce GTX 1080
- 네트워크 인터페이스
  - 2: enp0s31f6: MAC 70:85:c2:32:5d:81, inet 147.46.240.204/24
- 확장성: 싱글 소켓 1151, DDR4 2400 (7세대) / 2133 (6세대), 최대 메모리 32GB, 메모리 슬롯 2개, 6 SATA3, 1 PCIe3.0x4 M.2

### eggnog

- 위치: 앞면 왼쪽 위
- KVM 포트: 
- 제품: 
- 마더보드: ASRock B250M-HDV
- CPU: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz (4 cores, 8 vCPUs)
- 메모리: Samsung 16GB DDR4 2133MT/s
- OS 스토리지: WDC WDS240G1G0A-00SS50 2.5'' SATA3 SSD 240GB
- 데이터 스토리지: 
- 스토리지 컨트롤러: 
- GPU: NVIDIA GeForce GTX 1080
- 네트워크 인터페이스
  - 2: enp0s31f6: MAC 70:85:c2:32:5d:8d, inet 147.46.240.145/24
- 확장성: 싱글 소켓 1151, DDR4 2400 (7세대) / 2133 (6세대), 최대 메모리 32GB, 메모리 슬롯 2개, 6 SATA3, 1 PCIe3.0x4 M.2

### faust

- 위치: 뒷면 아래
- KVM 포트: 
- 제품: 
- 마더보드: ASRock B250M-HDV
- CPU: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz (4 cores, 8 vCPUs)
- 메모리: Samsung 16GB DDR4 2133MT/s
- OS 스토리지: WDC WDS240G1G0A-00SS50 2.5'' SATA3 SSD 240GB
- 데이터 스토리지: 
- 스토리지 컨트롤러: 
- GPU: NVIDIA GeForce GTX 1080
- 네트워크 인터페이스
  - 2: enp0s31f6: MAC 70:85:c2:32:5d:8b, inet 147.46.240.144/24
- 확장성: 싱글 소켓 1151, DDR4 2400 (7세대) / 2133 (6세대), 최대 메모리 32GB, 메모리 슬롯 2개, 6 SATA3, 1 PCIe3.0x4 M.2


## 하드웨어실습실 세번째 서버랙

서버실 입구에서 가까운 순으로 세번째에 위치한 서버랙이다.
서버랙 위에 있는 머신부터 순서대로 나열한다.

### (스위치)

- 서버의 맨 위에 네트워크 스위치 2개가 있다.
- 내부 스위치: 서버끼리의 연결을 위해 사용하는 스위치
- 외부 스위치: NET-SNU와도 연결되어 있는 스위치

### joker

- 물리적 크기: 1U
- KVM 포트: 1번
- 제품: HP ProLiant DL360 Gen9
- 마더보드: HP ProLiant DL360 Gen9
- CPU: Intel(R) Xeon(R) CPU E5-2630 v3 @ 2.40GHz (8 cores, 16 vCPUs)
- 메모리: 7 x 16GB DDR4 2133MT/s, 1866MT/s configured (112GB, total)
- OS 스토리지: HP EG1200JEMDA 2.5'' SAS-3 10kRPM HDD 1.2TB
- 데이터 스토리지: 
- 스토리지 컨트롤러: HPE Smart Array P440ar controller
- GPU: 
- 네트워크 인터페이스
  - 8: xenbr0: MAC 94:18:82:01:0e:4c, inet 147.46.242.183/24
  - 10: xenbr1: MAC 94:18:82:01:0e:4d, inet 192.168.0.4/24
- 확장성: 듀얼 소켓 LGA2011-3, DDR4 2133 (CPU 종류에 따라 동작 속도 상이함), 최대 메모리 RDIMM 기준 768GB, LRDIMM 기준 3TB, 메모리 슬롯 24개, 8 x 2.5'' SAS/SATA

### martini

- 물리적 크기: 1U
- KVM 포트: 2번
- 제품: HP ProLiant DL360 Gen9
- 마더보드: HP ProLiant DL360 Gen9
- CPU: Intel(R) Xeon(R) CPU E5-2630 v3 @ 2.40GHz (8 cores, 16 vCPUs)
- 메모리: 16GB DDR4 2133MT/s, 1866MT/s configured
- OS 스토리지: 3 x HP EG1200JEMDA 2.5'' SAS-3 10kRPM HDD 1.2TB (RAID 5 2.4TB, total)
- 데이터 스토리지: 
- 스토리지 컨트롤러: HPE Smart Array P440ar controller
- GPU: 
- 네트워크 인터페이스
  - 2: eno1: MAC 94:18:82:01:19:08, inet 147.46.240.44/24
- 확장성: 듀얼 소켓 LGA2011-3, DDR4 2133 (CPU 종류에 따라 동작 속도 상이함), 최대 메모리 RDIMM 기준 768GB, LRDIMM 기준 3TB, 메모리 슬롯 24개, 8 x 2.5'' SAS/SATA

### mimosa - 퇴역

- 물리적 크기: 1U
- KVM 포트: 3번
- 제품: Dell Inc. PowerEdge R420
- 마더보드: Dell Inc. 072XWF
- CPU: Intel(R) Xeon(R) CPU E5-2407 @ 2.20GHz (4 cores, 4 vCPUs)
- 메모리: 3 x 4GB DDR3 1333MT/s, 1067MT/s configured (12GB, total)
- OS 스토리지: 2 x WDC WD1003FBYX-18Y7B0 3.5'' SATA-2 7.2kRPM HDD 1.0TB (RAID 1 1.0TB, total)
- 데이터 스토리지: 
- 스토리지 컨트롤러: Dell PERC H310
- GPU: 
- 네트워크 인터페이스
  - 2: eno1: MAC 90:b1:1c:16:e9:ae, inet 147.46.240.46/24
- 확장성: 듀얼 소켓 LGA1356, DDR3 1333, 최대 메모리 384GB, 메모리 슬롯 12개, 4 x 3.5'' SAS/SATA

### sherry - 퇴역 필요

- 물리적 크기: 1U
- KVM 포트: 4번
- 제품: Dell Inc. PowerEdge R410
- 마더보드: Dell Inc. 01V648
- CPU: Intel(R) Xeon(R) CPU E5530 @ 2.40GHz (4 cores, 8 vCPUs)
- 메모리: 2 x 4GB DDR3 1333MT/s (8GB, total)
- OS 스토리지: Samsung 850 2.5'' SATA3 SSD 120GB
- 데이터 스토리지: WDC_WD40EFRX-68W 3.5'' SATA3 5.4kRPM HDD 4TB (현재 약 2.2TB), 2 x Samsung 860 2.5'' SATA3 SSD 1TB (2.2TB HDD, btrfs RAID 1 1TB SSD, total)
- 스토리지 컨트롤러: 
- GPU: 
- 네트워크 인터페이스
  - 2: eno1: MAC d4:ae:52:67:4b:a5, inet 147.46.78.91/24
- 확장성: 듀얼 소켓 LGA1366, DDR3 1333, 최대 메모리 128GB, 메모리 슬롯 8개, 4 x 3.5'' SAS/SATA

### rum - 퇴역 필요

- 물리적 크기: 2U
- KVM 포트: 5번
- 제품: Dell Inc. PowerEdge R710
- 마더보드: Dell Inc. 00NH4P
- CPU: Intel(R) Xeon(R) CPU E5640 @ 2.67GHz (4 cores, 8 vCPUs)
- 메모리: 6 x 4GB DDR3 1333MT/s (24GB, total)
- OS 스토리지: WDC WD5003ABYX-18WERA0 3.5'' SATA2 7.2kRPM HDD 500GB
- 데이터 스토리지: 
- 스토리지 컨트롤러: Dell PERC 6/i
- GPU: 
- 네트워크 인터페이스
  - 2: eno1: MAC 84:2b:2b:6c:25:c7, inet 147.46.242.138/24
- 확장성: 듀얼 소켓 LGA1366, DDR3 1333, 최대 메모리 192GB, 메모리 슬롯 18개, 6 x 3.5'' SAS/SATA

### blanc - 퇴역 필요

- 물리적 크기: 1U
- KVM 포트: 4번
- 제품: Dell Inc. PowerEdge R410
- 마더보드: Dell Inc. 0N051F
- CPU: Intel(R) Xeon(R) CPU E5520 @ 2.27GHz (4 cores, 8 vCPUs)
- 메모리: 6 x 2GB DDR3 1333MT/s (12GB, total)
- OS 스토리지: ST1000NM0011 3.5'' SATA3 7.2kRPM HDD 1TB, ST31000524NS 3.5'' SATA2 7.2kRPM HDD 1TB (RAID 1 1TB, total)
- 데이터 스토리지: 
- 스토리지 컨트롤러: Dell SAS 6/iR Integrated Blades RAID Controller
- GPU: 
- 네트워크 인터페이스
  - 2: eno1: MAC 00:26:b9:49:8f:2b, inet 147.46.242.187/24
  - 4: wg-aws: inet 10.129.0.2/24
- 확장성: 듀얼 소켓 LGA1366, DDR3 1333, 최대 메모리 128GB, 메모리 슬롯 8개, 4 x 3.5'' SAS/SATA

### kof - 퇴역

- 물리적 크기: 1U
- KVM 포트: 8번
- 제품: Dell Inc. PowerEdge R410
- 마더보드: Dell Inc. 0N051F
- CPU: Intel(R) Xeon(R) CPU E5520 @ 2.27GHz (4 cores, 8 vCPUs)
- 메모리: 6 x 2GB DDR3 1333MT/s (12GB, total)
- OS 스토리지: TOSHIBA MG04ACA1 3.5'' SATA3 7.2kRPM HDD 1TB, ST1000NM0011 3.5'' SATA3 7.2kRPM HDD 1TB (RAID 1 1TB, total)
- 데이터 스토리지: 
- 스토리지 컨트롤러: Dell SAS 6/iR Integrated Blades RAID Controller
- GPU: 
- 네트워크 인터페이스
  - 3: eno2: MAC 00:17:08:5d:37:2f, inet 147.46.240.39/24
- 확장성: 듀얼 소켓 LGA1366, DDR3 1333, 최대 메모리 128GB, 메모리 슬롯 8개, 4 x 3.5'' SAS/SATA

### skyy - 퇴역 필요

- 물리적 크기: 1U
- KVM 포트: 7번
- 제품: Dell Inc. PowerEdge R420
- 마더보드: Dell Inc. 072XWF
- CPU: Intel(R) Xeon(R) CPU E5-2407 @ 2.20GHz (4 cores, 4 vCPUs)
- 메모리: 3 x 4GB DDR3 1333MT/s, 1067MT/s configured (12GB, total)
- OS 스토리지: 4 x WDC WD1002FBYS-18W8B1 3.5'' SATA2 7.2kRPM HDD 1.0TB (RAID 5 3.0TB, total)
- 데이터 스토리지: 
- 스토리지 컨트롤러: Dell PERC H310
- GPU: 
- 네트워크 인터페이스
  - 2: eno1: MAC 90:b1:1c:0e:e0:f0, inet 147.46.242.84/24
  - 3: eno2: MAC 90:b1:1c:0e:e0:f1, inet 192.168.0.2/24
- 확장성: 듀얼 소켓 LGA1356, DDR3 1333, 최대 메모리 384GB, 메모리 슬롯 12개, 4 x 3.5'' SAS/SATA

### fizz - 퇴역, 이름 변경 필요

- 물리적 크기: 1U
- KVM 포트: 9번
- 제품: Dell Inc. PowerEdge R430
- 마더보드: Dell Inc. 03XKDV
- CPU: Intel(R) Xeon(R) CPU E5-2603 v3 @ 1.60GHz (6 cores, 6 vCPUs)
- 메모리: 16GB DDR4 2133MT/s
- OS 스토리지: 2 x ST1000NM0023 3.5'' SAS-2 7.2kRPM HDD 1.0TB (RAID 1 1.0TB, total)
- 데이터 스토리지: 
- 스토리지 컨트롤러: Dell PERC H330 Mini
- GPU: 
- 네트워크 인터페이스
  - 2: eno1: MAC 44:a8:42:22:82:1f, inet 147.46.242.140/24
- 확장성: 듀얼 소켓 LGA2011-3, DDR4 2400, 최대 메모리 듀얼 소켓 기준 384GB, 단일 소켓 기준 256GB, 메모리 슬롯 12개, 4 x 3.5'' SAS/SATA

### (빈 공간)

이전에 kir가 여기에 있었나 제거되면서 빈 공간이 남아있다.

## (KVM 모니터)

KVM 모니터가 여기에 위치한다.

### colada - 퇴역

- 물리적 크기: 1U
- KVM 포트: 14번
- 제품: Dell Inc. PowerEdge R210
- 마더보드: Dell Inc. PowerEdge R210
- CPU: Intel(R) Xeon(R) CPU X3430 @ 2.40GHz (4 cores, 4 vCPUs)
- 메모리: 2 x 2GB DDR3 1333MT/s (4GB, total)
- OS 스토리지: 2 x WDC WD1602ABKS-1 3.5'' SATA2 7.2kRPM HDD 160GB (RAID 1 160GB, total)
- 데이터 스토리지: 
- 스토리지 컨트롤러: Dell SAS 6/iR Adapter Controller
- GPU: 
- 네트워크 인터페이스
  - 1: MAC 02:15:c5:e8:9c:7a, inet 147.46.240.37/24
- 확장성: 싱글 소켓 LGA1156, DDR3 1333, 최대 메모리 16GB, 메모리 슬롯 4개

### glennfidich

- 물리적 크기: 1U
- KVM 포트: 
- 제품: HP ProLiant DL360 Gen9
- 마더보드: HP ProLiant DL360 Gen9
- CPU: Intel(R) Xeon(R) CPU E5-2640 v4 @ 2.40GHz (10 cores, 20 vCPUs)
- 메모리: 2 x 8GB DDR4 2133MT/s (16GB, total)
- OS 스토리지: 2.5'' HPE VK0240GFLKF SATA3 SSD 240GB
- 데이터 스토리지: 2.5'' HPE MSA MM1000JEFRB SAS-3 7.2kRPM HDD 1TB
- 스토리지 컨트롤러: HPE Smart Array P440ar controller
- GPU: 
- 네트워크 인터페이스
  - 2: eno1: MAC 94:18:82:81:6d:f0, inet 147.46.242.227/24
  - 4: eno3: MAC 94:18:82:81:6d:f2, inet 10.1.0.1/24
- 확장성: 듀얼 소켓 LGA2011-3, DDR4 2133 (CPU 종류에 따라 동작 속도 상이함), 최대 메모리 RDIMM 기준 768GB, LRDIMM 기준 3TB, 메모리 슬롯 24개, 8 x 2.5'' SAS/SATA

### jackdaniels

- 물리적 크기: 1U
- KVM 포트: 
- 제품: HP ProLiant DL360 Gen9
- 마더보드: HP ProLiant DL360 Gen9
- CPU: Intel(R) Xeon(R) CPU E5-2640 v4 @ 2.40GHz (10 cores, 20 vCPUs)
- 메모리: 2 x 8GB DDR4 2133MT/s (16GB, total)
- OS 스토리지: 2.5'' HPE VK0240GFLKF SATA3 SSD 240GB
- 데이터 스토리지: 2.5'' HPE MSA MM1000JEFRB SAS-3 7.2kRPM HDD 1TB
- 스토리지 컨트롤러: HPE Smart Array P440ar controller
- GPU: 
- 네트워크 인터페이스
  - 2: eno1: MAC 94:18:82:81:1d:14, inet 147.46.242.203/24
  - 4: eno3: MAC 94:18:82:81:1d:16, inet 10.1.0.2/24
- 확장성: 듀얼 소켓 LGA2011-3, DDR4 2133 (CPU 종류에 따라 동작 속도 상이함), 최대 메모리 RDIMM 기준 768GB, LRDIMM 기준 3TB, 메모리 슬롯 24개, 8 x 2.5'' SAS/SATA

## 하드웨어실습실 네번째 서버랙

### oloroso

- 물리적 크기: 1U
- KVM 포트: 
- 제품: HPE ProLiant DL20 Gen10
- 마더보드: HPE ProLiant DL20 Gen10
- CPU: Intel(R) Xeon(R) E-2236 CPU @ 3.40GHz (6 cores, 12 vCPUs)
- 메모리: 16GB DDR4 2666MT/s
- OS 스토리지: 2.5'' Samsung 870 EVO SATA3 SSD 4TB
- 데이터 스토리지: 
- 스토리지 컨트롤러: 
- GPU: 
- 네트워크 인터페이스
  - 2: eno1: MAC b4:7a:f1:2d:a2:b8, inet 147.46.241.60/24
- 확장성: 싱글 소켓 LGA1151, DDR4 2666, 최대 메모리 64GB, 메모리 슬롯 4개, 6 x 2.5'' SAS/SATA

## 공대신양 서버랙

### ramos

TODO: 서버 정보를 채워넣으세요. ipmi 세팅 정보도 같이 기입해주세요.

### gin

TODO: 서버 정보를 채워넣으세요. ipmi 세팅 정보도 같이 기입해주세요.

### fizz

TODO: 서버 정보를 채워넣으세요. ipmi 세팅 정보도 같이 기입해주세요.

### ford

TODO: 서버 정보를 채워넣으세요. ipmi 세팅 정보도 같이 기입해주세요.

### bentley

TODO: 서버 정보를 채워넣으세요. ipmi 세팅 정보도 같이 기입해주세요.

## 컴퓨터연구소 서버랙

### ferrari

TODO: 서버 정보를 채워넣으세요. ipmi 세팅 정보도 같이 기입해주세요.
