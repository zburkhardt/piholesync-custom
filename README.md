This script was originally based on version 2.1 of the piholesync script by /u/LandlordTiberius. This script is designed to be run from the secondary Pi-Hole host(s) and pull changed filed from the primary Pi-Hole host. Note: This means that this is a one-way script; changes only propagate from the primary to the secondary Pi-Holes. The secondary Pi-Hole host machines use an SSH key and run rsync to check for changes in adlists, blacklists, whitelists, etc.

Pi-Hole Sync supports version 4 and version 5 of Pi-Hole (differing in how the adlists, blacklists, whitelists, etc. are stored).

# Installation Steps
In this example, it is assumed that you are using user *"pi"* on both host machines and that the IP addresses of the primary and secondary host machines are *192.168.1.2* and *192.168.1.3*, respectively. Replace these values for your specific situation.

### Setup SSH Keys
1. SSH into the secondary Pi-Hole host (**ssh pi@192.168.1.3**)
2. Generate an SSH RSA key pair by running **ssh-keygen** (hit Enter through all options)
3. Copy the key pair to the primary Pi-Hole host by running **ssh-copy-id pi@192.168.1.2** (type *yes* if asked if you want to continue)
4. Enter the pi's user password of the primary Pi-Hole host
5. Change directory to .ssh (**cd ~/.ssh**)
6. Add the private SSH key to the secondary Pi-Hole host's SSH authentication agent (**ssh-add id\_rsa**)
7. Copy the public SSH key to the primary Pi-Hole host (**scp id\_rsa.pub pi@192.168.1.2:~/.ssh/**)
8. SSH into the primary Pi-Hole host (**ssh pi@192.168.1.2**)
9. Change directory to .ssh (**cd ~/.ssh**)
10. Concatenate the public SSH key into the user's authorized keys (**cat id\_rsa.pub >> authorized\_keys**)
11. Exit back into the secondary Pi-Hole host (**exit**)

### Setup Script
11. On your secondary Pi-Hole host, change directory to your home directory (**cd ~**)
12. Clone the script sync script (**git clone https://github.com/zburkhardt/piholesync-custom.git**)
13. Change directory into the new folder (**cd piholesync-custom**)
14. Change the Pi-Hole directory, primary host IP address, and primary host user as neccessary in the script
14. Make the script executable (**chmod +x piholesync.rsync.sh**)
15. Setup a CRON Job to run the script on a schedule (**crontab - e**)
16. Scroll to the bottom and, on a blank new line, type **\*/5 \* \* \* \* /bin/bash /home/pi/piholesync-custom/piholesync.rsync.sh** (This runs the script every 5 minutes. Also, adjust the location to where you save the script.)
17. Exit nano editor by hitting **Ctrl + x** and then **y**