# 개요
`bdo`는 실습실 컴퓨터, GPU 서버와 같이 동일한 환경을 가진 여러 대의 컴퓨터를 한 번에 관리하기 위한 쉘 스크립트이다. [lab-private 레포지토리](https://github.com/bacchus-snu/lab-private)의 `bacchus-pcdb` 패키지에 포함되어 있다. 기존의 순차적으로 한 컴퓨터씩 스크립트를 돌리는 방식이 너무 오래 걸려 1.2018.2.2-1 버전부터 모든 대상 컴퓨터에 동시에 접속하도록 수정하였다.

# 사용
## 사용 장소
`bdo`는 `bacchus-pcdb`가 설치되어 있는 모든 컴퓨터에서 실행 가능하다. 하지만 비밀번호를 묻지 않고 ssh 접속을 하기 위한 identity 파일은 sherry 서버에 저장되어 있으므로 주로 sherry에서 `bdo`를 실행한다.

## 사용 전 유의사항
`bdo`를 사용하여 주로 패키지 설치·업데이트 등의 작업을 하게 되는데 이 작업은 꽤나 오래 걸릴 수 있다. `bdo`가 동작하는 중 sherry 서버로의 ssh 접속을 끊어버릴 경우 결과 코드를 확인하지 못하고 진행 중인 작업이 중간에 중단될 수도 있으니 가급적 `tmux` 세션을 안에서 `bdo`를 실행하는 것이 좋다.

## 사용 방법

사용 가능한 옵션은 아래와 같다.
```
Usage: /usr/sbin/bdo [options] <script>
options:
  -s --software     : execute scripts on 302-311-1
  -h --hardware     : execute scripts on 302-310-2
  -sh               : execute scripts on 302-311-1 and 302-310-2
  -l --lounge       : execute scripts on 301-314
  -g --gpu          : execute scripts on gpu servers
  -i <identity>     : selects the private key for authentication
  -o --output <dir> : select directory to save outputs
```
이들 중 `-i`와 `-o` 옵션은 필수 옵션이며, `-s`, `-h`, `-sh`, `-l`, `-g` 중 적어도 하나는 넣어 주어야 한다.

### `-i` 옵션
`-i` 옵션은 비밀번호를 묻지 않고 ssh 접속을 하기 위한 identity 파일을 지정할 때 사용된다. 대상 컴퓨터의 `authorized_keys` 파일에 등록된 public key에 대응하는 private key 파일을 지정하면 된다.

현재 실습실 컴퓨터용 key는 `/home/sherry/script/lab-key`에 있으며, GPU 서버용 key는 `/home/sherry/gpu-server-key`에 있다.

### `-o` 옵션
`-o` 옵션은 각 대상 컴퓨터들의 표준 출력과 표준 에러가 담긴 파일들을 저장할 폴더를 지정한다. 적당히 `/tmp` 같은 곳에 임시로 새 폴더를 만드는 것을 권장한다.

## 결과 확인
`bdo`는 모든 대상 컴퓨터에서 스크립트 실행이 완료된 후 반환 값이 0이 아닌 경우에만 해당 컴퓨터의 이름, IP, 반환 값을 출력한다. 모든 컴퓨터에서 문제가 없었으면(0을 반환하면) 아무 것도 출력하지 않는다. 문제가 생긴 경우, `-o` 옵션으로 지정한 폴더에 들어가 출력 파일을 보며 문제를 고쳐보면 좋다.

## 사용 예시
```sh
bdo -sh -i /home/sherry/script/lab-key -o /tmp/upgrade-log upgrade.sh
```
의미 : 소프트웨어 실습실과 하드웨어 실습실의 모든 컴퓨터에서 upgrade.sh 스크립트를 실행한 후 출력 파일들을 /tmp/upgrade-log 폴더에 저장

# `bdo`용 스크립트 작성 요령
## 사용자의 입력 처리
여러 컴퓨터에서 일괄적으로 스크립트를 실행하는 `bdo`의 특성상 사용자의 입력을 요구하는 스크립트를 작성해서는 안 된다. 스크립트를 표준 입력으로 전송하는 `bdo`의 구현방식 상 스크립트가 표준 입력을 읽을 경우 스크립트의 일부가 입력으로 들어가버려 정상적으로 실행이 되지 않는 문제가 발생할 수 있다. 또한, 스크립트가 사용자의 입력을 기다리며 무한정 대기하는 문제가 발생할 수 있다.

### 입력 방법 1 : 사용자의 입력을 요구하지 않도록 만든다.
다수의 프로그램은 적당한 옵션을 주어 입력값을 미리 제공하거나, 항상 '예'를 선택하게 함으로써 사용자의 입력을 요구하지 않도록 만들 수 있다.

예시)
```sh
sudo apt-get -y install vim
```
apt-get은 원래 설치 여부를 사용자에게 물어보나 `-y` 플래그를 이용하여 묻지 않도록 만들 수 있다.

### 입력 방법 2 : IO 리디렉트를 이용한다.
사용자의 입력이 반드시 필요한 경우, 입력해야 하는 값을 미리 변수에 넣어두고 IO 리디렉트를 이용하여 넣어주는 방법이 있다.

예시)
```sh
input="old-password
new-password
new-password"

passwd <<< "$input"
```

### 입력 대기 문제 해결 방법 : 표준 입력을 `/dev/null`로 리디렉트 한다.
스크립트에서 실행되는 모든 프로그램의 입력을 `/dev/null`로 리디렉트하면 스크립트의 일부가 입력으로 들어가거나 사용자의 입력을 대기하는 문제를 방지할 수 있다.

예시)
```bash
function main() {
    # 실행할 코드 작성
}

main "$@" < /dev/null
```

## 에러 처리
### 오류 코드 반환
쉘 스크립트를 작성할 때는 항상 이전 작업이 정상적으로 완료되었는지 확인한 후에 다음 작업을 실행하도록 만들어야 한다. 작업이 실패할 경우 즉시 오류 코드를 반환하도록 만든다. 또한, 어디서 실패했는지 확인할 수 있도록 반환 값을 모두 다르게 만드는 것이 좋다.

예시)
```bash
cp 'source/file' 'destination/file'
if [ $? -ne 0 ]; then
    exit 100
fi

rm 'source/file'
if [ $? -ne 0 ]; then
    exit 101
fi
```
복사가 성공한 경우에만 삭제 명령이 실행된다. 또한 작업이 실패한 경우, 100이 반환되었는지, 101이 반환되었는지를 확인하여 어디서 실패했는지를 확인할 수 있다.

### 서브쉘에서의 에러 처리
파이프라인을 이용하여 `while`이나 `for` 등을 사용할 경우 해당 코드는 서브쉘에서 실행된다. 이 경우 `exit`을 하여도 쉘 스크립트 전체가 종료되는 것이 아닌, 서브쉘만이 종료되어 다음 스크립트를 실행하게 된다. 따라서 서브쉘을 사용하는 코드 뒤에 오류 체크 코드를 한 번 더 넣어줘야 한다.

예시)
```bash
find . -name '*.txt' | while read file; do
    chmod 644 "$file"
    if [ $? -ne 0 ]; then
        exit 100
    fi
done

if [ $? -ne 0 ]; then
    exit $?
fi
````
위 코드의 경우 while부터 done까지가 서브쉘에서 실행되므로 4번째 줄의 `exit 100`은 서브쉘만을 종료시킨다. 따라서 8번째 줄에서처럼 서브쉘의 반환 값을 확인해줘야 한다.
