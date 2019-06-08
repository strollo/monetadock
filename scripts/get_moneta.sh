#!/bin/bash

function INFO {
    echo "$(date +"%y%m%d %H:%M:%S") [Info] - $@"
}

MONETA_INI=/scripts/moneta.ini

function initMoneta {
    MONETA_ROOT_DIR=/var/www/moneta

    INFO "Installing moneta webapp"
    wget -q -c -nd https://github.com/strollo/moneta/archive/v1.0.2.zip -O /tmp/moneta.zip
    unzip /tmp/moneta.zip -d /var/www/  &> /dev/null
    rm /tmp/moneta.zip
    mv /var/www/moneta-1.0.2 $MONETA_ROOT_DIR
    mv $MONETA_INI $MONETA_ROOT_DIR/config/.
    
    INFO "Fixing permissions"
    chown www-data.www-data /var/www -R
    ln -sf $MONETA_ROOT_DIR  /var/www/html/.
}

initMoneta