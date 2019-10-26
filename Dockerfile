# Build espeak-ng and Haskell programs necessary to use the Espeak Vocal Studio

from ubuntu:18.04 as base-ubuntu

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

from base-ubuntu as espeak

run apt-fast install -y autoconf automake libtool make libsonic-dev

workdir /src
add espeak-ng espeak-ng
workdir espeak-ng
run ./autogen.sh
run ./configure --prefix=/espvs
run make
run make install

# Install Haskell Stack

from base-ubuntu as stack

run apt-fast install -y wget
run wget -qO- https://get.haskellstack.org/ | sed 's/apt-get/apt-fast/g' | sh
run stack upgrade

# Build hsespeak

from stack as hsespeak

workdir /src
add hsespeak hsespeak
workdir hsespeak
run stack build
run stack install
run mkdir -p /espvs/bin
run cp /root/.local/bin/lyrvoc /espvs/bin
run mkdir -p /espvs/examples
run cp /src/hsespeak/*.musicxml /espvs/examples
add voices /espvs/voices

# Final assembly. Pull all parts together.

from base-ubuntu as evs

# No recommended and/or suggested packages here

run echo "APT::Get::Install-Recommends \"false\";" >> /etc/apt/apt.conf
run echo "APT::Get::Install-Suggests \"false\";" >> /etc/apt/apt.conf
run echo "APT::Install-Recommends \"false\";" >> /etc/apt/apt.conf
run echo "APT::Install-Suggests \"false\";" >> /etc/apt/apt.conf

run apt-fast install -y sox libsonic0 strace

copy --from=espeak /espvs /espvs
copy --from=hsespeak /espvs /espvs

# Flatten the image

from scratch

copy --from=evs / /

