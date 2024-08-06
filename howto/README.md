# Bacchus Howto 문서

여기에서는 바쿠스에서 작성한 매뉴얼을 확인할 수 있습니다.

## 문서 작성하는 법

기본적으로 `src` 디렉토리 내에서 작업을 시작합니다.

1. 새로운 브랜치를 만듭니다.
2. 적절한 위치에 마크다운 문서를 작성하거나 수정합니다.
3. 필요한 경우 (예를 들어, 새로운 문서를 작성한 경우) `SUMMARY.md` 를 수정합니다.
4. PR을 생성한 후 리뷰를 거쳐 메인 브랜치에 반영합니다.

`SUMMARY.md` 파일의 자세한 작성법은 [mdBook 문서][mdbook-docs]를 참고해주세요.

## 빌드 및 배포

빌드 및 배포는 GitHub Actions를 이용하여 진행합니다.

* PR을 생성하면 빌드 후 프리뷰 페이지를 배포합니다. 이 링크는 Job Summary에서 확인 가능합니다.
* 메인 브랜치에 반영되면 빌드 후 프로덕션 페이지를 배포합니다.

만약 로컬에서 빌드를 하고 싶은 경우, mdBook을 사용하여 빌드합니다.  
이는 Rust 및 Cargo를 사용하여 설치하거나, 미리 컴파일된 바이너리 파일을 받아서 진행할 수 있습니다.

다음은 바이너리 파일을 받아서 빌드를 진행하는 예시입니다.

```console
cd howto

mkdir -p bin
wget -qO- \
  https://github.com/rust-lang/mdBook/releases/download/v0.4.23/mdbook-v0.4.23-x86_64-unknown-linux-gnu.tar.gz | \
  tar -xvz --directory=bin
wget -qO- \
  https://github.com/badboy/mdbook-mermaid/releases/download/v0.12.6/mdbook-mermaid-v0.12.6-x86_64-unknown-linux-gnu.tar.gz | \
  tar -xvz --directory=bin

export PATH=$PWD/bin:$PATH
mdbook build
```

빌드 결과물은 `book` 디렉토리에서 확인 가능합니다.

## 문서 확인

배포한 문서는 [여기][bacchus-howto]에서 확인할 수 있습니다.  
참고로 Cloudflare Access를 이용하고 있으며, 접속 후 바쿠스 이메일로 구글 로그인을 진행하여야 접근 가능합니다.

[mdbook-docs]: https://rust-lang.github.io/mdBook/format/summary.html
[bacchus-howto]: https://howto.bacchus.io/
