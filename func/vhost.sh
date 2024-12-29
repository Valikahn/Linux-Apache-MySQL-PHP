###################################################
##                                               ##
##  VHOST CONFIGURATION                          ##
##                                               ##
###################################################

clear
unset $DOMAIN

###--------------------  VHOST CREATION  --------------------###
##
read -p "How many vHosts would you like to create? " QTY_DOMAINS
for ((v=1; v<=QTY_DOMAINS; v++)); do
    clear
    read -p "Enter the name for vHost $v (e.g., hello_world.local): " DOMAIN
    if ! mkdir -p /var/www/public_html/$DOMAIN/cms; then
        echo "Failed to create directory for $DOMAIN"
        continue
    fi
    echo

cat <<EOL >/etc/apache2/sites-available/$DOMAIN.conf
<VirtualHost *:80>
    ServerAdmin webmaster@$DOMAIN
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    DocumentRoot /var/www/public_html/$DOMAIN

    <Directory /var/www/public_html/$DOMAIN>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/${VHOST_NAME}_error.log
    CustomLog \${APACHE_LOG_DIR}/${VHOST_NAME}_access.log combined
</VirtualHost>
EOL

a2enmod ssl
a2ensite $DOMAIN.conf

cp -r web/* /var/www/public_html/$DOMAIN

if ! cp /var/www/html/conf/php.ini /var/www/public_html/$DOMAIN/cms/; then
    echo "Failed to copy php.ini for $DOMAIN"
fi

if ! cp /var/www/html/conf/.htaccess /var/www/public_html/$DOMAIN/cms/; then
    echo "Failed to copy .htaccess for $DOMAIN"
fi

INSTALL_LETS_ENCRYPT_SSL

done

chown -R www-data:www-data /var/www/public_html
chmod -R 775 /var/www/public_html

if systemctl reload apache2; then
    echo "Apache reloaded successfully."
else
    echo "Failed to reload Apache."
    sleep 5
fi

