# Bluespec
Ubuntu 16.04 Xeniel 기준으로 작성된 문서입니다.

## installation
- [Bluespec-2014.07.A.tar.gz](http://bluespec.com/forum/download.php?id=206) 에서 다운로드.
- Username: `taejin1999`, Password: `1q2w3e`
    - 계정승인이 잘 안된다고 함. 김지홍 교수님 연구실에서 제공한 계정 사용
- `/opt/`에 압축 해제
```
tar xvzf Bluespec-2014.07.A.tar.gz /opt
```

## env & license
- `/etc/profile.d/bluespec.sh` 를 다음과 같이 작성한다.
```sh
export BLUESPEC_HOME=/opt/Bluespec-2014.07.A
export BLUESPECDIR=$BLUESPEC_HOME/lib
export PATH=$PATH:$BLUESPEC_HOME/bin
export BLUESPEC_LICENSE_FILE=@hyewon
```
- `/etc/hosts` 파일에 `147.46.241.65 hyewon` 라인을 새로 추가
    - 컴파일 시 hyewon서버(hyewon.snu.ac.kr)의 라이센스를 이용하도록 설정하는 것
- `echo $BLUESPEC_HOME`등을 하여 잘 반영되었는지 확인한다.

## library load
- 포함되어있는 라이브러리 로드
```
cd /etc/ld.so.conf.d
sudo touch bluespec.conf
echo "${BLUESPECDIR}/SAT/g++4_64" | sudo tee /etc/ld.so.conf.d/bluespec.conf
sudo ldconfig
```

- `libgmp.so.3`
```sh
sudo apt install -y libgmp10
cd /usr/lib/x86_64-linux-gnu
sudo ln -s libgmp.so.10 libgmp.so.3
```

- `iverilog`
```sh
sudo apt install -y iverilog
```

- `bluetcl` dependency
```sl
sudo apt install -y libfontconfig1 libxft2
```

## Test
- 라이센스가 적용되지 않으면 bsc 명령이 진행되지 않는다
```sh
cp -pr ${BLUESPEC_HOME}/training/BSV/labs/smoke_test ~/tmp
cd ~/tmp
make smoke_test
```
- 아래 명령에서 not found 인 라이브러리가 없어야 함
```
ldd ${BLUESPECDIR}/bin/linux64/bsc
ldd ${BLUESPECDIR}/bin/linux64/bluetcl
```


## 전체 스크립트
- 테스트는 포함되어있지 않으므로 아래 스크립트 실행 후 쉘을 다시 시작하고 테스트를 실행해야 한다.
- 여러번 실행시 `/etc/hosts`에 중복해서 덧붙여지므로 그 정도만 주의하자.
```bash
#!/bin/bash
# add host
sudo tee -a /etc/hosts <<EOF
147.46.241.65 hyewon
EOF

# set env
cd /etc/profile.d/
sudo touch bluespec.sh
sudo tee bluespec.sh <<EOF
export BLUESPEC_HOME=/opt/Bluespec-2014.07.A
export BLUESPECDIR=\$BLUESPEC_HOME/lib
export PATH=\$PATH:\$BLUESPEC_HOME/bin
export BLUESPEC_LICENSE_FILE=@hyewon
EOF

# load library in bluespec
cd /etc/ld.so.conf.d/
sudo touch bluespec.conf
sudo tee bluespec.conf <<EOF
/opt/Bluespec-2014.07.A/lib/SAT/g++4_64
EOF
sudo ldconfig

# install dependancy
sudo apt install -y libgmp10
cd /usr/lib/x86_64-linux-gnu
sudo ln -s libgmp.so.10 libgmp.so.3

sudo apt install -y iverilog
sudo apt install -y libfontconfig1 libxft2
```
