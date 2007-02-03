#!/bin/sh
printf "Are you sure you want to uninstall Webmin? (y/n) : "
read answer
printf "\\n"
if [ "\\\$answer" = "y" ]; then
        echo "Removing webmin package .."
    /etc/init.d/webmin stop >/dev/null 2>&1
    emerge unmerge webmin
    echo "Done!"
fi
