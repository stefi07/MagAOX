#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../_common.sh
set -euo pipefail

function link_if_necessary() {
  thedir=$1
  thelinkname=$2
  if [[ "$thedir" != "$thelinkname" ]]; then
    if [[ -L $thelinkname ]]; then
      if [[ "$(readlink -- "$thelinkname")" != $thedir ]]; then
        echo "$thelinkname is an existing link, but doesn't point to $thedir. Aborting."
        exit 1
      fi
    elif [[ -e $thelinkname ]]; then
      echo "$thelinkname exists, but is not a symlink and we want the destination to be $thedir. Aborting."
      exit 1
    else
        ln -sv "$thedir" "$thelinkname"
    fi
  fi
}

function setgid_all() {
    # n.b. can't be recursive because g+s on files means something else
    # so we find all directories and individually chmod them:
    find $1 -type d -exec chmod g+s {} \;
}

mkdir -pv /opt/MagAOX
chown root:root /opt/MagAOX

mkdir -pv /opt/MagAOX/bin
# n.b. not using -R on *either* chown *or* chmod so we don't clobber setuid binaries
chown root:root /opt/MagAOX/bin
chmod u+rwX,g+rX,o+rX /opt/MagAOX/bin

if [[ "$MAGAOX_ROLE" == "vm" ]]; then
  mkdir -pv /vagrant/setup/calib
  link_if_necessary /vagrant/setup/calib /opt/MagAOX/calib
else
  mkdir -pv /opt/MagAOX/calib
  chown -R root:magaox-dev /opt/MagAOX/calib
  chmod -R u=rwX,g=rwX,o=rX /opt/MagAOX/calib
  setgid_all /opt/MagAOX/calib
fi

if [[ "$MAGAOX_ROLE" == "vm" ]]; then
  mkdir -pv /vagrant/setup/config
  link_if_necessary /vagrant/setup/config /opt/MagAOX/config
else
  mkdir -pv /opt/MagAOX/config
  chown -R root:magaox-dev /opt/MagAOX/config
  chmod -R u=rwX,g=rwX,o=rX /opt/MagAOX/config
  setgid_all /opt/MagAOX/config
fi

mkdir -pv /opt/MagAOX/drivers/fifos
chown -R root:root /opt/MagAOX/drivers
chmod -R u=rwX,g=rwX,o=rX /opt/MagAOX/drivers
chown -R root:magaox /opt/MagAOX/drivers/fifos

if [[ $MAGAOX_ROLE == RTC || $MAGAOX_ROLE == ICC || $MAGAOX_ROLE == AOC ]]; then
  REAL_LOGS_DIR=/data/logs
  mkdir -pv $REAL_LOGS_DIR
  link_if_necessary $REAL_LOGS_DIR /opt/MagAOX/logs
else
  REAL_LOGS_DIR=/opt/MagAOX/logs
  mkdir -pv $REAL_LOGS_DIR
fi
chown -RP xsup:magaox $REAL_LOGS_DIR
chmod -R u=rwX,g=rwX,o=rX $REAL_LOGS_DIR
setgid_all $REAL_LOGS_DIR

if [[ $MAGAOX_ROLE == RTC || $MAGAOX_ROLE == ICC || $MAGAOX_ROLE == AOC ]]; then
  REAL_RAWIMAGES_DIR=/data/rawimages
  mkdir -pv $REAL_RAWIMAGES_DIR
  link_if_necessary $REAL_RAWIMAGES_DIR /opt/MagAOX/rawimages
else
  REAL_RAWIMAGES_DIR=/opt/MagAOX/rawimages
  mkdir -pv $REAL_RAWIMAGES_DIR
fi
chown -RP xsup:magaox $REAL_RAWIMAGES_DIR
chmod -R u=rwX,g=rwX,o=rX $REAL_RAWIMAGES_DIR
setgid_all $REAL_RAWIMAGES_DIR

mkdir -pv /opt/MagAOX/secrets
chown -R root:root /opt/MagAOX/secrets
chmod -R u=rwX,g=,o= /opt/MagAOX/secrets

mkdir -pv /opt/MagAOX/source
chown -R root:magaox-dev /opt/MagAOX/source
# n.b. using + instead of = so we don't clobber setuid binaries
chmod -R u+rwX,g+rwX,o+rX /opt/MagAOX/source
setgid_all /opt/MagAOX/source

mkdir -pv /opt/MagAOX/sys
chown -R root:root /opt/MagAOX/sys
chmod -R u=rwX,g=rX,o=rX /opt/MagAOX/sys

mkdir -pv /opt/MagAOX/vendor
chown root:magaox-dev /opt/MagAOX/vendor
chmod u=rwX,g=rwX,o=rX /opt/MagAOX/vendor
setgid_all /opt/MagAOX/vendor

if [[ "$MAGAOX_ROLE" == "vm" ]]; then
  mkdir -pv /vagrant/setup/cache
  link_if_necessary /vagrant/setup/cache /opt/MagAOX/.cache
else
  mkdir -pv /opt/MagAOX/.cache
  chown -R root:root /opt/MagAOX/.cache
  chmod -R u=rwX,g=rwX,o=rX /opt/MagAOX/.cache
fi
