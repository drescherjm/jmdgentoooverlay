 find /var/db/pkg/media-* -type d | sed s#/var/db/pkg/## | xargs -n20  emerge -C
