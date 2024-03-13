#!/bin/bash

# Edit the variables below
suspend_command="sudo /usr/bin/systemctl shutdown" # need to find a better way to handle hibernate
scantime=300 # How long of a period should each scan scan
ports='22 80 443' # Ports to monitor
min_uptime_minutes=10  # Minimum uptime in minutes
min_idle_time_minutes=10  # minimum idle time
user="${USER:-root}"

# Uptime
upSeconds="$(/usr/bin/cat /proc/uptime | /usr/bin/grep -o '^[0-9]\+')"
upMins=$((${upSeconds} / 60))

# Aggregate the rules to look for
scanrules=$(/usr/bin/echo $(for port in $ports; do echo -n "srcport:$port|"; done)  | /usr/bin/rev | /usr/bin/cut -c 2- | /usr/bin/rev)
echo "Grep matching rules: $scanrules"

# Scan network activity
ret=$(sudo /usr/sbin/jnettop --display text -t $scantime --format 'proto:$proto$,src:$srcname$,srcport:$srcport$,dst:$dstname$,dstport:$dstport$,bps:$totalbps$' | /usr/bin/grep -E "$scanrules")
echo "$ret"

# Idle time is a mess to grab, but with the hackish ssh workaround it works
# Check x session idle time
get_idle_time=`ssh -Y ${user}@:: /usr/bin/dbus-send --print-reply --dest=org.gnome.Mutter.IdleMonitor /org/gnome/Mutter/IdleMonitor/Core org.gnome.Mutter.IdleMonitor.GetIdletime`
idle_time=$(/usr/bin/echo $get_idle_time | /usr/bin/awk '{print $NF}')  # milliseconds
idle_time=$(( idle_time ))
min_idle_time=$(( min_idle_time_minutes*60*1000 ))
echo "idle_time: $idle_time (min: $min_idle_time)"

# Run suspend_command
if [[ -z "$ret" ]] && [[ "${upMins}" -gt "${min_uptime_minutes}" ]] # && [[ "${idle_time}" -gt "${min_idle_time}" ]]
then
    eval "$suspend_command"
else
    echo "Idle time (ms): $idle_time"
    echo "Detected network sessions:"
    echo "$ret"
fi

