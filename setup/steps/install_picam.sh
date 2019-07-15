#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../_common.sh
set -euo pipefail

PICAM_RUNFILE_CHECKSUM=df337d5ff5bea402669b2283eb534d08
PICAM_RUNFILE=Picam_SDK.run
PICAM_URL=ftp://ftp.piacton.com/Public/Software/Official/PICam/$PICAM_RUNFILE
if [[ ! -e $PICAM_RUNFILE ]]; then
    curl -O $PICAM_URL
fi
if [[ $(md5sum ./$PICAM_RUNFILE) != *$PICAM_RUNFILE_CHECKSUM* ]]; then
    log_error "$PICAM_RUNFILE has md5 checksum $(md5sum ./$PICAM_RUNFILE)"
    log_error "Expected $PICAM_RUNFILE_CHECKSUM"
    log_error "(Either revise ${BASH_SOURCE[0]} or get the old runfile somewhere)"
    exit 1
fi
chmod +x ./$PICAM_RUNFILE
if [[ ! -e /opt/PrincetonInstruments/picam ]]; then
    yes yes | ./$PICAM_RUNFILE
fi
chmod a+rX -R /opt/pleora
chmod a+rX -R /opt/PrincetonInstruments
chmod g+xr,o+xr /usr/local/lib/libftd2xx.so.1.4.6
echo "if [[ \"\$EUID\" != 0 ]]; then source /opt/pleora/ebus_sdk/x86_64/bin/set_puregev_env; fi" > /etc/profile.d/picam_pleora_env.sh
