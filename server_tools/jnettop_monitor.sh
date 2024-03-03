#!/bin/bash

# Edit the variables below
suspend_command="/usr/bin/systemctl hibernate"
scantime=300 # How long of a period should each scan scan
ports='22 80 443' # Ports to monitor
min_uptime_minutes=10  # Minimum uptime in minutes
min_idle_time_minutes=10  # minimum idle time

# Uptime
upSeconds="$(/usr/bin/cat /proc/uptime | /usr/bin/grep -o '^[0-9]\+')"
upMins=$((${upSeconds} / 60))

# Aggregate the rules to look for
scanrules=$(/usr/bin/echo $(for port in $ports; do echo -n "dstport:$port|"; done)  | /usr/bin/rev | /usr/bin/cut -c 2- | /usr/bin/rev)
echo "Grep matching rules: $scanrules"

# Scan network activity
ret=$(/usr/sbin/jnettop --display text -t $scantime --format 'proto:$proto$,src:$srcname$,dstport:$dstport$,bps:$totalbps$' | /usr/bin/grep -E "$scanrules")

# Check x session idle time
get_idle_time=`/usr/bin/dbus-send --print-reply --dest=org.gnome.Mutter.IdleMonitor /org/gnome/Mutter/IdleMonitor/Core org.gnome.Mutter.IdleMonitor.GetIdletime`
idle_time=$(/usr/bin/echo $get_idle_time | /usr/bin/awk '{print $NF}')  # milliseconds

# Run suspend_command
if [ -z "$ret" ] && [ "${upMins}" -gt "${min_minutes}" ] && [ "$idle_time" -gt $(( min_idle_time_minutes*60*1000 )) ]
then
    eval "$suspend_command"
fi
