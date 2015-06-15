#!/bin/bash
# Install Script for Snort/Snortsam/phpservermon
# Authors: Altan & Darren
# Links: twitter.com/altan_aksoy
# Date: 15 June 2015
# version: 1.0.6
#------------------
# Variables
#------------------
YES_INPUT="yes"
Y_INPUT="y"
NO_INPUT="no"
N_INPUT="n"
#------------------
#Checks if script is run as root.
#Stops script if not root.
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
echo ""
echo "+------------------------------------+"
echo "+------------------------------------+"
echo "Installation and setup Script for:"
echo "Snort | Snortsam | phpservermon"
echo "+------------------------------------+"
echo "+------------------------------------+"
read -p "Press [Enter] key to Continue"
cd /etc/apt/
echo "#dotdeb sources" >> sources.list
echo "deb http://packages.dotdeb.org jessie all" >> sources.list
echo "deb-src http://packages.dotdeb.org jessie all" >> sources.list
cd ~
wget http://www.dotdeb.org/dotdeb.gpg
apt-key add dotdeb.gpg
rm dotdeb.gpg 
apt-get update && apt-get upgrade
apt-get install git-core python curl php5-mysql build-essential openssl libssl-dev sqlite3 python g++ make checkinstall lynis iptables unzip php5-fpm curl php5-curl php5-cli php5-tidy php5-sqlite automake libtool gcc git-core curl build-essential openssl libssl-dev sqlite3 python g++ make checkinstall lynis iptables monodevelop mono-gmcs mono-mcs liblog4net-cil-dev nginx unzip php-apc libmysqlclient-dev libpcre3-dev libpcap-dev libdnet libdnet-dev libdumbnet-dev bison flex
echo ""
echo "+------------------------------------+"
echo "MySQL will be installed. Please choose password"
echo "+------------------------------------+"
read -p "Press [Enter] key to Continue"
apt-get -y install mysql-server
#Downloading nginx config
echo ""
echo "+------------------------------------+"
echo "Nginx Virtual Host file 'snortnginx' wll be installed"
echo "+------------------------------------+"
read -p "Press [Enter] key to Continue"
cd /etc/nginx/sites-available && wget -N --no-check-certificate https://download.altan.me/snortnginx
ln -s /etc/nginx/sites-available/snortnginx /etc/nginx/sites-enabled/snortnginx
echo "+------------------------------------+"
echo "If you already have nginx preconfigured & want to keep,"
echo "'default' virtualhost file - enter 'no'"
echo "or enter 'y' or 'yes' to remove default [Recommended]"
echo "+------------------------------------+"
echo "[y/n]"
read INPUT
#Converts input case to lower case to match variables
VAR=$( tr '[:upper:]' '[:lower:]' <<<"$INPUT" )
if [ "$VAR" == "$Y_INPUT" ] || [ "$VAR" == "$YES_INPUT" ]; then
    echo "+------------------------------------+"
    echo "Removing default..."
    echo "+------------------------------------+"
    rm /etc/nginx/sites-enabled/default
    sleep 3s
else
  echo "+------------------------------------+"
  echo "Continuing in 5s"
  echo "+------------------------------------+"
  sleep 5s
