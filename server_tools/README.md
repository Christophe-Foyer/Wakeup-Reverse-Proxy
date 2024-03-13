# Server tools

Tool to help manage the remote hosts you plan on waking up

*Note: Some of these are a bit hackish, don't give random scripts sudo access without knowing what you're giving access to, feel free to ask questions if you have safety concerns.

## Included scripts

### jnettop_monitor.sh

A recuring task, easily integrated into cron to check for network activity on specified ports and shut down the server if no activity is detected.

This is probably not perfect, and extra logic could be added to handle simple pings, but is fairly generlizable to a variety of tasks you may be running on the host.

Logic will have to be added to check for desktop activity to avoid hibernation/shutdown if say a user is active on the desktop, this would also give other processes a sensible behavior to nudge to avoid suspending operation.

The network monitoring logic should cover most cases however where you are exposing services to remote users, such as webpages, vpns, game servers, whatever you may be running that people would presumably interact with.

#### Setup:

Relies on jnettop (`sudo apt install jnettop` on ubuntu).
Must be run as the local user, and the `jnettop_sudoers` file must be added to `/etc/sudoers.d/jnettop_sudoers`. 
This is a bit hackish but if you check what's in that file it should be pretty safe if you trust jnettop.

You'll also need local ssh set up using keys to run the idle check command:
```
1. ssh-keygen -t rsa
Press enter for each line 
2. cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
3. chmod og-wx ~/.ssh/authorized_keys 
```

make sure you change the variables in the script to suit your needs (namely, the USER variable)

Add this to crontab (`crontab -e`) to make this a recuring task (every 5 minutes here)
```
*/5 * * * * /bin/bash /path/to/scripts/jnettop_monitor.sh
```

### proxmox_autoshutdown.sh

Checks for running VMs in proxmox. If all are off (and uptime is more than a set threshold), shuts down the host.

#### Setup:

Add this to crontab (`crontab -e`) to make this a recuring task (every minute here)
```
* * * * * /bin/bash /path/to/scripts/proxmox_autoshutdown.sh
```

## Additional apps

Support for additional applications/task monitoring would have to be done on a per-application basis
