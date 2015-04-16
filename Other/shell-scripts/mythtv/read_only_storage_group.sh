BE=jmd0
SG_DIR=/mnt/mythtv/zfs_4t0/recordings
VALUE=99
wget --post-data="HostName=${BE}&Key=SGweightPerDir:${BE}:${SG_DIR}&Value=${VALUE}" \
     http://${BE}:6544/Myth/PutSetting
