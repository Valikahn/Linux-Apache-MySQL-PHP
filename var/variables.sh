###################################################
##												 ##
##  VARIABLES									 ##
##												 ##
###################################################


###--------------------  COLORS DECLARE  --------------------###
##
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2)
LBLUE=$(tput setaf 6)
RED=$(tput setaf 1)
PURPLE=$(tput setaf 5)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BBLACK=$(tput setaf 8)
BRED=$(tput setaf 9)
BGREEN=$(tput setaf 10)
BYELLOW=$(tput setaf 11)
BBLUE=$(tput setaf 12)
BMAGENTA=$(tput setaf 13)
BCYAN=$(tput setaf 14)
BWHITE=$(tput setaf 15)

###--------------------  BLINK DECLARE  --------------------###
##
BLINK=$(tput blink)
RESET=$(tput sgr0)

###--------------------  PASSWORD COLLECTION  --------------------###
##
PSWD=$(PASSGEN)
MYSQL_ROOT_PASSWORD=$(PASSGEN)

###--------------------  IP ADDRESS SET  --------------------###
##
IP_ADDRESS=$(ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '^127\.')
