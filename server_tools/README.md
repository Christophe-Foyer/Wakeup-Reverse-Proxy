# Server tools

Tool to help manage the remote hosts you plan on waking up

## Included scripts

### jnettop_monitor.sh

Relies on jnettop (`sudo apt install jnettop` on ubuntu).
May need to be run as root (or give non-sudo access to jnettop)

A recuring task, easily integrated into cron to check for network activity on specified ports and shut down the server if no activity is detected.

This is probably not perfect, and extra logic could be added to handle simple pings, but is fairly generlizable to a variety of tasks you may be running on the host.

Logic will have to be added to check for desktop activity to avoid hibernation/shutdown if say a user is active on the desktop, this would also give other processes a sensible behavior to nudge to avoid suspending operation.

The network monitoring logic should cover most cases however where you are exposing services to remote users, such as webpages, vpns, game servers, whatever you may be running that people would presumably interact with.

### proxmox_autoshutdown.sh

Checks for running VMs in proxmox. If all are off (and uptime is more than a set threshold), shuts down the host.

## Additional apps

Support for additional applications/task monitoring would have to be done on a per-application basis
