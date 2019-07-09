#!/bin/bash -x

# Version 2.2
# -----------------------------
# Script by Zach Burkhardt. Majorly changed from original piholesync script by /u/LandlordTiberius
# See Github repository for more information
# Script is configured to run as a CRON Job (crontab -e)
# Secondary pihole pulls files from primary pihole instead of primary pushing to secondary
# To that end, secondary pihole has an ssh-key for primary pihole
# Editing sudoers/visudo is no longer required for rsync to run passwordless
# Removed black.list from synced files (constantly copying for no reason)
# Pihole generates black.list from blacklist.txt when gravity is restarted

#VARS
FILES=(blacklist.txt regex.list whitelist.txt adlists.list lan.list) #list of files you want to sync
PIHOLEDIR=/etc/pihole #working dir of pihole
PIHOLE1IP=192.168.10.2 #IP of 1st PiHole
PIHOLE1USER=pi #user of 1st pihole

#LOOP FOR FILE TRANSFER
RESTART=0 # flag determine if service restart is needed
for FILE in ${FILES[@]}
do
  RSYNC_COMMAND=$(sudo rsync -ai -e "ssh -i /home/pi/.ssh/id_rsa" $PIHOLE1USER@$PIHOLE1IP:$PIHOLEDIR/$FILE $PIHOLEDIR)
  if [[ -n "${RSYNC_COMMAND}" ]]; then
    RESTART=1 # rsync copied changes, restart flagged
   fi
done

if [ $RESTART == "1" ]; then
  sudo -S pihole -g #restart pihole gravity if files updated
fi