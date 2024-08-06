# Btrfs
[Btrfs]는 리눅스 커널에 내장된 CoW (Copy on Write) 파일시스템이다. 백업과 파일시스템 복사가 용이해
바쿠스에서 주로 사용하고 있다.

주요 기능은 다음과 같다.
* 서브볼륨
* 빠른 서브볼륨 스냅샷
* 서브볼륨 이미지 파일 작성
* RAID
* 실시간 데이터 압축
* 디스크 사용량 제한 (quota)

Btrfs를 사용할 때는 패키지 매니저를 통해 `btrfs-progs`를 꼭 설치해 줄 것!

[Btrfs]: https://btrfs.wiki.kernel.org/

## 용어 설명

### CoW
[CoW]는 복사 요청이 들어왔을 때, 실제 복사 시점을 최대한 미루어 복사 후 변경되지 않는 데이터에 대해
복사 성능을 끌어올리는 기법이다. Btrfs에서는 이 기능을 파일시스템 스냅샷 등에 활용하고 있다.

[CoW]: https://en.wikipedia.org/wiki/copy-on-write

### 서브볼륨 (Subvolumes)
Btrfs의 서브볼륨은 파일시스템 내에 존재하는 파일 공간이다. 각각의 서브볼륨은 파일시스템처럼 마운트가
가능하며 포맷 직후에 생긴 루트 파일시스템도 서브볼륨으로 취급된다. 하지만 서브볼륨이 별도의 블록
디바이스로 인식되는 것은 아니다 (대신 루트 파일시스템의 블록 디바이스를 통해 마운트할 수 있다).

예를 들어, 다음과 같이 생긴 Btrfs 파일시스템을 생각해 보자.
```
/dev/sda2 (btrfs, 루트 서브볼륨, ID 5)
|- root (서브볼륨, ID 802)
|  |- boot
|  |- etc
|  |- root
|  |  `- btrfs (빈 디렉토리)
|  |- usr (빈 디렉토리)
|  |- home (빈 디렉토리)
|  `- ...
|- usr (서브볼륨, ID 803)
|  `- ...
`- home (서브볼륨, ID 804)
   `- ...
```

이것을 다음과 같이 마운트할 수 있다.
```
/ (/dev/sda2, btrfs, readonly, 서브볼륨 root)
|- boot
|- etc
|- root
|  `- btrfs (/dev/sda2, btrfs, 서브볼륨 ID 5)
|     |- root (서브볼륨, ID 802)
|     |  |- boot
|     |  |- etc
|     |  |- root
|     |  |  `- btrfs (빈 디렉토리)
|     |  |- usr (빈 디렉토리)
|     |  |- home (빈 디렉토리)
|     |  `- ...
|     |- usr (서브볼륨, ID 803)
|     |  `- ...
|     `- home (서브볼륨, ID 804)
|        `- ...
|- usr (/dev/sda2, btrfs, readonly, 서브볼륨 usr)
|  `- ...
`- home (/dev/sda2, btrfs, 서브볼륨 home)
   `- ...
```

위의 트리에서 각 서브볼륨이 서로 다른 파일시스템인 것처럼 독립적으로 마운트된 것을 볼 수 있다.
`/home`과 `/root/btrfs/home`은 같은 서브볼륨이므로 동일한 데이터를 갖고 있으며 수정한 내용이 각각의
위치에 똑같이 반영된다.

### 스냅샷
서브볼륨의 어느 한 순간과 완전히 동일한 내용을 가진 서브볼륨을 만드는 기능이다. 스냅샷 생성 명령을
내리면 Btrfs의 CoW 기능을 활용한 타깃 서브볼륨의 경량 복사본(shallow copy)이 새 서브볼륨으로
생성된다. 스냅샷 기능의 특징은, 서브볼륨에 데이터가 얼마나 많건 상관없이 한순간에 끝난다는 점이다.
백업을 만들거나 동일한 내용의 디렉토리를 여러 개 만들 때 주로 사용된다.

## 파일시스템 포맷
`mkfs.btrfs`를 사용한다.

### RAID를 사용하지 않을 때 (단일 드라이브 구성)
```
mkfs.btrfs /dev/sda2
```

