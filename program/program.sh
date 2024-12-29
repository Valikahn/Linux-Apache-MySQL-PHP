###################################################
##												 ##
##  PROGRAM FUNCTIONS   						 ##
##												 ##
###################################################


###--------------------  UNINSTALL DETACH UBUNTU PRO  --------------------###
##
UBUNTU_PRO() {
clear
echo "UNINSTALL DETACH UBUNTU PRO..."
sleep 5

if command -v pro &> /dev/null; then
    echo "Ubuntu Pro is installed. Checking if the system is attached..."
    PRO_STATUS=$(pro status --format json)
        if [[ $(echo "$PRO_STATUS" | grep -i '"attached": true') ]]; then
            echo "System is attached to Ubuntu Pro. Detaching now..."
            sudo pro detach
                if [ $? -eq 0 ]; then
                    echo "System successfully detached from Ubuntu Pro."
                else
                    echo "Failed to detach from Ubuntu Pro. Exiting."
                    exit 1
                fi
            else
                echo "System is not attached to Ubuntu Pro."
        fi
    echo "Proceeding to uninstall Ubuntu Pro."
    sudo apt-get remove --purge ubuntu-advantage-tools -y
    if [ $? -eq 0 ]; then
        echo "Ubuntu Pro has been successfully uninstalled."
    else
        echo "Failed to uninstall Ubuntu Pro."
        exit 1
    fi
else
    echo "Ubuntu Pro is not installed. Continuing."
fi
}

###--------------------  DELETE PURGE CLOUD-INIT  --------------------###
##
CLOUD_INIT() {
clear
echo "DELETE PURGE CLOUD-INIT..."
sleep 5

if dpkg -l | grep -q cloud-init; then
    apt-get purge -y cloud-init
	apt autoremove -y
else
	echo "Cloud-Init not found/installed on host - moving on."
fi

if id "cloud-user"; then
    deluser cloud-user
	echo "Deleted cloud-user account"
	deluser --remove-home cloud-user
	echo "Deleted cloud-user profile"
else
	echo "Cloud-User Profile not found on host - moving on."
fi

if [ -e "/var/log/cloud-init.log" ]; then
    rm -rf /var/log/cloud-init.log
    echo "Deleted cloud-init files (/var/log/cloud-init.log)"
fi
		
if [ -e "/var/log/cloud-init-output.log" ]; then
    rm -rf /var/log/cloud-init-output.log
    echo "Deleted cloud-init files (/var/log/cloud-init-output.log)"
fi
}

###--------------------  UPDATE DEB HOST  --------------------###
##
UPDATE_DEB_HOST() {
clear
echo "UPDATE DEB HOST..."
sleep 5

NEEDRESTART_MODE=a
DEBIAN_PRIORITY=required
export DEBIAN_FRONTEND=noninteractive

apt update && apt upgrade -y
apt-get -o Dpkg::Options::="--force-confdef" \
                -o Dpkg::Options::="--force-confold" \
                apt dist-upgrade -y
			    dpkg --configure -a

apt --purge autoremove -y
apt autoclean -y
apt update && apt upgrade -y
}

###--------------------  INSTALL APACHE AND CONFIGURE DIRECTORY PERMISSIONS  --------------------###
##
INSTALL_APACHE() {
clear
echo "INSTALL APACHE AND CONFIGURE DIRECTORY PERMISSIONS..."
sleep 5

apt install -y apache2
apt install -y php
chown -R www-data:www-data /var/www/html
usermod -aG www-data $USERNAME
chmod -R 775 /var/www/html
chmod -R g+w /var/www/html
chmod g+s /var/www/html
}

