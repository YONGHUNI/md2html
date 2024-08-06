# 실습용 VM 발급

## Overview

## 1. 실습환경 접수 설문 발송

- 이전학기 보낸 내용을 참고하여 보낸다.
- VM 스팩 기본값 (CPU, RAM, OS 버전 등)은 변경이 필요하면 변경한다.
  - 특히, 이전 학기 이후 Ubuntu Server LTS 신규 버전이 릴리즈된 경우 버전을
    변경한다.

## 2. MAC 주소 할당

MAC 주소 충돌을 방지하기 위해 신청이 들어오는데로 MAC 주소를 발급한다.

1. bartender 클러스터에 접근한다.
   - [bartender](../infra/bartender.md) 문서 확인.
2. Container를 생성한다.
   - 이름은 적당히 설정한다 (예: 2024-spring-address-holder)
   - MAC 주소를 들고만 있는 용도이기 때문에 설정은 크게 상관이 없다.
   - 설정 후 부팅하지 않는다.
3. Network 탭에서 VM 개수만큼 interface를 추가한다 (기본설정된 interface 포함).
   - 설정도 모두 기본설정으로 한다.
4. MAC 주소마다 정보화본부에 IP 주소를 신청한다.
   - SSH 포트 개방도 반드시 같이 신청한다.

## 3. "Full VM" 발급

1. VM template를 생성한다.
   - 설정 화면 하단에 있는 Advanced checkbox를 선택한다.
   - General
     - Name: 설문에서 "강좌를 잘 표현할 수 있는 영문 약어"에 따라서 설정한다.
       (예: ds-template, sp-template)
   - OS
     - ISO image: 설문의 "가상머신 사양 및 환경" 요청사항에 따라서 설정한다.
   - System
     - Graphic card: VirtIO-GPU.
     - Qemu Agent: 켠다. OS가 지원하는 경우 IP 주소 등을 proxmox에서 확인할 수
       있게 된다.
   - Disks
     - Disk size (GiB): "가상머신 사양 및 환경" 요청사항에 따라서 설정한다.
     - Discard: 켠다.
     - SSD emulation: 켠다.
   - CPU
     - Type: host
     - Cores: "가상머신 사양 및 환경" 요청사항에 따라서 설정한다.
       - 기본 설정이 range인 경우 총 발급 필요한 VM 개수 등을 고려해서 설정한다.
   - Memory
     - Memory (MiB): "가상머신 사양 및 환경" 요청사항에 따라서 설정한다.
   - Network
     - MAC address: "MAC 주소 할당" 에서 생성된 MAC 주소 중 하나를 설정한다.
     - MTU: 1 (inherit bridge MTU)
2. VM template 부팅하고 설치 진행한다.
   - 사욘자는 "ta" 로 설정하고, 비밀번호는 랜덤생성 후 저장한다.
   - 네트워크는 선택한 MAC 주소에 맞게 설정한다.
   - qemu-guest-agent, fail2ban 설치한다.
3. 설정 완료된 VM은 template으로 전환한다.
   - More -> Convert to template
4. Clone으로 VM 생성한다.
   - Network 탭에서 MAC 주소를 설정한다.
   - 부팅 후 hostname, 네트워크 설정을 수정한다.

## 3. "OS 컨테이너" 발급

TODO

## 4. DNS 설정

[`bacchus-snu/infra/dns_hosts.tf`](https://github.com/bacchus-snu/infra/blob/main/dns_hosts.tf)에 추가하고 적용한다.

## 5. VM 사용 안내

- 실습환경 접수 설문에 응답한 이메일 주소로 보내고, 다음 정보를 반드시 포함한다:
  - hostname (예: ds01.snucse.org)
  - username, password
  - 사용 기간.
  - 보안 관련 당부사항.
