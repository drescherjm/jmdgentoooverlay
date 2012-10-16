#!/bin/sh

sed -i '/check_glsa/d'  /etc/nagios/nrpe.cfg

echo "command[check_glsa]=/usr/lib64/nagios/plugins/check_glsa2.sh" >> /etc/nagios/nrpe.cfg

/etc/init.d/nrpe restart
