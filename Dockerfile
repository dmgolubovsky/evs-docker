# Build espeak-ng and Haskell programs necessary to use the Espeak Vocal Studio

from ubuntu:19.10

run cp /etc/apt/sources.list /etc/apt/sources.list~
run sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
run apt -y update
run apt install -y --no-install-recommends software-properties-common apt-utils
run add-apt-repository ppa:apt-fast/stable
run apt -y update
run env DEBIAN_FRONTEND=noninteractive apt-get -y install apt-fast
run echo debconf apt-fast/maxdownloads string 16 | debconf-set-selections
run echo debconf apt-fast/dlflag boolean true | debconf-set-selections
run echo debconf apt-fast/aptmanager string apt-get | debconf-set-selections

run apt-fast -y update && apt-fast -y upgrade

run mkdir -p /src

# Build espeak-ng

run apt-fast install -y autoconf automake libtool make

workdir /src
add espeak-ng espeak-ng
workdir espeak-ng
run ./autogen.sh
run ./configure --prefix=/espvs
run make
run make install

