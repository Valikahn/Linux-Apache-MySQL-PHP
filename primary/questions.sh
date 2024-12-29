###################################################
##												 ##
##  SYSTEM CHECK								 ##
##												 ##
###################################################


###--------------------  USERNAME  --------------------###
##
clear
while true; do
    read -p "Enter username: " USERNAME
    echo "You entered: $USERNAME"

    while true; do
        read -p "Is this correct? (Y/N): " CONFIRM
        
        case "$CONFIRM" in
            [Yy]) 
				echo "Next steps will continue with username: $USERNAME"
				sleep 5
                break 2
                ;;
            [Nn]) 
                echo "Let's try again."
                break
                ;;
            *) 
                echo "Invalid response. Please enter Y or N."
                ;;
        esac
    done
done

###--------------------  DOMAIN NAME  --------------------###
##
clear
while true; do
    read -p "Enter the domain name for SSL (e.g., example.com): " DOMAINAME
    DOMAINAME=$DOMAIN
    FQDN=$DOMAIN

    echo "DOMAIN entered: $DOMAIN"
    echo "FQDN entered: $FQDN"

    while true; do
        read -p "Is this correct? (Y/N): " CONFIRM
        
        case "$CONFIRM" in
            [Yy]) 
				echo "Next steps will continue with domain: $DOMAIN"
				sleep 5
                break 2
                ;;
            [Nn]) 
                echo "Let's try again."
                break
                ;;
            *) 
                echo "Invalid response. Please enter Y or N."
                ;;
        esac
    done
done

###--------------------  EMAIL ADDRESS  --------------------###
##
clear
while true; do
    read -p "Enter your email address for Let's Encrypt notifications: " EMAIL
    echo "You entered: $EMAIL"

    while true; do
        read -p "Is this correct? (Y/N): " CONFIRM
        
        case "$CONFIRM" in
            [Yy]) 
				echo "Next steps will continue with email: $EMAIL"
				sleep 5
                break 2
                ;;
            [Nn]) 
                echo "Let's try again."
                break
                ;;
            *) 
                echo "Invalid response. Please enter Y or N."
                ;;
        esac
    done
done

###--------------------  VHOST INFORMAION GATHERING  --------------------###
##
clear
read -p "Are you going to be deploying vHosts? (Yy/Nn): " VHOST_ANSWER
if [[ "$VHOST_ANSWER" == "Y" ]] || [[ "$VHOST_ANSWER" == "y" ]] || [[ "$VHOST_ANSWER" == "YES" ]] || [[ "$VHOST_ANSWER" == "yes" ]] || [[ "$VHOST_ANSWER" == "Yes" ]]; then
		VHOST_ANSWER=1
        echo "You will be prompted later for more input for the vHost configuration..."
        sleep 5
		break
	elif [[ "$VHOST_ANSWER" == "N" ]] || [[ "$VHOST_ANSWER" == "n" ]] || [[ "$VHOST_ANSWER" == "NO" ]] || [[ "$VHOST_ANSWER" == "no" ]] || [[ "$VHOST_ANSWER" == "No" ]]; then
        VHOST_ANSWER=0
	    break
    else
	    echo "Invalid choice - try again please. Enter 'Yy' or 'Nn'."
	    echo
    fi