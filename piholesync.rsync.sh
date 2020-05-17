#!/bin/bash -x

# Script by Zach Burkhardt (zburkhardt). Significantly changed from original piholesync script by /u/LandlordTiberius
#
# The secondary Pi-Hole pulls files from the primary pihole remotely and natively using rsync
# Run as a scheduled CRON Job (crontab -e) on secondary pi-hole
# To authenticate the remote commands, the secondary pihole needs an ssh-key for the primary pihole
# -----------------------------
# Version 3.0
# -----------------------------
# Adds basic compatibility with Pi-Hole v5.0's new database
# Maintains compatibility with Pi-Hole v4 individual text and list files


# VARIABLES
DATABASES=(gravity.db) # list of databases you want to sync (Pi-Hole v5 and newer only)
FILES=(blacklist.txt regex.list whitelist.txt adlists.list lan.list) # list of files you want to sync (Pi-Hole v4 and older only)
PIHOLEDIR=/etc/pihole # working dir of pihole
PIHOLE1IP=192.168.1.2 # IP of 1st/Primary PiHole
PIHOLE1USER=pi # user of 1st/Primary pihole

# CHECK PI-HOLE VERSION
syncSource=0 # var to determine which file sync list to use
piHoleVer=$(pihole -v) # run pihole version command
piHoleVer=$(echo ${piHoleVer[0]} | cut -c20-23) # get substring from console output
majorVer=$(echo $piHoleVer | cut -c1-2) # another substring to get the major version number
if test $majorVer = 'v5'; then
    echo "Pi-Hole v5 is installed. Syncing databases..."
    syncSource=1
elif test $majorVer = 'v4'; then
    echo "Pi-Hole v4 is installed. Syncing text and list files..."
    syncSource=2
else
    echo "It appears that Pi-Hole v4/v5 is not installed."
    echo "Script found the following installed version: $piHoleVer (major version: $majorVer). Exiting..."
    exit 1
fi

# LOOP FOR FILE TRANSFER
RESTART=0 # flag to determine if service restart is needed
if test $syncSource = '1'; then
    for DATABASE in ${DATABASES[@]}
    do
        RSYNC_COMMAND=$(sudo rsync -ai -e "ssh -i /home/pi/.ssh/id_rsa" $PIHOLE1USER@$PIHOLE1IP:$PIHOLEDIR/$DATABASE $PIHOLEDIR)
        if [[ -n "${RSYNC_COMMAND}" ]]; then
            echo "Copied $DATABASE from $PIHOLEDIR at $PIHOLE1IP"
            RESTART=1 # rsync copied changes, restart flagged
        fi
    done
elif test $syncSource = '2'; then
    for FILE in ${FILES[@]}
    do
        RSYNC_COMMAND=$(sudo rsync -ai -e "ssh -i /home/pi/.ssh/id_rsa" $PIHOLE1USER@$PIHOLE1IP:$PIHOLEDIR/$FILE $PIHOLEDIR)
        if [[ -n "${RSYNC_COMMAND}" ]]; then
            echo "Copied $FILE from $PIHOLEDIR at $PIHOLE1IP"
            RESTART=1 # rsync copied changes, restart flagged
        fi
    done

if [ $RESTART == "1" ]; then
    echo "One or more files were synced. Restarting pihole gravity..."
  sudo -S pihole -g # restart pihole gravity if files are updated
fi