#!/bin/sh

echo "update recorded set hostname='jmd1' where basename LIKE '2010_%210000.%' AND hostname = 'jmd0'" | mysql -h jmd0 -u mythtv mythconverg

