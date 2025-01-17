###################################################
##												 ##
##  MULTIPLE USE FUNCTIONS						 ##
##												 ##
###################################################


###--------------------  RANDOM PASSWORD GENERATOR  --------------------###
##
PASSGEN() {
local genln=$1
[ -z "$genln" ] && genln=16
## Without Special Characters
tr -dc A-Za-z0-9 < /dev/urandom | head -c ${genln} | xargs
## With Special Characters
## tr -dc 'A-Za-z0-9!@#$%^&*()_+-=[]{}|;:,.<>?' < /dev/urandom | head -c ${genln} | xargs
}

###--------------------  IS PORT IN USE  --------------------###
##
IS_PORT_IN_USE() {
  lsof -i -P -n | grep LISTEN | grep ":$1 " > /dev/null
  return $?
}

###--------------------  CREATE RANDOM PORT  --------------------###
##
CREATE_RANDOM_PORT() {
    unset $NEW_PORT
    while true; 
    do
      NEW_PORT=$((RANDOM % 64512 + 1024))
      if ! IS_PORT_IN_USE $NEW_PORT; then
        break
      fi
    done
}

###--------------------  CONFIRM YES NO  --------------------###
#
CONFIRM_YES_NO () {
while true;
	do
	read -p "Happy to proceed? (Yy/Nn): " CONFIRM
    echo
    if [[ "$CONFIRM" == "Y" ]] || [[ "$CONFIRM" == "y" ]] || [[ "$CONFIRM" == "YES" ]] || [[ "$CONFIRM" == "yes" ]] || [[ "$CONFIRM" == "Yes" ]]; then
		break
    elif [[ "$CONFIRM" == "N" ]] || [[ "$CONFIRM" == "n" ]] || [[ "$CONFIRM" == "NO" ]] || [[ "$CONFIRM" == "no" ]] || [[ "$CONFIRM" == "No" ]]; then
	    clear
        exit
    else
	    echo "Invalid choice - try again please. Enter 'Yy' or 'Nn'."
	    echo
    fi
done
}