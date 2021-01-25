#!/data/data/com.termux/files/usr/bin/bash
# Shell script to install vulnerable web applications on termux android
# Author - Ryuk (Rishi Choudhary)
# Github - https://github.com/Ryuk0x01
# Don't copy without giving credits.
# This script is able to install DVWA curently.

red='\033[1;31m'
yellow='\033[1;33m'
blue='\033[1;34m'
purple='\033[1;35m'
cyan='\033[1;36m'
green='\033[1;32m'
reset='\033[0m'

apt-get update -y && apt-get upgrade -y
apt install figlet
clear
echo -e "$red"
figlet " Vulnmux"
echo -e "$reset		by - Ryuk"

echo "It will use 27 mb data for main package."
read -p "Do you want to continue (y/n) : " CONT
if [ $CONT == "y" -o $CONT == "Y" ] 
then
	echo -e "$green Starting setup..."
else
	echo -e "$reset Quitting!!"
	exit
fi
USER=$(whoami)
echo -e "$cyan Checking for required packages."

PACKAGES=("php-apache" "mariadb" "curl" "nano" "git")

for PKG in ${PACKAGES[@]}
do
	IS_INSTALLED=$(dpkg-query -W --showformat='${Status}\n' ${PKG} | grep "install ok installed")

    if [ "${IS_INSTALLED}" == "install ok installed" ]
    then
	    echo -e "$reset ${PKG} is installed."
    else
	    apt install -y ${PKG}
    fi
done
sleep 2
echo -e "$green Configuring mysql server. $reset"

if [ ! -d /data/data/com.termux/files/usr/etc/my.cnf.d ]
then
	mkdir /data/data/com.termux/files/usr/etc/my.cnf.d
fi
sleep 2
echo -e "$green Initiating mysql db installation... $reset"

mysql_install_db

echo -e "$purple Starting mysql server as background job... $reset"

mysqld_safe -u ${USER} &
sleep 2
echo -e "$yellow Creating MySQL database db-name $reset: $cyan dvwa $reset"
mysql -e "CREATE DATABASE dvwa /*\!40100 DEFAULT CHARACTER SET utf8 */;"
echo "Database successfully created!"
sleep 2
echo -e "$green Showing databases..."
mysql -e "show databases;"
sleep 3
echo -e "$reset Creating new user without password :$red admin $reset"
mysql -e "CREATE USER 'admin'@localhost IDENTIFIED BY '';"
echo "User successfully created!"
echo -e "$cyan Showing users..."
sleep 1
mysql -e "SELECT User FROM mysql.user;"
sleep 3
echo -e "Granting ALL privileges on dvwa to admin $reset"
mysql -e "GRANT ALL PRIVILEGES ON dvwa.* TO 'admin'@localhost;"
sleep 3
mysql -e "FLUSH PRIVILEGES;"
echo -e "$green MySQL server configuration completed! $reset"
echo
echo
echo
sleep 2
echo "Checking for existing files.."
if [ ! -d DVWA ]
then
	echo -e "$blue Downloading $green DVWA $reset files..."
	echo
	git clone https://github.com/Ryuk0x01/DVWA.git
	sleep 2
fi
echo -e "Downloading configurations file for $red apache...$reset"
echo
curl -LO https://ryuk0x01.github.io/files/vulnmux/httpd.conf
curl -LO https://ryuk0x01.github.io/files/vulnmux/config.inc.php
echo -e "Configuring $green DVWA...$reset"
sleep 2
cp config.inc.php DVWA/config/
echo
echo
echo -e "Copying files in $red apache server...$reset"
echo
sleep 2
mv /data/data/com.termux/files/usr/etc/apache2/httpd.conf /data/data/com.termux/files/usr/etc/apache2/httpd.conf.bak
cp httpd.conf /data/data/com.termux/files/usr/etc/apache2/
cp -r DVWA/ /data/data/com.termux/files/usr/share/apache2/default-site/htdocs/dvwa
chmod 777 /data/data/com.termux/files/usr/share/apache2/default-site/htdocs/dvwa
curl -LO https://ryuk0x01.github.io/files/vulnmux/vulnmux
echo -e "Setting up $red Vulnmux $reset in /usr/bin"
cp vulnmux /data/data/com.termux/files/usr/bin/
chmod +x /data/data/com.termux/files/usr/bin/vulnmux
echo
if [ -d /data/data/com.termux/files/usr/share/apache2/default-site/htdocs/dvwa ]
then
	echo -e "$green DVWA $reset configured..."
	sleep 2
	echo "Clearing setup files..."
	rm -rf DVWA
	rm vulnmux
	rm httpd.conf
	rm config.inc.php
	sleep 2
fi
echo -e "$green Setup finished! $reset"
echo -e "Starting $red apache server...$reset"
echo
apachectl
sleep 2
echo -e "$red Apache server $green running!!$reset"
echo
echo -e "Type $red vulnmux$reset in terminal to use."
sleep 3
echo
echo -e "$green Launching browser...$reset"
sleep 3
exec am start --user 0 -n com.android.chrome/com.google.android.apps.chrome.Main -d "http://localhost:8080/dvwa/setup.php" >/dev/null
exit
