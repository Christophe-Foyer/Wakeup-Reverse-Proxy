#!/bin/bash

ret="$(/usr/sbin/qm list | /usr/bin/grep running)"
upSeconds="$(/usr/bin/cat /proc/uptime | /usr/bin/grep -o '^[0-9]\+')"
upMins=$((${upSeconds} / 60))
min_minutes=10  # Minimum uptime

if [ -z "$ret" ] && [ "${upMins}" -gt "${min_minutes}" ]
then
    if [ ! -f "/run/systemd/shutdown/scheduled" ]
    then
      echo "Shutting down"
      /usr/sbin/shutdown -h +5 "No VMs active, shutting down in 5 minutes | ${ret}"
    else
      echo "Shutdown is already scheduled"
    fi
else
    if [ "${upMins}" -gt "${min_minutes}" ]
    then
      msg="VM is online, canceling shutdown"
    else
      msg="Uptime < ${min_minutes}, canceling shutdown"
    fi
    echo "${msg}"
    /usr/sbin/shutdown -c "${msg}"
fi
