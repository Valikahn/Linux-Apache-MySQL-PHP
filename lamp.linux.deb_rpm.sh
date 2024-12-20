#!/bin/bash
clear
export EDITOR=nano

###--------------------  START OF LAMP SCRIPT  --------------------###
##


######################################################################################################################################################
######################################################################################################################################################
##																																					##
##  LAMP (Linux, Apache, MySQL and PHP)                                                                                                             ##
##  Apache SSL, phpMyAdmin, Webmin and VSFTPD inc FTP SSL                                                                                           ##
##  Managing a Web Server (MAWS_HP2V48)                                                                                                             ##
##																																					##
##  Written by:  Neil Jamison                   																									##
##  Copyright (C) 2024 Neil Jamieson																												##
##																																					##
######################################################################################################################################################
######################################################################################################################################################
##																																					##
##  Licensed under the GPLv3 License.																												##
##  GPLv3 Licence:  https://www.gnu.org/licenses/gpl-3.0.en.html																					##
##																																					##
##	This program comes with ABSOLUTELY NO WARRANTY; for details type 'show w'. This is free software, and you are welcome to redistribute it		##
##  under certain conditions; type 'show c' for details."																							##
##																																					##
######################################################################################################################################################
######################################################################################################################################################

###
source ./func/functions.sh
source ./var/variables.sh
source ./primary/system_check.sh
source ./primary/questions.sh
source ./program/program.sh

###--------------------  EXECUTE FUNCTIONS  --------------------###
##
UBUNTU_PRO
CLOUD_INIT
UPDATE_DEB_HOST
INSTALL_APACHE
INSTALL_IONCUBE
INSTALL_MYSQL
INSTALL_PHPMYADMIN
INSTALL_DEPENDENCIES
INSTALL_WEBMIN
INSTALL_VSFTPD
INSTALL_LETS_ENCRYPT_SSL
ENABLE_FIREWALL
SSH_PORT_SECURITY
DEPLOY_HTML
DEPLOY_VHOSTS

###--------------------  COMPLETE | DONE  --------------------###
##
clear
echo "DONE!"

echo "phpMyAdmin Username: phpMyAdmin | Password: $PSWD"
echo "Webmin Username: $USERNAME | Password: [SHELL PASSWORD]"
echo "SSH IP: $IP_ADDRESS | SSH Port: $SSH_PORT"
echo "FTP IP: $IP_ADDRESS | FTP Port: $FTP_PORT"