#!/bin/bash

echo "Set system clock to GMT"
cat  /usr/share/zoneinfo/UTC > /etc/localtime

grep '# Force system to use GMT time at boot' /etc/rc.d/rc.local &> /dev/null
if [ $? -ne 0 ]; then
    echo "Setting GMT reset in rc.local"
    echo "" >> /etc/rc.d/rc.local
    echo "# Force system to use GMT time at boot" >> /etc/rc.d/rc.local
    echo "cat  /usr/share/zoneinfo/UTC > /etc/localtime" >> /etc/rc.d/rc.local
fi

cat > /etc/sysconfig/clock <<EOF
# The time zone of the system is defined by the contents of /etc/localtime.
# This file is only for evaluation by system-config-date, do not rely on its
# contents elsewhere.
ZONE="UTC"
UTC=true
ARC=false
EOF

service crond restart

echo "End of system clock reset to GMT"


