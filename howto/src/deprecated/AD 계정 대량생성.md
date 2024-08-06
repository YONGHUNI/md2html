AD 계정 대량 생성
---
> 작성자: 서장호, 이진우, 정모두하리, 노윤미

## 개요

* 뭐하는 짓거리인가: 랜덤 패스워드를 가진 수업용(실습용) AD 계정을 한번에 대량으로 생성한다
* 언제 필요한가: 학기 초 (또는 방학 말에) 수업 조교가 요청할 경우
* 왜 필요한가: 스누씨 통합계정이 없는 (즉, 주전공생 또는 제2전공생이 아님) 수강생을 위해서 필요하다
* 어떤 효과가 있는가: 이 계정을 가진 수강생은 실습실 PC에 로그인할 수 있고, 마티니나 미모사 등의 실습 서버에 로그인할 수 있다
* 어떻게 만드는가
    * 랜덤 패스워드의 생성: 여러 툴이 있지만 여기서는 `pwgen` 이라는 유틸리티를 사용한다.
    * 계정 대량생성: Domain Controller에 원격 데스크톱으로 연결해 PowerShell을 실행시킨다
* 이후 주의사항: 해당 학기가 끝나면 잘 계정을 회수해야 한다

## 패스워드 랜덤 생성하기

130개의 임시계정을 생성한다고 치자.

리눅스 환경에서 `pwgen` 유틸리티를 이용하여 아래와 같이 입력한다.

```bash
pwgen -1 7 130 > passdb.txt
```

* 총 7글자로 된 패스워드를
* 한 줄에 하나씩
* 130개 만들어서
* passdb.txt 로 저장하라는 명령어다.

이 텍스트 파일을 Windows에서 열면 개행 문자 차이로 인해 이상하게 보일 것이다. 사전에 이를 방지하자.

```bash
unix2dos passdb.txt
```

## 계정 생성하기

도메인 컨트롤러 (colada나 pina) 에 원격 데스크톱 연결을 건다. 그리고 앞에서 생성한 passdb.txt를 도메인 컨트롤러 서버로 전송한다. (그 방법은 각자 알아서.. 메일로 보내건 개인 서버에 업로드하건. 다만 외부에 유출되지는 않도록 조심한다)

시작 메뉴에서 PowerShell ISE를 연다. 
열어서 아래 colada 항목의 스크립트를 입력한다.
스크립트를 실행하고, 아이디와 패스워드를 잘 정리해서 조교에게 알려주면 된다.

### colada
Window Server 2008 R2 기준(현재 colada)으로 다음과 같은 내용을 입력하면 된다.

* `NUMBER`: 생성하려는 계정의 갯수
* `PASS_PATH`: password가 적힌 파일의 경로. 가령 `C:\Users\Bacchus\Documents\ADAccountCreate\passdb.txt`
* `ID`: 계정의 아이디. 예컨대 pp1~pp50의 계정을 생성하려고 한다면, pp가 ID이다.
* `DISPLAY`: 계정을 표시할 때 사용되는 이름
* `DESCRIPTION`: 계정에 대한 설명

```
for ($i=0; $i -le NUMBER; $i++){
    $pass = Get-Content PASS_PATH | Select -first 1 -skip $i;
    dsadd user "CN=ID$($i+1),OU=Temporary,OU=Users,OU=CSE,DC=snucse,DC=org" -pwd $pass -hmdir \\kof.snucse.org\Profile\ID$($i+1) -display DISPLAY -desc DESCRIPTION
    Write-Host $i;
```

* `dsadd`: 계정을 대량으로 생성하는 명령어.
    * 사용예: `dsadd user [사용자DN] -display [표시 이름] -desc [설명]  -hmdir [홈디렉토리] -pwd [비밀번호]`
        * 사용자DN
            * CN: 사용자이름
            * OU: 조직 단위를 나타내며, 일반적으로 계층구조의 디렉터리에 해당하며, 낮은 계층 부터 순차적으로 써주면 된다.
            * DC: 도메인 이름에 해당하며, 하위 도메인 이름 부터 써준다.
        * 표시 이름 : 사용자 이름을 한글로 넣는다.
        * 설명: 사용자 이름이나, 계정에 대한 짧은 설명을 넣는다.
        * 홈디렉토리: 홈디렉토리가 백업되는 위치.
        실습실은 bacchus-sync를 통해서 sherry에서 받아오나, 윈도우에서는 그렇지 않다.
        윈도우 프로필이 저장되는 `\\kof.snucse.org\Profile\USERNAME`를 입력해준다.
        * 비밀번호: 계정 로그인시 사용하는 비밀번호.
* `Wrie-Host $i`: 이 명령어는 현재 몇번째 계정 작업이 끝났는지 알려준다.

### pina

아래는 2017년에 사라진 pina 서버에서 가능한 방법이다.(Window Server 2012 R2)
혹시 나중에 참고할 일이 있을지 모르니, 기록만 남겨둔다.


```
for ($i=0; $i -le 129; $i++)
{
    $pass = Get-Content C:\Users\Bacchus\Documents\ADAccountCreate\passdb.txt | Select -first 1 -skip $i;
    New-ADUser -Name "pp$($i+1)" -AccountPassword (ConvertTo-SecureString -AsPlainText $pass -Force) -Enabled $true -Path "ou=Temporary,ou=Users,ou=CSE,dc=snucse,dc=org"
    Write-Host $i;
}
```

(사실 pina.snucse.org 에는 "C:\Users\Bacchus\Documents\ADAccountCreate\pass.ps1" 에 똑같이 저장되어 있다. 다만 아래의 "129"나 "pp"에 해당하는 부분을 적절히 바꾸는걸 잊지 말 것.)

* for 조건의 "129" 는 생성해야 할 계정이 130개이기 때문이다. 즉 생성하고자 하는 계정의 수 - 1 을 입력한다.
* `C:\Users\Bacchus\Documents\ADAccountCreate\passdb.txt` 가 보이는가? 생성한 passdb.txt는 그 위치에 있어야 한다. 아니라면 passdb.txt를 바꾸거나 스크립트를 고치자.
* `pp$($i+1)` 이 계정의 아이디를 결정한다. 저대로라면 pp1, pp2, pp3, pp4, ..., pp130 으로 생성될 것이다. 과목의 이름에 맞게, 그리고 기존에 존재하는 아이디와 중복되지 않게 잘 바꾸어주자.


## 패스워드 변경

bootstrap에 있는 클라이언트 PAM설정 덕분에, 임시계정 사용자는 실습실 PC에서 passwd 명령어를 통해 AD패스워드를 변경할 수 있다.<br>
단, 이 방법으로 통합계정 패스워드도 변경가능하지만 이 경우 SNUCSE 패스워드와 AD계정 패스워드가 달라지게된다. SNUCSE 사용자는 SNUCSE 마이페이지에서 패스워드를 변경해야한다.
패스워드가 변경되지 않는 경우, PAM 설정의 문제가 있는지 보도록 한다.

## 패스워드 초기화

간혹 비밀번호를 잊어버린 경우가 있다.
이때, colada 서버로 접속하여 Windows powershell에서 `dsmod`를 이용하여 다음과 같이 비밀번호를 초기화해주도록 하자.

```
dsmod user [사용자 DN] -pwd PASSWORD
```

* 사용자 DN: 위의 `dsadd`와 동일하게, CN, OU, DC로 이루어진 정보

tip: `damod`를 통하여 사용자의 여러 정보를 갱신할 수 있다. [MS 공식 페이지](https://technet.microsoft.com/en-us/library/cc732954(v=ws.11).aspx)를 참조하도록 하자.
