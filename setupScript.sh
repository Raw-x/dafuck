

#!/usr/bin/env bash
#
# Vuln Setup Script
# Brought to you by: MrGreen and the ZentrixPlus Team
#
# Vuln Site v0.000000000000001.beta
#
# Base Server to use as platoform for this script (if you like, not totally required):
# Download: http://downloads.sourceforge.net/thoughtpolicevm/centos-5.2-i386-server.zip
# TorrentDL: http://download.thoughtpolice.co.uk/centos-5.1-i386-server.zip.torrent
# Default Login Info:
#  USER: root
#	PASS: thoughtpolice
#
# Created by this script:
# MySQL Credentials:
#	User: root
#	Pass: sup3rs3cr3t
#
 
 
if [ $(id -u) == 0 ]; then
	clear
	echo
	echo "Welcome to MrGreen's Z+ Lab Setup Script" | grep --color "Welcome to MrGreen's Z+ Lab Setup Script"
	echo
	echo "This will automate the typical setup steps required for my suggested vuln lab server setup" | grep --color 'This will automate the typical setup steps required for my suggested vuln lab server setup'
	echo "It's going to take just a bit to get everything all setup, but should only require minimal interaction if any....." | grep --color -E 'It||s going to take just a bit to get everything all setup||but should only require minimal interaction if any'
	echo
 
	echo
	echo "Starting System Setup......" | grep --color 'Starting System Setup'
	echo
	echo "Installing core dev tools....." | grep --color 'Installing core dev tools'
	echo
	# Dev Tools includes lots of small needed items like automake...
	yum -y groupinstall 'Development Tools'
	yum -y install gcc
	yum -y install curl-devel
 
	clear
	echo
	echo "Dev Tools installed, moving to Apache next...." | grep --color -E 'Dev Tools installed||moving to Apache next'
	echo
 
	#Install Apache Server 2.4?
	yum -y install httpd mod_ssl
 
	home="/root/Desktop/"
	ip=$(ifconfig eth0 | awk 'BEGIN { FS = "n"; RS = "" } { print $2 }' | sed -e 's/ .*addr://' -e 's/ .*//')
 
	cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bk
 
	#set ip for Apache to listen on to our LAN IP so we can access from the network on other attacking machines :)
	sed -i -s "s/#ServerName www.example.com:80/ServerName $ip:80" /etc/httpd/conf/httpd.conf
 
	service httpd start
 
	#make sure it restarts on any reboots...
	chkconfig --levels 235 httpd on
 
	clear
	echo
	echo "Apache has been installed! Going to install MySQL now....." | grep --color -E 'Apache has been installed||Going to install MySQL now'
	echo
 
	#Install Oracle MySQL 5.0.95
	yum -y install mysql-server
 
	service mysqld start
 
	#make sure it restarts on any reboots...
	chkconfig --levels 235 mysqld on
 
	#establish root user and associated pass
	mysqladmin -u root password 'sup3rs3cr3t'
 
	clear
	echo
	echo "Confirming MySQL was setup properly....." | grep --color 'Confirming MySQL was setup properly'
	echo
	echo "MySQL Successfully Installed!" | grep --color 'MySQL Successfully Installed'
	echo "MySQL Version: $(mysql -u root -psup3rs3cr3t -e "SELECT version()" | grep "5.0")" | grep --color 'MySQL Version'
	echo
	echo "Installing PHP Support now....." | grep --color 'Installing PHP Support now'
	echo
 
	# Installs PHP 5.1 so we can have all the fun we want with NULL Bytes, path truncation attacks, and possible some SAFE_MODE bypassing
	yum -y install php php-mysql php-devel php-gd php-pecl-memcache php-pspell php-snmp php-xmlrpc php-xml
 
	#NOTE: No edits needed to /etc/php.ini file out of the box as its vuln as hell with 5.1, but if you want to tighten things down later you can edit this file as needed to help restrict things like RFI's :p (allow_url_fopen, open_basedir, SAFE_MODE, disable_functions, magic_quotes_gpc, etc....)
 
	service httpd restart
 
	echo "<?php echo "Its working fool"; ?>" > /var/www/html/testing.php
 
	clear
	echo
	echo "Confirming PHP is working now...." | grep --color 'Confirming PHP is working now'
	echo
	curl -s $ip/testing.php | grep 'Working'
	echo
	rm -f /var/www/html/testing.php 2> /dev/null
 
	echo
	echo "Installing Git next...." | grep --color 'Installing Git next'
	echo
	yum -y install zlib-devel openssl-devel cpio expat-devel gettext-devel
	cd /usr/local/src
	wget http://git-core.googlecode.com/files/git-1.7.9.tar.gz
	tar xvzf git-1.7.9.tar.gz
	rm -f git-1.7.9.tar.gz 2> /dev/null
	cd git-1.7.9
	./configure
	make
	make install
 
	clear
	echo
	echo "Git installed...." | grep --color 'Git installed'
	cd $home
 
	echo
	echo "Downloading Audi-1's SQL Injection Training Lessons now......" | grep --color -E 'Downloading Audi||1||s SQL Injection Training Lessons now'
	echo
	# Download the Audi SQL Injection Training Labs (very good set of lessons for learning the basic methods of SQLi)
	cd /var/www/html/
	git clone https://github.com/Audi-1/sqli-labs.git
	#Now set things up...
	cd sqli-labs/sql-connections/
	sed -i -e "s/toor/sup3rs3cr3t/" db-creds.inc
	echo
	echo "Need your help to do this next step..." | grep --color 'Need your help to do this next step'
	echo "Please click on the 'setup/reset' button in the upper left of the page that is about to open in your browser to setup the database for the SQL Training Labs....close browser when done to resume...."
	echo
	echo
 
	#user needs to click on link to setup database for labs (its on you, dont fuck up this simple step!)
	firefox "$ip/sqli-labs/index.html"
	cd $home
 
	clear
	echo
	echo "OK, the SQLi labs should now be good to go. Now to setup the XSS Lab...." | grep --color -E 'OK||the SQLi labs should now be good to go||Now to setup the XSS Lab'
	echo
 
	echo
	echo "Downloading SpiderLabs's XSS Injection Lab now......" | grep --color "Downloading SpiderLabs's XSS Injection Lab now"
	echo
 
	cd /var/www/html/
	git clone https://github.com/SpiderLabs/XSSmh.git
	mv XSSmh/ xss-labs/
	chmod a+rw xss-labs/pxss.html
	rm -f xss-labs/CHANGELOG 2> /dev/null
	rm -f xss-labs/license.txt 2> /dev/null
	rm -f xss-labs/README 2> /dev/null
	rm -f xss-labs/challenges/*.txt 2> /dev/null
 
	clear
	echo
	echo "OK, the XSS lab should now be good to go. Now to setup the front of the main site...." | grep --color -E 'OK||the XSS lab should now be good to go||Now to setup the front of the main site'
	echo
 
	# Download Z+ Fun House to Tie it All together :)
	wget http://inf0rm3r.webuda.com/training/ZPlus-FunHouse.tar.gz 
	tar -zxvf ZPlus-FunHouse.tar.gz
	rm -f ZPlus-FunHouse.tar.gz 2> /dev/null
 
	echo
	echo "Almost done, just have to tweak some system settings...." | grep --color -E 'Almost done||just have to tweak some system settings'
	echo
 
	#enable log poisoning attacks....
	chown apache /var/log/httpd/
 
	#re-assign ownership, recursively, of web directories since we created everything as root user
	chown -R apache:apache /var/www/html/sqli-labs/
	chown -R apache:apache /var/www/html/xss-labs/
 
	#let's make a few places to write to in case someone figures something fun out :p
	mkdir /var/www/html/images/
	chown apache:apache /var/www/html/iamges/
	chmod a+rwx /var/www/html/images/
	chmod a+rwx /var/www/html/sqli-labs/images
 
	#refresh web server just to be safe and make sure all our changes take affect
	service httpd restart
	clear
 
	echo
	echo "The Z+ Learning Server is setup now!" | grep --color "The Z+ Learning Server is setup now!"
	echo
	echo "In order to access it you can point your browser from any machine on your LAN to: http://$ip/" | grep --color 'In order to access it you can point your browser from any machine on your LAN to'
	echo
	echo "Have fun, and until next time - ENJOY" | grep --color -E 'Have fun||and until next time||ENJOY'
	echo
	echo
 
	#Shit is done! Point them at the new site and let them at it :)
	firefox "$ip/" &
else
	echo
	echo "This script needs to be run as root!" | grep --color 'This script needs to be run as root'
	echo 
	exit 666;
fi
#EOF


