###################################################
##												 ##
##  SYSTEM CHECK								 ##
##												 ##
###################################################


###--------------------  SUDO/ROOT CHECK  --------------------###
##
if [ "$(id -u)" -ne 0 ]; then 
	echo -n "SUDO PERMISSION CHECK..."; 	sleep 5
	echo -e "\rSUDO PERMISSION CHECK... ${RED}[  ACCESS DENIED  ]${NORMAL}"; sleep 3
	echo
	echo "Error 126: Command cannot execute."
	echo "This error code is used when a command is found but is not executable.  Execute as root/sudo!"
	exit 126
else
	echo -n "SUDO PERMISSION CHECK..."; 	sleep 5
	echo -e "\rSUDO PERMISSION CHECK... ${GREEN}[  ACCESS GRANTED  ]${NORMAL}"; sleep 3
    clear
fi

###--------------------  COLLECTING SYSTEM DATA  --------------------###
##
clear
echo -n "DATA COLLECTION..."
sleep 3

if [ -f /etc/os-release ]; then
    . /etc/os-release
    ## DEB
    if [[ "$ID" == "ubuntu" ]]; then
        VERSION_NUMBER=$(echo "$VERSION" | grep -oP '^\d+\.\d+')
        DISTRO=$NAME
        echo -e "\rDATA COLLECTION... ${GREEN}[  OK!  ]${NORMAL}"
        sleep 3
    ## RHEL
    elif [[ "$ID" == "rhel" || "$ID" == "centos" ]]; then
        VERSION_NUMBER=$(echo "$VERSION_ID" | grep -oP '^\d+')
        DISTRO=$NAME
        echo -e "\rDATA COLLECTION... ${GREEN}[  OK!  ]${NORMAL}"
        sleep 3
    ## WTF
    else
        echo "Unsupported distribution."
        echo -e "\rDATA COLLECTION... ${BOLD}${RED}[  FAILED!  ]${NORMAL}"
	    sleep 3
        exit 1
    fi

# DEB FALLBACK
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    DISTRO=$DISTRIB_ID
    echo -e "\rDATA COLLECTION... ${GREEN}[  OK!  ]${NORMAL}"
    sleep 3
else
    echo -e "\rDATA COLLECTION... ${BOLD}${RED}[  FAILED!  ]${NORMAL}"
	sleep 3
	echo "ERROR: RHEL or DEBIAN release files could not be found! [OPERATING SYSTEM DETECTION]"
	exit 1
fi

###--------------------  NEEDRESTART PREVENTION  --------------------###
##
NEED_CONF_FILE="/etc/needrestart/needrestart.conf"
UBUNTU_VERSION=$(lsb_release -rs)

if [[ "$UBUNTU_VERSION" == "22.04" ]]; then
	if grep -q '^\$nrconf{restart} = '\''a'\'';' "$NEED_CONF_FILE"; then
		echo "The setting is already set to '\$nrconf{restart} = '\''a'\'';'. No changes made."
	else
		cp "$NEED_CONF_FILE" "$NEED_CONF_FILE.bak"
		if grep -q "^#\$nrconf{restart} = 'i';" "$NEED_CONF_FILE"; then
			sed -i "s/^#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/" "$NEED_CONF_FILE"
			echo "Configuration updated: \$nrconf{restart} is now set to 'a'."
		else
			echo "No matching line to uncomment and change."
		fi
	fi
else
	echo "This script only runs on Ubuntu 22.04. Detected version: $UBUNTU_VERSION."
fi

CONFIRM_YES_NO