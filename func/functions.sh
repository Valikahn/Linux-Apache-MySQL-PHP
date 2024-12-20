###################################################
##												 ##
##  MULTIPLE USE FUNCTIONS						 ##
##												 ##
###################################################


###--------------------  RANDOM PASSWORD GENERATOR  --------------------###
##
PASSGEN() {
local genln=$1
[ -z "$genln" ] && genln=21
## Without Special Characters
tr -dc A-Za-z0-9 < /dev/urandom | head -c ${genln} | xargs
## With Special Characters
## tr -dc 'A-Za-z0-9!@#$%^&*()_+-=[]{}|;:,.<>?' < /dev/urandom | head -c ${genln} | xargs
}

###--------------------  CREATE RANDOM PORT  --------------------###
##
CREATE_RANDOM_PORT() {
    $NEW_PORT=$nil
    while true; 
    do
      NEW_PORT=$((RANDOM % 64512 + 1024))
      if ! IS_PORT_IN_USE $NEW_PORT; then
        break
      fi
    done
}
