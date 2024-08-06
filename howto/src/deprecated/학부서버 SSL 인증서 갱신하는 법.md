# 학부서버 SSL 인증서 갱신하는 법
> 작성자: 박재현, 최원우

## 개요
학부서버의 SSL 인증서가 만료되었을 때 인증서를 직접 갱신하는 방법이 필요하다.

## 방법
1. ssh를 통해 `cse.snu.ac.kr`에 접속한다.
1. certbot이 환경변수에 추가되어있지 않고, 홈 디렉토리에 있다. 그러므로 `cd certbot`으로 들어간다.
1. `sudo service apache stop`으로 아파치를 정지시킨다. 
1. `./certbot-auto renew --standalone` 으로 인증서를 갱신한다.
1. `sudo service apache start`으로 다시 아파치를 시작한다.

## TODO
- webroot 인증으로 바꾸기
