DNS 설정하는 법
========
> 이은서

[Colada 서버에 접속](connect-windows-server-from-os-x.md)합니다.
- PC name   : `colada.snucse.org`
- User name : `CSE\bacchus`

<kbd>Windows</kbd> + <kbd>R</kbd> 키로 `실행` 창을 켜고, 아래를 붙여넣어 DNS
관리 프로그램을 실행합니다.
```
%SystemRoot%\system32\mmc.exe %SystemRoot%\system32\dnsmgmt.msc /s
```

#### 새 호스트 추가
`정방향 조회 영역`에서 새 호스트를 추가하고자 하는 영역을 선택하고, 우클릭 혹은
상단의 `동작(A)` 메뉴 선택 후 `새 호스트(A 또는 AAAA)`를 선택합니다.

아래 그림과 같이 `이름`과 `IP 주소`를 입력한 뒤 `호스트 추가`를 누릅니다.

![](img/dns-newrecord-1.png) ![](img/dns-newrecord-2.png)

#### 기존 호스트 삭제

`정방향 조회 영역`에서 삭제하려는 호스트가 있는 영역을 선택하고, 우클릭 혹은
상단의 `동작(A)` 메뉴 선택 후 `삭제`를 누릅니다.

![](img/dns-delete.png)
