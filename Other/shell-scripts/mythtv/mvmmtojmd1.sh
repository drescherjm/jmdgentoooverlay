#!/bin/sh

echo "update recorded set hostname='jmd1' where basename LIKE '2045_%' AND hostname = 'jmd0'" | mysql -h jmd0 -u mythtv mythconverg

