# Description

This service is intended to run some actions when any file(s) in the certain directory are modified. It uses *auditd* service and *inotify-tools*.

# Requirements

- Tested on AlmaLinux 8

# Installation

- Install required components

```
dnf install inotify-tools libnotify
```

- Create dir for the service script

```
mkdir /opt/audit-files
```

- Create the service script and put the content of the file "audit-files.sh" into it.

```
nano /opt/audit-files/audit-files.sh
```

- Edit the variables in the script "audit-files.sh"
- Add execution permission to script

```
chmod +x /opt/audit-files/audit-files.sh
```

- Create the systemd service file and put the content of the file "audit-files.service" into it.

```
nano /etc/systemd/system/audit-files.service
```

- Reload systemd daemon, add the service to autostart and run it

```
systemctl daemon-reload
```
```
systemctl enable --now audit-files.service
```

# How it works

- Create or modify some file in the monitored directory as any user

```
u1@chef ~ $ echo 2 > /opt/test123/1
```

- You will see some debug in the service output

```
systemctl status audit-files.service
```
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

- Feel free to add any actions with gotten vars to the script "audit-files.sh"

  *For example, you can send a message using telegram bot
  
  ```
  curl --request POST https://api.telegram.org/bot4***1:A***Y/sendMessage?chat_id=2***3 \
    --data "text=File: ${fileModedFullPath}, File action: ${fileAction}, Username: ${userName}";
  ```
  
- Restart the service after adding actions

```
systemctl restart audit-files.service
```
