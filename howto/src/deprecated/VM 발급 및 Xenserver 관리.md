


VM 발급 및 Xenserver 관리
----

> 작성자: 이은서 노윤미 이진우

## Xenserver

### 개요

수업에서 가상머신을 요청하는 경우가 종종 있다.
가상머신 발급에 사용하는 xen server를 다루는 방법에 대해 설명한다.

### 배경지식

* 최신 버전을 받으면 연결이 안 되는 문제가 있기 때문에 옛날 버전을 받는다.
아직 fizz가 6.5 버전, rum이 6.1이므로 6.5 버전을 사용한다.
추후 버전 업데이트가 필요하다.
(7 버전부터는 하위버전과 호환성이 상실되었다.)
* 접속은 xencenter 뿐만 아니라 ssh로도 가능하다.
이때 rum, fizz는 학외서버를 통해서는 접속이 불가능하다.
마티니 등을 통해 우회하면 된다.
대부분 xe 명령어를 통해서 작업이 가능하지만, 복잡해서 문서화가 필요하다.
xsconsole 명령어를 사용한다.
* fizz, rum은 기본 계정이 fizz와 rum이 아니라 root이다.
이는 최초 설치할 때 xencenter 설정을 하지 않았기 때문이다.
나중에 재설치할 때는 각각 fizz와 rum 계정을 사용하도록 하는 것이 좋겠다.

## xapi

### 개요

xen server관리를 쉽게 해주는 xen center라는 프로그램이 있다.
xen ceter에서 서버에 접근하려면 `xapi`가 켜져있어야 한다. 
`xapi`가 켜져있으면 http 접속이 가능해지기 때문에,
보안상 문제가 생기게 된다.
따라서 반드시 작업 후 종료하도록 한다.
아래에서 이 `xapi`를 활성화하고 비활성화 하는 방법에 대해서 설명한다.

### xapi 활성화

1. ssh 접속을 한다. 
이때 rum과 fizz의 경우 학외에서 접속이 막혀있으니,
학내 서버에서 터널링 하는 등의 방식으로 접속한다.
fizz와 rum은 현재 root 계정을 사용하고 있다.
1. `xsconsole`을 입력하여 콘솔 모드로 들어간다.
이때 콘솔을 사용하지 않고 `xe` 명령어를 사용하는 방법도 가능하다.
이 부분은 추가적인 문서화가 필요하다.
1. xapi 경고문이 뜨는 것을 확인 가능하다.
이는 xapi가 켜져 있는 경우, 해당 서버에 http 접속이 가능해지기 때문이다.
따라서 당황하지 않고 `<F8>`을 눌러서 켜면 된다.

### xapi 비활성화

1. 서버 콘솔을 띄운다. 다음 두 가지 방법을 쓸 수 있다.
    1. xencenter에서 서버 이름 클릭 후 우측에 `consol` 탭을 클릭, 엔터를 눌러 접속
    1. ssh로 서버에 접속
1. 아래의 두 가지 방법 중 하나를 선택하여 xapi를 다시 종료한다.
    1. 콘솔에서 `service xapi stop`을 입력
    1. `netstat -tlnp` 입력 후 `stunnel`의 pid 확인 후 `kill [pid]` 입력 (안되는 경우가 있으니 잘 확인하자)
1. http 접속하는 것으로 확인. 접속이 되지 않으면 정상적으로 종료된 것이다.



## XenCenter

