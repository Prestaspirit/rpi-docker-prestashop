#!/bin/bash

NORMAL="\\033[0;39m"
RED="\\033[1;31m"
BLUE="\\033[1;34;40m"
YELLOW="\\033[1;33;33m"
GREEN="\\033[1;32m"

FLAG="/tmp/installed"

#Enviornment variables to configure php
MYSQL_DIR="/var/lib/mysql"
PHP_PS_PATH_DIR="/var/www/html"

#Enviornment variables to configure prestashop
PS_VERSION="1.6.1.1"
PS_DOMAIN="presta.dev"
DB_SERVER="127.0.0.1"
DB_NAME="prestashop"
DB_USER="admin"
DB_PASSWD="prestashop"
ADMIN_MAIL="demo@prestashop.com"
ADMIN_PASSWD="prestashop_demo"
PS_LANGUAGE="fr"
PS_COUNTRY="fr"
PS_INSTALL_AUTO=0
PS_DEV_MODE=0
PS_HOST_MODE=0
PS_HANDLE_DYNAMIC_DOMAIN=0

# permissions
if [ "$(whoami)" != "root" ]; then
    echo -e "$RED Root privileges are required to run this, try running with sudo... $NORMAL"
    exit 2
fi

# Allready!!
if [ ! -f $FLAG ]; then

    # Configure vhost
    echo -e "$BLUE[Step 1] Configure vhost $NORMAL"
    read -e -i "$PS_DOMAIN" -p "Please enter your domain : " input_1
    PS_DOMAIN="${input_1:-$PS_DOMAIN}"
    echo "---> Add ServerName in apache2 conf"
    echo "ServerName localhost" >> /etc/apache2/apache2.conf
    echo "---> Create logs folder"
    rm -fr ${PHP_PS_PATH_DIR}/*
    mkdir -vp /var/www/html/logs/apache2/${PS_DOMAIN}
    echo " ---> Copy vhost file"
    cp -v /tmp/apache_default.conf /etc/apache2/sites-available/000-default.conf
    echo " ---> Configure vhost file"
    sed -i "s/%%DOMAIN%%/${PS_DOMAIN}/g" /etc/apache2/sites-available/000-default.conf
    echo -e "${GREEN}Done configure vhost! $NORMAL"

    # Configure database
    echo -e "$BLUE[Step 2] Configure database $NORMAL"
    if [[ ! -d $MYSQL_DIR/mysql ]]; then
        echo " ---> Install database"
        mysql_install_db > /dev/null 2>&1
        /usr/bin/mysqld_safe > /dev/null 2>&1 &

        RET=1
        while [[ RET -ne 0 ]]; do
            echo " ---> Waiting for confirmation of MySQL service startup"
            sleep 5
            mysql -uroot -e "status" > /dev/null 2>&1
            RET=$?
        done

        read -e -i "$DB_USER" -p "Please enter your db user : " input_2
        read -e -i "$DB_NAME" -p "Please enter your db name : " input_3
        read -e -i "$DB_SERVER" -p "Please enter your db host : " input_4
        DB_PASSWD=$(pwgen -s 12 1)
        DB_USER="${input_2:-$DB_USER}"
        DB_NAME="${input_3:-$DB_NAME}"
        DB_SERVER="${input_4:-$DB_SERVER}"
        echo " ---> Creating MySQL ${DB_USER} user on ${DB_USER}@${DB_SERVER} with ${DB_PASSWD} password"

        mysql -uroot -e "CREATE USER '$DB_USER'@'$DB_SERVER' IDENTIFIED BY '$DB_PASSWD'"
        mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'$DB_SERVER' WITH GRANT OPTION"
        mysql -uroot -e "CREATE DATABASE IF NOT EXISTS $DB_NAME"

        echo -e "${GREEN}Done configure database! $NORMAL"
    fi

    # Configure adminer
    echo -e "$BLUE[Step 3] Configure adminer $NORMAL"
    wget https://www.adminer.org/static/download/4.2.2/adminer-4.2.2-mysql.php -P ${PHP_PS_PATH_DIR}/pma
    mv ${PHP_PS_PATH_DIR}/pma/adminer-4.2.2-mysql.php ${PHP_PS_PATH_DIR}/pma/index.php
    echo -e "${GREEN}Done configure adminer! $NORMAL"

    # Configure prestashop
    echo -e "$BLUE[Step 4] Configure prestashop $NORMAL"
    read -e -i "$PS_VERSION" -p "Please enter your Prestashop version : " input_5
    PS_VERSION="${input_5:-$PS_VERSION}"
    echo " ---> Download prestashop V${PS_VERSION}"
    wget http://www.prestashop.com/download/prestashop_${PS_VERSION}.zip -P ${PHP_PS_PATH_DIR}
    unzip ${PHP_PS_PATH_DIR}/prestashop_${PS_VERSION}.zip -d ${PHP_PS_PATH_DIR}
    cp -pRv ${PHP_PS_PATH_DIR}/prestashop/* ${PHP_PS_PATH_DIR}
    rm -rf ${PHP_PS_PATH_DIR}/prestashop_$PS_VERSION.zip ${PHP_PS_PATH_DIR}/Install_PrestaShop.html ${PHP_PS_PATH_DIR}/prestashop
    chown www-data:www-data -R ${PHP_PS_PATH_DIR}/
    php ${PHP_PS_PATH_DIR}/install/index_cli.php --domain=$PS_DOMAIN --db_server=$DB_SERVER --db_name="$DB_NAME" --db_user=$DB_USER --db_password=$DB_PASSWD --language=$PS_LANGUAGE --country=$PS_COUNTRY --name=$PS_DOMAIN --firstname="Docker" --lastname="Prestashop" --password=$ADMIN_PASSWD --email="$ADMIN_MAIL" --newsletter=0 --send_email=0
    mv ${PHP_PS_PATH_DIR}/admin ${PHP_PS_PATH_DIR}/admin_docker
    mv ${PHP_PS_PATH_DIR}/install ${PHP_PS_PATH_DIR}/__install__
    echo -e "${GREEN}Done configure prestashop! $NORMAL"

    echo ""
    echo ""
    echo ""
    echo ""
    echo -e "$YELLOW## PRESTASHOP V${PS_VERSION} CONFIGURATION $NORMAL"
    echo -e "$YELLOW## ============================================================================== $NORMAL"
    echo -e "$YELLOW## Domain           = $PS_DOMAIN $NORMAL"
    echo -e "$YELLOW## Shop name        = $PS_DOMAIN $NORMAL"
    echo -e "$YELLOW## Admin folder     = admin_docker $NORMAL"
    echo -e "$YELLOW## Admin email      = $ADMIN_MAIL $NORMAL"
    echo -e "$YELLOW## Admin password   = $ADMIN_PASSWD $NORMAL"
    echo -e "$YELLOW## Language         = $PS_LANGUAGE $NORMAL"
    echo -e "$YELLOW## Country          = $PS_COUNTRY $NORMAL"
    echo -e "$YELLOW##  $NORMAL"
    echo -e "$YELLOW## DATABASE INFOS $NORMAL"
    echo -e "$YELLOW## -------------- $NORMAL"
    echo -e "$YELLOW## Db host          = $DB_SERVER $NORMAL"
    echo -e "$YELLOW## Db name          = $DB_NAME $NORMAL"
    echo -e "$YELLOW## Db user          = $DB_USER $NORMAL"
    echo -e "$YELLOW## Db pass          = $DB_PASSWD $NORMAL"
    echo -e ""
    echo -e "$YELLOW## You can access the database using the following URL : http://$PS_DOMAIN/pma  $NORMAL"
    echo -e "$YELLOW## ============================================================================== $NORMAL"
    echo ""
    echo ""
    echo ""
    echo ""
    echo -e "${GREEN}Run this command line to start container : docker start prestadev $NORMAL"

    mysqladmin -uroot shutdown
    touch $FLAG
    exit 1
else
    exec supervisord -n
fi