###--------------------  INSTALL IONCUBE LOADER  --------------------###
##
INSTALL_IONCUBE() {
clear
echo "INSTALL IONCUBE LOADER..."
sleep 5

PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
PHP_EXT_DIR=$(php -i | grep extension_dir | cut -d" " -f5)
IONCUBE_URL="https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz"
IONCUBE_DIR="/tmp/ioncube"

apt update -y && sudo apt upgrade -y
sudo apt install php-cli php-dev php-pear -y
wget $IONCUBE_URL -O /tmp/ioncube_loaders.tar.gz
tar xzf /tmp/ioncube_loaders.tar.gz -C /tmp/
sudo cp $IONCUBE_DIR/ioncube_loader_lin_${PHP_VERSION}.so $PHP_EXT_DIR

PHP_INI_CLI="/etc/php/${PHP_VERSION}/cli/php.ini"
PHP_INI_FPM="/etc/php/${PHP_VERSION}/fpm/php.ini"

if ! grep -q "ioncube_loader_lin_${PHP_VERSION}.so" $PHP_INI_CLI; then
    echo "zend_extension = $PHP_EXT_DIR/ioncube_loader_lin_${PHP_VERSION}.so" | sudo tee -a $PHP_INI_CLI
fi

if [ -f "$PHP_INI_FPM" ]; then
    if ! grep -q "ioncube_loader_lin_${PHP_VERSION}.so" $PHP_INI_FPM; then
        echo "zend_extension = $PHP_EXT_DIR/ioncube_loader_lin_${PHP_VERSION}.so" | sudo tee -a $PHP_INI_FPM
    fi
fi

if [ $(systemctl is-active apache2) == "active" ]; then
    sudo systemctl restart apache2
fi

if [ $(systemctl is-active php${PHP_VERSION}-fpm) == "active" ]; then
    sudo systemctl restart php${PHP_VERSION}-fpm
fi

clear
php -v | grep ionCube

if [ $? -eq 0 ]; then
    echo "IonCube Loader installed successfully!"
else
    echo "IonCube Loader installation failed."
fi
}

###--------------------  INSTALL MYSQL SERVER  --------------------###
##
INSTALL_MYSQL() {
clear
echo "INSTALL MYSQL SERVER..."
sleep 5

apt update
DEBIAN_FRONTEND=noninteractive apt install -y mysql-server
systemctl enable mysql
systemctl start mysql

mysql --user=root <<_EOF_
ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY '$MYSQL_ROOT_PASSWORD';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
FLUSH PRIVILEGES;

CREATE USER 'phpMyAdmin'@'%' IDENTIFIED BY '$PSWD';
GRANT ALL PRIVILEGES ON *.* TO 'phpMyAdmin'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
_EOF_

debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD"

cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf.bak
sed -i "s/^bind-address\s*=\s*127.0.0.1/bind-address            = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
}

###--------------------  INSTALL PHPMYADMIN  --------------------###
##
INSTALL_PHPMYADMIN() {
clear
echo "INSTALL PHPMYADMIN..."
sleep 5

echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $PSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections

apt-get install -y phpmyadmin
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
systemctl restart apache2
systemctl restart mysql
}

###--------------------  INSTALL DEPENDENCIES  --------------------###
##
INSTALL_DEPENDENCIES() {
clear
echo "INSTALL DEPENDENCIES..."
sleep 5

deb [arch=amd64 signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] http://nova.clouds.archive.ubuntu.com/ubuntu focal main restricted
apt install ubuntu-keyring
apt update
apt install -y libapache2-mod-php php-mysql php-cli php-curl php-json php-xml php-zip
apt install -y net-tools nmap tcpdump cifs-utils dnsutils default-jre dos2unix
apt install -y rar unrar perl python3 python3-pip

systemctl restart apache2
systemctl restart mysql
}

###--------------------  INSTALL WEBMIN  --------------------###
##
INSTALL_WEBMIN() {
clear
echo "INSTALL WEBMIN..."
sleep 5

yes | curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh
yes | sh setup-repos.sh
apt-get install -y --install-recommends webmin
apt-get install -y --install-recommends ./webmin-current.deb

# This command will reset the root password and prevent access using the shell login.
#sudo /usr/share/webmin/changepass.pl /etc/webmin root "$ROOT_PASSWORD"
}

