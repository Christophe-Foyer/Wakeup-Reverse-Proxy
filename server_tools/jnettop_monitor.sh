#!/bin/bash

# Edit the variables below
suspend_command="shutdown"
cancel_command="shutdown -c 'Monitored application is using bandwidth'"
scantime=60 # How long of a period should each scan scan
ports='80 443' # Ports to monitor
min_uptime_minutes=10  # Minimum uptime in minutes

# Uptime
upSeconds="$(/usr/bin/cat /proc/uptime | /usr/bin/grep -o '^[0-9]\+')"
upMins=$((${upSeconds} / 60))

# Aggregate the rules to look for
scanrules=$(echo $(for port in $ports; do echo -n "dstport:$port|"; done)  | rev | cut -c 2- | rev)
echo "Grep matching rules: $scanrules"

# Scan network activity
ret=$(/usr/sbin/jnettop --display text -t $scantime --format 'proto:$proto$,src:$srcname$,dstport:$dstport$,bps:$totalbps$' | grep -E "$scanrules")

# Suspend_command
echo ret
