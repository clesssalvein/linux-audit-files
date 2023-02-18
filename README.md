# Description

This service is intended to run some actions when any file(s) in the certain directory are modified.

# Requirements

- Tested on AlmaLinux 8

# Installation

- Create dir for service script

```
mkdir /opt/audit-files
```

- Create service script and put "audit-files.sh" file content in it.

```
nano /opt/audit-files/audit-files.sh
```

- Edit variables in script "audit-files.sh"
- Add execute permission to script

```
chmod +x /opt/audit-files/audit-files.sh
```

- Create systemd service file and put "audit-files.service" file content in it.

```
nano /etc/systemd/system/audit-files.service
```

- Reload systemd daemon, add service to autostart and run it

```
systemctl daemon-reload
```
```
systemctl enable --now audit-files.service
```

# How it works

- Create or modify some file in the monitoring directory as any user

```
u1@chef ~ $ echo 2 > /opt/test123/1
```

- You will see some debug in the service output

```systemctl status audit-files.service```
```
...
Feb 18 15:58:34 chef systemd[1]: Started script.
Feb 18 15:58:51 chef audit-files.sh[1825]: ---
Feb 18 15:58:51 chef audit-files.sh[1825]: dirPathFileModed: /opt/test123/
Feb 18 15:58:51 chef audit-files.sh[1825]: fileModed: 1
Feb 18 15:58:51 chef audit-files.sh[1825]: fileModedFullPath /opt/test123/1
Feb 18 15:58:51 chef audit-files.sh[1825]: userName: u1
Feb 18 15:58:51 chef audit-files.sh[1825]: userId: 1000
Feb 18 15:58:51 chef audit-files.sh[1825]: File action: MODIFY
Feb 18 15:58:51 chef audit-files.sh[1825]: ---
...
```

- Feel free to add any actions with gotten vars to script "audit-files.sh"
- Restart service after adding actions

```
systemctl restart audit-files.service
```
