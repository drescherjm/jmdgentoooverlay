#/bin/sh

mount /mnt/boxdrive
rsync  --progress -uax /home/svn-backups/ /mnt/boxdrive/svn-backups/
