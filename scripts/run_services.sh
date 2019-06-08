#!/bin/bash

function INFO {
    echo "$(date +"%y%m%d %H:%M:%S") [Info] - $@"
}

./init_mysql.sh

INFO "*** Starting all services..."
INFO "Starting MySQL"
/etc/init.d/mysql start
INFO "Starting Apache Web Server"
/etc/init.d/apache2 start

INFO "all services started"
INFO "Starting SSH Server"
/usr/sbin/dropbear -F