### RAID를 사용할 때 (다중 드라이브 구성)
`-m`, `-d` 옵션으로 메타데이터와 실제 데이터의 RAID 구성을 정할 수 있다. 바쿠스에서는 주로 
메타데이터에 RAID 1(모든 드라이브에 복사), 실제 데이터에 RAID 0(여러 드라이브에 번갈아 저장)을
사용하게 될 것이다.
```
mkfs.btrfs -m raid1 -d raid0 /dev/sdc1 /dev/sdd1
```

마운트할 때는 RAID를 구성하는 드라이브 중 하나를 골라 마운트하면 된다.
```
mount /dev/sdc1 /mnt
# or
mount /dev/sdd1 /mnt
```

## Btrfs 파일시스템 정보 보기
[`btrfs filesystem`][btrfs-filesystem.8] 서브커맨드를 사용한다.

[btrfs-filesystem.8]: https://man.archlinux.org/man/btrfs-filesystem.8

### 파일시스템 정보 확인
`btrfs filesystem show`를 사용한다. 루트 권한이 필요하다.

마운트된 디렉토리를 필요로 하는 대부분의 명령과는 달리 이 명령은 블록 디바이스를 인자로 사용할 수
있다.

```
# btrfs filesystem show /
Label: none  uuid: e5672964-66a9-4e8e-a542-782dcd76223c
        Total devices 1 FS bytes used 124.73GiB
        devid    1 size 255.50GiB used 164.02GiB path /dev/mapper/firis-btrfs

# btrfs filesystem show /dev/firis/btrfs
Label: none  uuid: e5672964-66a9-4e8e-a542-782dcd76223c
        Total devices 1 FS bytes used 124.73GiB
        devid    1 size 255.50GiB used 164.02GiB path /dev/mapper/firis-btrfs
```

### 전체 파일시스템 사용량 확인
`btrfs filesystem usage`를 사용한다. 루트 권한이 없어도 대략적인 정보는 볼 수 있다.

여기에 표시되는 내용은 `df`와 동일하지만 조금 더 자세하다.

```
$ btrfs filesystem usage /
WARNING: cannot read detailed chunk info, per-device usage will not be shown, run as root
Overall:
    Device size:                 255.50GiB
    Device allocated:            164.02GiB
    Device unallocated:           91.47GiB
    Device missing:              255.50GiB
    Used:                        127.22GiB
    Free (estimated):            123.24GiB      (min: 77.51GiB)
    Free (statfs, df):           123.24GiB
    Data ratio:                       1.00
    Metadata ratio:                   2.00
    Global reserve:              265.84MiB      (used: 0.00B)
    Multiple profiles:                  no

Data,single: Size:154.01GiB, Used:122.24GiB (79.37%)

Metadata,DUP: Size:5.00GiB, Used:2.49GiB (49.83%)

System,DUP: Size:8.00MiB, Used:48.00KiB (0.59%)

```

루트 권한을 사용하면 파일시스템을 이루는 각 디바이스가 차지하는 용량이 얼마인지도 확인할 수 있다.
```
# btrfs filesystem usage /
Overall:
    Device size:                 255.50GiB
    Device allocated:            164.02GiB
    Device unallocated:           91.47GiB
    Device missing:                  0.00B
    Used:                        127.22GiB
    Free (estimated):            123.24GiB      (min: 77.51GiB)
    Free (statfs, df):           123.24GiB
    Data ratio:                       1.00
    Metadata ratio:                   2.00
    Global reserve:              265.84MiB      (used: 0.00B)
    Multiple profiles:                  no

Data,single Size:154.01GiB, Used:122.24GiB (79.37%)
   /dev/mapper/firis-btrfs       154.01GiB

Metadata,DUP: Size:5.00GiB, Used:2.49GiB (49.81%)
   /dev/mapper/firis-btrfs        10.00GiB

System,DUP: Size:8.00MiB, Used:48.00KiB (0.59%)
   /dev/mapper/firis-btrfs        16.00MiB

Unallocated:
   /dev/mapper/firis-btrfs        91.47GiB:
```

### 디렉토리 사용량 확인
`btrfs filesystem du`를 사용한다. Btrfs의 내부 구조를 파악하여 용량을 계산하므로 `du`보다 더
정확하다.

