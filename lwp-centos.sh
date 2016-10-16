#!/bin/bash
# Written by Brett Salmiery
# Note: This script is made just to get LXC Web Panel working in Centos 7
# Quick run: wget https://raw.githubusercontent.com/salmiery/lxc/master/lwp-centos.sh -O - | /bin/sh
##############################################################################################

echo ''' _     __   _______  __          __  _       _____                 _ '''
echo '''| |    \ \ / / ____| \ \        / / | |     |  __ \               | |'''
echo '''| |     \ V / |       \ \  /\  / /__| |__   | |__) |_ _ _ __   ___| |'''
echo '''| |      > <| |        \ \/  \/ / _ \ '_ \  |  ___/ _` | '_ \ / _ \ |'''
echo '''| |____ / . \ |____     \  /\  /  __/ |_) | | |  | (_| | | | |  __/ |'''
echo '''|______/_/ \_\_____|     \/  \/ \___|_.__/  |_|   \__,_|_| |_|\___|_|'''
echo
echo 
echo ''' _____            _   _____ _____   _____    _ _ _   _             '''
echo '''/  __ \          | | |  _  /  ___| |  ___|  | (_) | (_)            '''
echo '''| /  \/ ___ _ __ | |_| | | \ `--.  | |__  __| |_| |_ _  ___  _ __  '''
echo '''| |    / _ \ '_ \| __| | | |`--. \ |  __|/ _` | | __| |/ _ \| '_ \ '''
echo '''| \__/\  __/ | | | |_\ \_/ /\__/ / | |__| (_| | | |_| | (_) | | | |'''
echo ''' \____/\___|_| |_|\__|\___/\____/  \____/\__,_|_|\__|_|\___/|_| |_|'''
echo 
echo 'Written by Brett Salmiery'
sleep 2

echo '[~] Downloading web panel'
wget https://lxc-webpanel.github.io/tools/install.sh -O lwpinstall.sh

echo '[~] Converting "apt-get" to "yum"'
sed -i -e 's/apt-get/yum/g' lwpinstall.sh

echo '[~] Beginning install'
/bin/sh lwpinstall.sh




echo '[~] Removing the service that came with the install'
## Remove this other service. Start-stop-daemon didn't work for me.
rm -rf /etc/init.d/lwp


##################################################################
######## NOTE: THIS MAY NEED TO CHANGE IN FUTURE RELEASES ########
########      This changes the path to the python dir     ########
######## because, the script does not use absoulute path. ########
##################################################################
#sed -i -e 's/# configuration/# configuration\nos.chdir('/srv/lwp') #Change to directory\n/g' /srv/lwp/lwp.py

echo '[~] Changing lwp.py to use absolute path of config file'
sed -i -e 's/lwp.conf/\/srv\/lwp\/lwp.conf/g' /srv/lwp/lwp.py

echo '[~] Creating a new service to work with systemd'
## Write our own systemd service
cat > '/etc/systemd/system/lwp.service' <<EOF
# Written by Brett Salmiery
[Unit]
Description=Systemd LXC Web Panel startup script for Centos 7

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python /srv/lwp/lwp.py
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

## Refresh systemd

echo '[~] Refreshing systemd'
systemctl daemon-reload


echo '[~] Starting the service...'
## Start our service
systemctl start lwp

## Enable it to start on boot

echo '[~] Enabling on startup...'
echo 'NOTE: To disable on startup use command `systemctl disable lwp`'
systemctl enable lwp
ln -s '/etc/systemd/system/lwp.service' '/etc/systemd/system/multi-user.target.wants/lwp.service'

echo [!] Finished
echo 
echo "Written by Brett Salmiery"