fi
#Downloading packages
mkdir ~/tmp && cd ~/tmp && wget http://sourceforge.net/projects/snort/files/snort/daq-2.0.5.tar.gz/download
tar xvfz download && rm download
cd daq* && ./configure; sudo make; sudo make install
rm -rf daq*
cd ..
wget http://sourceforge.net/projects/snort/files/latest/download
wget http://www.snortsam.net/files/snortsam/snortsam-src-2.70.tar.gz
wget http://www.snortsam.net/files/snort-plugin/snortsam-2.9.5.3-1.diff.gz
#extract packages
tar -xvzf download && rm download
tar -xvzf snortsam-src-2* && rm *.tar.gz
gunzip snortsam-2*
#Starting Compilers
cd snortsam
chmod +x makesnortsam.sh
./makesnortsam.sh
cp snortsam /usr/bin
cd ~/tmp/snort-2*
autoreconf --force --install
./configure --enable-sourcefire; make; make install
patch -p1 <../snortsam-2.9.5.3-1.diff
chmod +x autojunk.sh
./autojunk.sh
./configure --enable-sourcefire; make; make install
#dir creation
mkdir /etc/snort
cd ~/tmp/snort-2*/etc
rm Makefile*
#copy default config files to final location
cp * /etc/snort
mkdir /var/log/snort && mkdir /etc/snort/rules
cd ~/tmp
# Download custom config files from private VPS & move to correct location
wget --no-check-certificate https://download.altan.me/local.rules && mv local.rules /etc/snort/rules/
wget -N --no-check-certificate https://download.altan.me/snort.conf && mv snort.conf /etc/snort
wget --no-check-certificate https://download.altan.me/snortsam.conf && mv snortsam.conf /etc
# Snort config files, need input from user
echo "+------------------------------------+"
echo "Ensure you change 'ipvar HOME_NET' IP in snort.conf before running snort"
echo "Do you know your IP address ? - [y/n]"
echo "+------------------------------------+"
echo "-"
read INPUT
#Converts input case to lower case to match variables
VAR2=$( tr '[:upper:]' '[:lower:]' <<<"$INPUT" )
if [ "$VAR2" == "$N_INPUT" ] || [ "$VAR2" == "$NO_INPUT" ]; then
  echo "+------------------------------------+"
  echo "Copy IP address from NIC to be monitored"
  echo "+------------------------------------+"
  ifconfig
  read -p "Press [Enter] key continue"
else
  echo "+------------------------------------+"
  echo "Continuing in 5s"
  echo "+------------------------------------+"
  sleep 5s
fi
echo "+------------------------------------+"
echo "the editor will now open, please replace IP after HOME_NET"
echo "to exit the editor, 'ctrl+x' then 'y' then 'enter'"
echo "+------------------------------------+"
read -p "Press [Enter] key continue"
nano /etc/snort/snort.conf
snortsam
ldconfig
#create placeholder files. ( snort complains without these )
echo "#Whitelist Placeholder" >> /etc/snort/rules/white_list.rules
echo "#Blacklist Placeholder" >> /etc/snort/rules/black_list.rules
#echo ""
#echo "+------------------------------------+"
#echo "Snort will now test run, CTRL+C to close and contine snort"
#echo "+------------------------------------+"
#read -p "Press [Enter] key continue"
#sleep 10s
#snort -c /etc/snort/snort.conf -l /var/log/snort/
echo "+------------------------------------+"
echo "Snort init script will be installed"
echo "to start snort etc: 'service snort start'"
echo "+------------------------------------+"
read -p "Press [Enter] key continue"
wget -N --no-check-certificate https://download.altan.me/snort && mv snort /etc/init.d/
chmod 755 /etc/init.d/snort
#Download and set perms for phpservermon
cd /var/www/html
wget http://sourceforge.net/projects/phpservermon/files/latest/download
tar xvfz download && rm download
mv phpserver* phpservermon
touch /var/www/html/phpservermon/config.php
chmod 777 phpservermon
chown www-data:www-data /var/www/html/phpservermon/config.php
echo "+------------------------------------+"
echo "A database 'servermon' will be created. please input mysql password"
echo "+------------------------------------+"
read -p "Press [Enter] key to continue"
# MySQL database creation
mysql -u root -p -e "create database servermon"; 
echo "+------------------------------------+"
echo "Created MySQL database name: servermon"
echo "+------------------------------------+"
sleep 2s
# Creates Cron Job
line="*/2 * * * * /usr/bin/php /var/www/html/phpservermon/cron/status.cron.php"
(crontab -u root -l; echo "$line" ) | crontab -u root -
service nginx restart
service php5-fpm restart
#if no errors continue with setup
# if unable to create config.php
# copy content from box on webpage
echo "+------------------------------------+"
echo "+----------------|||||---------------+"
echo "+------------Project O1nk------------+"
echo "+------------------------------------+"
echo "Script Install Completed"
echo "For troubleshootig information visit our github"
echo "To continue with setup - navigate to http://localhost/phpservermon"
echo "Database name: servermon"
echo "Script by Altan & Darren"
echo "+------------------------------------+"
echo "!! SYSTEM RESTART REQUIRED !!"
read -p "Press [Enter] key to close script"
