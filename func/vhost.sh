###################################################
##                                               ##
##  VHOST CONFIGURATION                          ##
##                                               ##
###################################################

clear

###--------------------  VHOST CREATION  --------------------###
##
read -p "How many vHosts would you like to create? " QTY_VHOSTS
for ((v=1; v<=QTY_VHOSTS; v++)); do
    clear
    read -p "Enter the name for vHost $v (e.g., hello_world.local): " VHOST_NAME
    if ! mkdir -p /var/www/public_html/$VHOST_NAME/cms; then
        echo "Failed to create directory for $VHOST_NAME"
        continue
    fi
    echo

cat <<EOL >/etc/apache2/sites-available/$VHOST_NAME.conf
<VirtualHost *:80>
    ServerAdmin webmaster@$VHOST_NAME
    ServerName $VHOST_NAME
    ServerAlias www.$VHOST_NAME
    DocumentRoot /var/www/public_html/$VHOST_NAME

    <Directory /var/www/public_html/$VHOST_NAME>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/${VHOST_NAME}_error.log
    CustomLog \${APACHE_LOG_DIR}/${VHOST_NAME}_access.log combined
</VirtualHost>

<VirtualHost *:443>
    ServerAdmin webmaster@$VHOST_NAME
    ServerName $VHOST_NAME
    ServerAlias www.$VHOST_NAME
    DocumentRoot /var/www/public_html/$VHOST_NAME

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
    SSLCertificateChainFile /etc/ssl/certs/dhparam.pem

    <Directory /var/www/public_html/$VHOST_NAME>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/${VHOST_NAME}_ssl_error.log
    CustomLog \${APACHE_LOG_DIR}/${VHOST_NAME}_ssl_access.log combined
</VirtualHost>
EOL

a2enmod ssl
a2ensite $VHOST_NAME.conf

cp -r web/* /var/www/public_html/$VHOST_NAME

if ! cp /var/www/html/conf/php.ini /var/www/public_html/$VHOST_NAME/cms/; then
    echo "Failed to copy php.ini for $VHOST_NAME"
fi

if ! cp /var/www/html/conf/.htaccess /var/www/public_html/$VHOST_NAME/cms/; then
    echo "Failed to copy .htaccess for $VHOST_NAME"
fi

done

chown -R www-data:www-data /var/www/public_html
chmod -R 775 /var/www/public_html

if systemctl reload apache2; then
    echo "Apache reloaded successfully."
else
    echo "Failed to reload Apache."
    COUNTDOWN 5
fi