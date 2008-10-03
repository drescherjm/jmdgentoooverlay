#! /bin/sh

echo ""
echo "                              ==========================="
echo "                              # Daily Insecurity Report #"
echo "                              ==========================="
echo ""
echo "Daily Security Run Beginning... `date`"
echo ""
echo ""
echo "1. Logins:"
echo "=========="
echo ""
echo "Users Currently Logged In:"
echo "--------------------------"
/usr/bin/users
echo ""
echo "Logins in the Past Day:"
echo "-----------------------"
/usr/bin/lastlog -t 2
echo ""
echo "Failed Logins in the Past Day:"
echo "------------------------------"
/usr/bin/faillog -t 2
echo ""
echo "Cumulative Login Failures:"
echo "--------------------------"
/usr/bin/faillog -a
echo ""
echo ""
echo "2. Open Network Connections:"
echo "============================"
/bin/netstat --inet -ap
echo ""
echo ""
echo "3. Patch Status:"
echo "================"
echo "Synchronizing Package Database... "
/usr/bin/emerge --sync --quiet && echo "Completed."
echo ""
echo "Package Updates Available:"
echo "--------------------------"
/usr/bin/emerge -puD world
echo ""
echo ""
echo "Applicable Security Advisories:"
echo "-------------------------------"
/usr/bin/glsa-check -tvn all
echo ""
echo ""
echo "4. Storage Utilization:"
echo "======================="
/bin/df -hT
echo ""
echo ""
echo "5. SUID/SGID Changes:"
echo "====================="
/usr/sbin/sxid -n
echo ""
echo ""
echo "Daily Security Run Ending... `date`"
echo ""
echo "                            =================================="
echo "                            # End of Daily Insecurity Report #"
echo "                            =================================="
echo ""
logger -p cron.notice "$0 job complete."