보통 `-s` (`--summarize`) 옵션을 사용하고 싶을 것이다. 이 옵션을 주면 디렉토리의 전체 용량만을
표시한다.

```
$ btrfs filesystem du -s coding/
     Total   Exclusive  Set shared  Filename
  50.49GiB    45.01GiB     2.43GiB  coding/
$ du --summarize -h coding/
52G     coding/
```

*Set shared*는 해당 디렉토리(set) 내부에서 여러 파일이 공유하고 있는 데이터 영역(extent)의 크기를
뜻한다.

### 파일시스템 크기 조정
`btrfs filesystem resize`를 사용한다. Ext 시리즈의 `resize2fs`에 해당하는 명령이다. 보통 `fdisk`나
`parted` 같은 툴으로 파티션 크기를 조정한 뒤에 사용하게 될 것이다.

자세한 사용법은 [매뉴얼의 `EXAMPLES` 절][resize-examples]을 참고.

[resize-examples]: https://man.archlinux.org/man/btrfs-filesystem.8#EXAMPLES

## 서브볼륨과 스냅샷 관리
[`btrfs subvolume`][btrfs-subvolume.8] 서브커맨드를 사용한다.

[btrfs-subvolume.8]: https://man.archlinux.org/man/btrfs-subvolume.8

### 서브볼륨 목록 보기
`btrfs subvolume list`를 사용한다. 주어진 경로를 포함하는 Btrfs 파일시스템의 모든 서브볼륨 목록을
보여준다. 하위 서브볼륨이 마운트되어 있더라도 파일시스템의 서브볼륨이 전부 출력된다. 단, 루트
서브볼륨은 출력되지 않는다.

```
# btrfs subvolume list /
ID 257 gen 119461 top level 5 path root
ID 259 gen 119405 top level 5 path home
ID 262 gen 20 top level 257 path var/lib/portables
ID 263 gen 119057 top level 257 path var/lib/machines
```

### 새 서브볼륨 만들기
`btrfs subvolume create`를 사용한다. 주어진 위치에 새 서브볼륨을 만든다. 물론 해당 위치는 Btrfs
파일시스템 트리 안에 있어야 한다.

```
# btrfs subvolume create /mnt/btrfs/foo
Create subvolume '/mnt/btrfs/foo'
```

### 서브볼륨 삭제
`btrfs subvolume delete`를 사용한다. 주어진 서브볼륨이 즉시 삭제된다. 하지만 데이터는 바로 삭제되지
않고 백그라운드에서 삭제 작업이 진행된다.

```
# btrfs subvolume delete /mnt/btrfs/foo
Delete subvolume (no-commit): '/mnt/btrfs/foo'
```

### 스냅샷 생성
`btrfs subvolume snapshot`을 사용한다. `-r` 옵션을 주면 만들어진 스냅샷이 읽기 전용이 된다.

## 서브볼륨 이미지 송수신
서브볼륨의 데이터를 모아서 이미지 파일로 만들거나, 이미지 파일에서 서브볼륨을 만들 수 있다.

### 이미지 송신
[`btrfs send`][btrfs-send.8]를 사용한다. 주어진 서브볼륨으로 이미지를 만들어 표준 출력으로 보낸다.
`-f <file>` 옵션을 사용하면 표준 출력 대신 파일으로 출력할 수 있다.

`-p <parent-subvolume>` 옵션을 사용하면 해당 서브볼륨에서 변한 내용만 이미지로 만들 수 있다. 단, 이
옵션으로 만들어진 이미지를 수신할 때는 해당 파일시스템에 이미지 생성 시 지정한 서브볼륨이 이미
존재해야 한다.

[btrfs-send.8]: https://man.archlinux.org/man/btrfs-send.8

### 이미지 수신
[`btrfs receive`][btrfs-receive.8]를 사용한다. 표준 입력으로 주어진 이미지를 사용해 주어진 경로에 새
서브볼륨을 만든다.  `-f <file>` 옵션을 사용해 표준 입력 대신 이미지 파일을 사용할 수 있다.

[btrfs-receive.8]: https://man.archlinux.org/man/btrfs-receive.8