- [Remmina](https://remmina.org/) 또는 Windows의 원격 데스크톱 연결을 이용하여 colada.snucse.org에 연결하면, colada에 설치된 XenCenter를 사용할 수 있다.
  - username: Bacchus
  - Domain: CSE
  - password: Windows 서버 패스워드

### 다운로드

[여기](http://xenserver.org/open-source-virtualization-download.html)에서 6.5 버전을 다운로드한다.
버전 7에서는 버전 하위 호환이 되지 않는다.
지금 사용하는 건 버전이 6.x라 접속 가능하다. 
빠른 시일 내 럼과 피즈 재설치가 필요하다.


### 접속

1. 윈도우에서 XenCenter를 켠다.
1. 접속하고자 할 서버를 리스트에서 더블클릭 혹은 `add new server` 클릭 후 접속. 접속할 때 root로 접속.
1. 버전이 낮으면 라이센스가 만료되었다고 경고를 하지만 무시하도록 한다.
1. 왼쪽 상단에 vm목록이 있다.
1. 버전이 높으면 `Memory`에 서버의 중요한 정보들이 있으니 참고하면 된다.

### fizz의 메모리 확인

우상단 memory tab : 현재 메모리들을 확인 가능

rum의 경우 버전이 6.1이라서 메모리를 확인하는 것이 유료이다.
또한 예전에 메모리가 논리적으로 오류가 난 적이 있는 등 조금 불안정한 서버이다.
재설치가 시급합니다.

### shutdown

vm을 종료하는 것. 메모리가 사라지지 않는다.
서버명-우클릭-`shut down`으로 종료해도 된다.
1 개월 ~ 한 학기 가량이 지난 후 아래와 같이 delete VM 하여 메모리를 회수하자.

* cf: 해당 머신에서 연결한 맥주소를 완전히 지우지 않고,
같은 맥주소를 다른 VM에 할당하면 `The MAC address entered has already been assigned to the VM`과 같은 메시지를 띄우며 에러가 나게 된다.
따라서 아이피를 회수할 때는 맥 주소도 같이 지우도록 한다.

### delete server

왼쪽 리스트에서 삭제할 vm을 선택하고 우클릭 후 제거 클릭.
서버명-우클릭-`delete VM`으로도 삭제 가능하다.

수업에서 요청하여 발급한 서버는 반드시 해당 학기 종료로부터 학기가 지난 후 삭제하도록 한다. 
예를 들어 2016년 봄 학기 컴퓨터프로그래밍 과목의 경우 2016년 가을학기가 끝난 후에 삭제하도록 한다.
간혹 수업 자료의 백업을 요청하는 경우가 있기 때문이다.

### add server(가상 머신 발급해주기)

#### colada에서 joker에 VM 생성

1. colada에 원격 접속한 뒤 xencenter를 실행한다.
1. 왼쪽 Bacchus를 더블 클릭한 뒤 joker에 접속한다.
1. new VM 버튼
1. snapshot된 template 선택
1. {Year}{Semester}-{Course} 같은 이름을 넣고 설명을 추가한다.  
이와 같이 이름을 짓지 않을 경우,
지워도 되는 서버인지 판단할 수 없어서 지우지 않고 방치하는 경우가 생길 수 있다.
반드시 **수업명, 발급년도, 학기** 의 정보를 포함하도록 한다.
1. OS image들이 담겨있는 서버인 skyy에 있는 이미지 목록이 나타난다. 설치할 이미지를 선택한다.
1. Home Server, CPU & Memory, GPU, Stroage는 특별한 요청이 없을 경우 기본 값으로 진행
1. Networking에서 Edit을 클릭하여 바쿠스IP목록 내 할당할 ip의 mac 입력
1. 확인 후 Finish



#### VM 생성

1. `add sever` 버튼을 눌러 fizz 서버를 추가한다.
1. new VM 버튼
1. 요청된 서버를 설치하기 위해 `Other install media`
1. ComputerNetwork2016Autumn 같은 이름을 넣고 설명을 추가한다.
이와 같이 이름을 짓지 않을 경우,
지워도 되는 서버인지 판단할 수 없어서 지우지 않고 방치하는 경우가 생길 수 있다.
반드시 **수업명, 발급년도, 학기** 의 정보를 포함하도록 한다.
1. OS image들이 담겨있는 서버인 `images.fizz.snucse.org`에 있는 이미지 목록이 나타난다.
(아래 `서버 이미지 관리` 항목에서 상술)
이미지를 선택한다.
1. vCPUs(코어 갯수라고 생각하면 됨)와 memory 선택
vCPUs는 특별한 요청이 없을 경우 2~3 정도로 준다.
memory는 요구받은 것이 있으면 그만큼을, 없는 경우 2기가 내외로 주도록 한다.
1. 우측 ADD버튼을 누른다.
이름은 보통 VM 이름과 같이 해준다.
HDD는 vCPUs나 memory와는 달리 재설정 후 재부팅으로 되는 것이 아닐 것이라(?) 좀 더 넉넉하게 주어야 한다.
특별한 요청사항이 없으면 10기가 내외를 주도록 한다.
확인 후 next

#### Network

1. 구글드라이브의 ip adress table 중 미사용인 ip중 적당한 것을 골라잡는다.
    * 작동중인 IP
        * 학외 TCP 22 열림 &larr;  실습용으로 굳
        * 안 열림 &larr; 열려면 중전과 연락해야함 = 귀찮
    * 안되는 IP &larr; 정 다른 IP가 안 되면 일단 연결을 해보고 안 되면 반납한다.
혹은 시간 날때 테스트 해본다.
충돌되는 경우는 대략 10초 정도 주기로 연결이 되다 안되다 함.
그리고 중전에서 연락이 오면 확실히 안 되는 것이다.
1. 4개가 목록에 있을텐데, 아무거나 세개를 지운다.
나머지 하나 선택-프로퍼티즈-선택한 IP의 맥주소 입력(시트에도 사용으로 바꿔줘야 한다)-ㅇㅋ 선택
IP는 OS에게 따로 알려주는 것

#### OS 설치(아래에서는 우분투 16.04를 기준으로 설명)
1. 해당 VM의 Console로 이동
1. 언어 선택 - install - 다른 것은 다 default 따라가되 국적만 한국으로 잘 해준다.
1. hostname은 대충 수업명에서 따온다.(그리고 IP 구글 시트도 바꿔준다.) 
ex. 컴퓨터 네트워크 &rarr; cn.snucse.org
1. username/username for account: 둘다 걍 통일해서 ta로 하면 편하다(?)
1. password: https://strongpasswordgenerator.com/ 에서 만들어서 줘야 한다.
안그러면 취약한 비밀번호 학기내내 쓰다 털릴 수도.
10자정도로 길게 해본다.
1. Encrypt home dir.? : no (귀찮음)
1. Partition disk: unmount 원하냐고 나오면 yes.(no를 누르면 설치하다 error)
1. Partition disk: use entire disk 정도만 해도 괜찮다. LVM 을 쓰고 싶다면 먼저 조사해보면 좋을 것
1. 그다음에는 적당한 파티셔닝을 해준 것을 볼 수 있는데확인해가면서 넘어가면 된다.(no를 누르면 더 자세한 내용을 볼 수있다)
1. HTTP proxy information: 필요없으므로 빈칸으로 두고 엔터
우회할때 빼고는 별로 안 필요함.
1. [tasksel](https://help.ubuntu.com/community/Tasksel): 패키지를 적당히 묶어놓은 것.
보통 ssh만 활성화해서 준다.
1. 옵션이 세가지
    * No automatic updates
    * Install security updates automatically
    * landscape - 우리가 쓸 것이 아님
위에 둘 중에 결정
1. 부트 로더? : yes // 다른 부트로더 있으면 grub 위에 그것이 덮어씌여질 수 있기 때문에 물어보는 것
1. 자동 보안 업데이트 : 조교한테 알아서 하라고 할 수도 있고, 우리가 할 수도 있음

#### 도메인 연결
{course name}.snucse.org 와 IP를 연결해줘야 한다.
https://www.cloudflare.com/ko-kr/ 들어가서 하면 됨.

로그인한 뒤 snucse.org 클릭 후 상단 메뉴 중 DNS 클릭
Add record 하고 이름(course name), IP주소는 미리 고른 것 입력, proxy status는 DNS only로 바꾼 후 Save


#### 맥주소 확인

`ip link show`
해서 나오는 것에서 맥 주소가 잘 나오는지 본다.

#### ip 연결

OS 설치가 끝나면 다음과 같이 ip를 연결을 해준다.
우선 /etc/network/interfaces에서 해당 network interface 설정을 아래와 같이 바꾸어준다.
```
NETWORK_INTERFACE_NAME: 위에서 찾은 이름
SERVER_IP_ADDR: 해당 서버의 IP. 구글 드라이브에 정보가 있다.
SERVER_GATEWAY_ADDR: 서버 IP의 앞 세 블럭은 그대로 쓰되, 마지막 블럭을 1로 바꾼다.
```
```
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto NETWORK_INTERFACE_NAME
iface NETWORK_INTERFACE_NAME inet static
    address SERVER_IP_ADDR
    netmask 255.255.255.0
    gateway SERVER_GATEWAY_ADDR
    dns-nameservers 8.8.8.8
```
이후 `sudo reboot` 해서 ip 연결되도록 한다.
`ping google.com`했을 때 핑이 잘 가지 않는다면 다음과 같은 이유들을 생각해 볼 수 있겠다.

1. 우리가 잘못함
    * 맥주소를 확인해본다 &rarr; 틀린 경우: `sudo poweroff` &rarr; xencenter 콘솔로 맥주소 다시 설정해줌
    * IP를 확인해본다
    
1. 안되는 IP: 
애초에 잘 안 되는 IP들이 있다. 
딱히 설정상의 문제가 없다면 IP 자체에 문제가 있을 수 있으니, 다른 IP를 사용해본다.
다른 IP로 바꾸었을 때 잘 된다면, IP의 문제가 맞으므로 해당 IP가 잘 안 된다는 것을 꼭 기록으로 남기도록 한다.

핑이 잘 간다면 ssh 접속 되는지 확인한다.
문제가 없다면 모든 세팅이 끝난다.

#### 후처리

* xencenter에서 xapi를 꼭 꺼준다. 이는 위 #xapi 비활성화 항목을 참고하자.
* 수업용 가상머신 발급이라면 조교에게 메일을 보내 계정, 도메인, 사양 등을 알려준다.
* 깃헙 이슈트래커 혹은 깃헙 프로젝트에 자원 회수 이슈를 추가한다.
* 도메인 및 IP 발급은 [서버실 IP](https://docs.google.com/spreadsheets/d/1P_fADVs9LJ1xee0VdylUlsEK5yBlYvpZ1nuvFPFqHhk/edit#gid=864214807) 문서에 추가하고,
자원 발급 내역은 각 학기별 자원 발급 내역 문서에 추가한다.

### 똑같은 VM을 동시에 여러대 만들기
1. 우선 Template을 만들기 위한 VM을 하나 파서 완전히 설치와 설정을 끝내 놓는다.
1. VM template을 만들기 위한 VM snapshot을 하나 만들어 놓는다. (VM을 사용하는 경우 상관없음)   
    * VM snapshot은 VM을 우클릭하여 Take a snapshot하면 만들어진다. 이 때, 적절한 이름과 설명을 붙여주자. 또한, VM을 꺼놓는것을 권장한다.
    * 만들어진 snapshot은 해당 VM의 우측 영역에서 Snapshots탭을 클릭하면 확인할 수 있다.
1. 생성된 VM을 꺼놓는다. (Snapshot을 사용하는 경우는 상관없음)
1. 꺼진 VM을 우클릭하여 Convert to Template 항목을 선택한다.
1. 경고창이 뜨는데 이는 Template으로 바꾸고 나면 실행 취소가 안된다는 의미의 메세지를 출력한다. Convert를 클릭하자.
1. 잠시 기다리면 Template이 좌측 항목 아래 쪽에 나타난다. Template이 나타나면 우클릭하고 Quick Create를 눌러주면 알아서 똑같은 VM이 만들어진다.
1. 이것을 n번 하면 똑같은 VM이 n개 생성된다. 



## 서버 이미지 관리

xencneter에서 VM 발급시 OS image들을 매번 다운로드 하지 않기 위해서 이미지를 호스트하고 있다.

* 도메인: `images.fizz.snucse.org`
* 계정: bacchus
* 위치: `/srv/images`

이 위치에 이미지를 넣으면 xencenter에서 손쉽게 이미지를 받아올 수 있다.

## recovery mode(ubuntu)
root 계정의 비밀번호를 분실하였거나, sudo 계정으로 로그인이 불가능한 경우 등이 있을 수 있다.
이때는 보통 grub menu에 들어가서 single mode로 부팅을 시도한다.
그러나 Xencenter에서는 부팅 중에 키 입력을 받지 않아 grub menu에 진입이 불가능하다.
따라서, 우분투 부팅 이미지파일을 이용해서 설치 모드로 들어가 recovery mode를 이용하기로 한다.

Xencenter에서 서버의 콘솔 탭으로 들어간다.
서버를 끈 뒤, 상단 탭 아래에서 볼 수 있는 셀렉트박스에서 우분투 이미지를 선택해준다.
서버를 다시 켜면, 우분투 설치 화면으로 진입한다.
화면의 하단에 있는 recovery mode를 선택한다.

1. `Device to use as root file system:`이라는 질문이 나오기 전까지는
우분투 설치할 때와 동일하게 한다.
해당 질문에는 현재 서버의 HDD를 선택하는데, 보통 기본 옵션으로 잡혀있을 것이다.
(ex. `/dev/xvda1`)
1. `Rescue opreation`에서는 셸을 실행하기 위해서
`Execute a shell in /dev/xvada1`을 선택한다.
1. 화면 하단에서 root 권한으로 셸이 실행되는 것을 확인할 수 있다.