###--------------------  INSTALL VSFTPD TO ENABLE FTP ACCESS  --------------------###
##
INSTALL_VSFTPD(){
clear
echo "INSTALL VSFTPD TO ENABLE FTP ACCESS..."
sleep 5

apt install -y vsftpd
systemctl enable vsftpd
systemctl start vsftpd

clear
source ./func/vsftpd.sh

systemctl restart vsftpd
}

###--------------------  INSTALL SSL VIA LETS ENCRYPT  --------------------###
##
INSTALL_LETS_ENCRYPT_SSL() {
clear
echo "INSTALL SSL VIA LETS ENCRYPT..."
sleep 5

sudo apt update
sudo apt install -y certbot python3-certbot-apache
sudo a2enmod ssl
sudo a2enmod rewrite
sudo systemctl restart apache2
sudo certbot --apache --agree-tos --no-eff-email -m "$EMAIL" -d "$DOMAIN"
sudo apachectl configtest
sudo systemctl reload apache2
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

CONFIRM_YES_NO
}

###--------------------  ENABLE FIREWALL AND CONFIGURE PORTS  --------------------###
##
ENABLE_FIREWALL() {
clear
echo "ENABLE FIREWALL AND CONFIGURE PORTS..."
sleep 5

## ALLOW
ufw allow in "Apache Full"
ufw allow 22/tcp # SSH
ufw allow 80/tcp # HTTP
ufw allow 443/tcp # HTTPS
ufw allow 10000/tcp # WEBMIN
ufw allow 3306/tcp # MYSQL
ufw allow 40000:50000/tcp # SAFETYNET PASSIVE 
ufw allow 10000:10100/tcp # VSFTPD/FTP PASSIVE

## DENY
ufw deny 23/tcp # TELNET
ufw deny 21/tcp # FTP
ufw deny 25/tcp # SMTP
ufw deny 137:139/tcp # NETBIOS/SMB
ufw deny 445/tcp # SMB
ufw deny 161:162/tcp # SNMP
ufw deny 3389/tcp # RDP
ufw deny 69/tcp # TFTP
ufw deny 111/tcp # RPC
ufw deny 5060/tcp # SIP
ufw deny 5061/tcp # SIP

# RELOAD | RESTART | ENABLE
echo "y" | ufw enable
systemctl enable apache2
systemctl start apache2
systemctl restart ssh
ufw reload
}

###--------------------  SSH PORT SECURITY | GENERATE PORT NUMBER BETWEEN 1024 and 65535 AND CHANGE  --------------------###
##
SSH_PORT_SECURITY() {
clear
echo "SSH PORT SECURITY | GENERATE PORT NUMBER BETWEEN 1024 and 65535 AND CHANGE..."
sleep 5

CREATE_RANDOM_PORT
SSH_PORT=$NEW_PORT

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i "/^#Port/c\Port $SSH_PORT" /etc/ssh/sshd_config

if ufw status | grep -q active; then
    if ! ufw status | grep -q "$SSH_PORT/tcp"; then
    ufw allow $SSH_PORT/tcp
    ufw reload
    fi
    ufw deny 22/tcp
    ufw reload
fi

CONFIRM_YES_NO
}

###--------------------  HTML PAGE CREATION  --------------------###
##
DEPLOY_HTML() {
clear
echo "HTML PAGE CREATION..."
sleep 5

rm -rf /var/www/html/* > /dev/null 2>&1
cp -r web/* /var/www/html/ > /dev/null 2>&1
rm -rf /var/www/html/index.html > /dev/null 2>&1
touch /var/www/html/index.html > /dev/null 2>&1

source ./conf/html.sh
}

###--------------------  VHOST QUESTION  --------------------###
##
DEPLOY_VHOSTS() {
clear
echo "VHOST QUESTION..."
sleep 5

if [ "$VHOST_ANSWER" == "1" ]; then
    clear
    echo "WORKING ON: ${RED}[  ${FUNCNAME[0]}  ]${NORMAL}"
    sleep 5
    source ./func/vhost.sh
fi

CONFIRM_YES_NO
}