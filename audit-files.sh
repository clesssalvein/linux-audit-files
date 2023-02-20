#!/bin/bash

#####
#
# linux-audit-files by @ClessAlvein
# Running actions when modifying files
#
#####


# VARS

# monitoring directory path
auditDirPath="/opt/test123"

# auditd log marker
auditMarker="${auditDirPath}"

# auditd standard log file
auditLogFilePath="/var/log/audit/audit.log"


# START SCRIPT

# flush auditd rules
auditctl -W ${auditDirPath} -p w -k ${auditMarker}

# add auditd rules
#auditctl ${auditDirRecursiveCheckKey} ${auditDirPath} -p w -k ${auditMarker}
auditctl -w ${auditDirPath} -p w -k ${auditMarker}

# write audit rule to file (unnecessary)
###auditctl -l > /etc/audit/rules.d/${auditMarker}.rules


# infinite loop start
while true;
do
  # inotify wait for file modification
  inotifywait -rq ${auditDirPath} -e modify |
    while read dirPathFileModed fileAction fileModed;
    do
      # get modded file full path
      fileModedFullPath="${dirPathFileModed}${fileModed}";

      # screening slashes in the moded file path for awk
      fileModedFullPathScreenedSlashes=`echo ${fileModedFullPath} | sed -e 's:\/:\!:g'`

      # search for the latest record in auditd log with our custom marker,
      # get user id, which moded the file
      userId=$(ausearch -k ${auditMarker} -if ${auditLogFilePath} \
        | awk -v RS='----' -v i=$fileModedFullPathScreenedSlashes '/i/ {print}' \
        | awk -v RS='' 'END {print}' \
        | grep "SYSCALL" \
        | awk '{print $15}' \
        | awk -F"=" '{print $2}');

      # get dateTime when file has been modified
      dateTime=$(date --date="$(ausearch -k ${auditMarker} -if ${auditLogFilePath} \
        | awk -v RS='----' -v i=$fileModedFullPathScreenedSlashes '/i/ {print}' \
        | awk -v RS='' 'END {print}' \
        | awk -F"->" '/time->/ {print $2}')" \
        +%Y-%m-%d_%H-%M-%S);

      # get username, which moded the file
      userName=`id -nu ${userId}`;

      # debug
      echo "---";
      echo "DateTime: ${dateTime}";
      echo "dirPathFileModed: ${dirPathFileModed}";
      echo "fileModed: ${fileModed}";
      echo "fileModedFullPath ${fileModedFullPath}";
      echo "userName: ${userName}";
      echo "userId: ${userId}";
      echo "File action: ${fileAction}";
      echo "---";

      # Here you can add arbitrary actions with gotten vars
      
      # For example, you can write log

      echo "DateTime: ${dateTime}, File: ${fileModedFullPath}, File action: ${fileAction}, Username: ${userName}" >> /opt/audit-files/audit-files.log
      
      # For example, you can send text using telegram bot

      # send text using telegram bot
      #curl --request POST https://api.telegram.org/bot4***1:A***Y/sendMessage?chat_id=2***3 \
      #    --data "text=DateTime: ${dateTime}, File: ${fileModedFullPath}, File action: ${fileAction}, Username: ${userName}";

    done
# infinite loop stop
done
