#!/bin/bash

#####
#
# linux-audit-files by @ClessAlvein
# Running actions when modifying files
#
#####


# VARS

# monitoring directory path (!!! the path must not contain spaces in the directory names !!!)
auditDirPath="/opt/test123"

# auditd log marker
auditMarker="${auditDirPath}"

# auditd standard log file
auditLogFilePath="/var/log/audit/audit.log"


# START SCRIPT

# flush auditd rules
auditctl -W "${auditDirPath}" -p w -k "${auditMarker}"

# add auditd rules
#auditctl ${auditDirRecursiveCheckKey} ${auditDirPath} -p w -k ${auditMarker}
auditctl -w "${auditDirPath}" -p w -k "${auditMarker}"

# write audit rule to file (unnecessary)
###auditctl -l > /etc/audit/rules.d/${auditMarker}.rules


# infinite loop start
while true;
do
  # separator ";" between dirPath, file, action
  IFS=';'
  # inotify wait for any file modification
  # output format: dirPath;file;action ( e.g.: /dirpath/;file.txt;MODIFY )
  inotifywait -rq "${auditDirPath}" --format '%w;%f;%:e' -e modify |
    while read "dirPathFileModed" "fileModed" "fileAction";
    do
      # debug
      echo "///";
      echo "dirPathFileModed: ${dirPathFileModed}";
      echo "fileAction: ${fileAction}";
      echo "fileModed: ${fileModed}";
      echo "///";

      # get modded file full path
      fileModedFullPath="${dirPathFileModed}${fileModed}";

      # get inode of the moded file
      fileModedInode=$(ls -i "${fileModedFullPath}" | awk '{print $1}')

      # debug
      echo "///";
      echo "fileModedFullPath: ${fileModedFullPath}";
      echo "fileModedInode: ${fileModedInode}";
      echo "///";

      # searching for auditd log block with the latest record
      # with our custom auditd marker AND inode of the fileModed,
      # get user id ( uid=X ), which moded the file
      userId=$(ausearch -k ${auditMarker} -if ${auditLogFilePath} \
        | awk -v RS='----' -v i="inode=$fileModedInode" '$0~i {print}' \
        | awk -v RS='' 'END {print}' \
        | grep "SYSCALL" \
        | awk '{sub(/.* uid=/,X,$0);sub(/ .*/,X,$0);print}');

      # get dateTime when file has been modified in auditd standard format
      dateTimeAuditFormat=$(ausearch -k ${auditMarker} -if ${auditLogFilePath} \
      | awk -v RS='----' -v i="inode=$fileModedInode" '$0~i {print}' \
      | awk -v RS='' 'END {print}' \
      | awk -F"->" '/time->/ {print $2}');

      # convert dateTime to custom human format
      dateTime=$(date --date="$dateTimeAuditFormat" +%Y-%m-%d_%H-%M-%S);

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
