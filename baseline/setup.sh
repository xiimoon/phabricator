#!/bin/bash

set -e
set -x

# Add repositories
# zypper --non-interactive ar http://download.opensuse.org/repositories/devel:/languages:/php/openSUSE_Leap_15.0/ php
zypper --non-interactive ar https://download.opensuse.org/update/leap/42.3/oss/ update
zypper --non-interactive ar https://download.opensuse.org/update/leap/15.1/oss/ updata1
zypper --non-interactive ar https://download.opensuse.org/repositories/devel:/libraries:/c_c++/openSUSE_Leap_15.0/ exprc
zypper --non-interactive ar http://download.opensuse.org/repositories/devel:/languages:/python/openSUSE_Leap_15.0/ python

# Install Git before we add the SCM repository (the SCM repository contains Git 2.11, which is broken).
zypper --gpg-auto-import-keys --non-interactive in --force-resolution git

# Lock the git package to the current version
# zypper --non-interactive al git

# Add SCM package for other tools (Subversion, Mercurial)...
# zypper --non-interactive ar http://download.opensuse.org/repositories/devel:/tools:/scm/openSUSE_Leap_42.3/ scm

# Install requirements
zypper --gpg-auto-import-keys --non-interactive in --force-resolution nginx php5-fpm php5-mbstring php5-mysql php5-curl php5-pcntl php5-gd php5-openssl php5-ldap php5-fileinfo php5-posix php5-json php5-iconv php5-ctype php5-zip php5-sockets which nodejs8 ca-certificates ca-certificates-mozilla ca-certificates-cacert sudo subversion mercurial php5-xmlwriter php5-opcache ImageMagick postfix glibc-locale

# Build and install APCu
zypper --non-interactive install --force-resolution autoconf automake binutils cpp gcc glibc-devel libasan0 libatomic1 libgomp1 libitm1 libltdl7 libmpc3 libpcre16-0 libpcrecpp0 libpcreposix0 libstdc++-devel libstdc++48-devel libtool libtsan0 libxml2-devel libxml2-tools linux-glibc-devel m4 make ncurses-devel pcre-devel php5-devel php5-pear php5-zlib pkg-config readline-devel tack xz-devel zlib-devel
printf "\n" | pecl install apcu-4.0.10

# Remove cached things that pecl left in /tmp/
rm -rf /tmp/*

# Install a few extra things
zypper --non-interactive install --force-resolution mariadb-client vim vim-data

# Force reinstall cronie
zypper --non-interactive install -f cronie

# add by adam@xiimoon
# some stuff
zypper --gpg-auto-import-keys --non-interactive in python-pip
pip install --upgrade pip
pip install pygments
pip install supervisor

# Create users and groups
echo "nginx:x:497:495:user for nginx:/var/lib/nginx:/bin/false" >> /etc/passwd
echo "nginx:!:495:" >> /etc/group
echo "PHABRICATOR:x:2000:2000:user for phabricator:/srv/phabricator:/bin/bash" >> /etc/passwd
echo "wwwgrp-phabricator:!:2000:nginx" >> /etc/group

# Set up the Phabricator code base
mkdir /srv/phabricator
chown PHABRICATOR:wwwgrp-phabricator /srv/phabricator
cd /srv/phabricator
sudo -u PHABRICATOR git clone https://github.com/phacility/libphutil.git /srv/phabricator/libphutil
sudo -u PHABRICATOR git clone https://github.com/phacility/arcanist.git /srv/phabricator/arcanist
sudo -u PHABRICATOR git clone https://github.com/phacility/phabricator.git /srv/phabricator/phabricator
sudo -u PHABRICATOR git clone https://github.com/PHPOffice/PHPExcel.git /srv/phabricator/PHPExcel
sudo -u PHABRICATOR git clone https://github.com/wikimedia/phabricator-extensions-Sprint.git /srv/phabricator/libext/sprint
cd /

# Clone Let's Encrypt
git clone https://github.com/letsencrypt/letsencrypt /srv/letsencrypt
cd /srv/letsencrypt
./letsencrypt-auto-source/letsencrypt-auto --help
cd /
