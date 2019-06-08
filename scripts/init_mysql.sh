#!/bin/bash

function INFO {
    echo "$(date +"%y%m%d %H:%M:%S") [Info] - $@"
}

FIRST_INSTALL_MARK=/scripts/.docker_initialized
if [ -f "$FIRST_INSTALL_MARK" ]; then
    INFO "Service already initialized... exiting"
    exit 0
else
    rm -fr /var/lib/mysql/mysql
    INFO "Initilizing MySQL credentials for the first install"
    touch $FIRST_INSTALL_MARK
fi

###########################################################
# Include Configuration file (can be customized by user)
###########################################################
. /scripts/configuration.sh

CONF_FILE=/scripts/.conf.log
MONETA_INI=/scripts/moneta.ini

function createConfLog {
    echo "===================================================="       > $CONF_FILE
    echo "User root password:       ${CONF_USER_ROOT_PWD}"           >> $CONF_FILE
    echo "MySQL root password:      ${CONF_MYSQL_ROOT_PWD}"          >> $CONF_FILE
    echo "MySQL moneta DB user:     ${CONF_MYSQL_USER}"              >> $CONF_FILE
    echo "MySQL moneta DB password: ${CONF_MYSQL_USER_PWD}"          >> $CONF_FILE
    echo "MySQL moneta DB database: ${CONF_MYSQL_USER_DB}"           >> $CONF_FILE
    echo "===================================================="      >> $CONF_FILE
}

function initRootPwd {
    INFO "Setting root password"
    echo "root:${CONF_USER_ROOT_PWD}" | chpasswd
}

function printConfLog {
    INFO "User and Database created with the following credentials"
    cat $CONF_FILE
}

function createIniFile {
    INFO "Creating moneta conf file in ${MONETA_INI}"

    echo "[database]"                                                   > $MONETA_INI
    echo "db_type = \"mysql\""                                         >> $MONETA_INI
    echo "db_hostname = \"127.0.0.1\""                                 >> $MONETA_INI
    echo "db_port = \"3306\""                                          >> $MONETA_INI
    echo "db_name = \"${CONF_MYSQL_USER_DB}\""                         >> $MONETA_INI
    echo "db_username = \"${CONF_MYSQL_USER}\""                        >> $MONETA_INI
    echo "db_password = \"${CONF_MYSQL_USER_PWD}\""                    >> $MONETA_INI
}

function initMySQL {
    if [ ! -d "/run/mysqld" ]; then
        mkdir -p /run/mysqld
        chown -R mysql:mysql /run/mysqld
    fi

    if [ -d /var/lib/mysql/mysql ]; then
        INFO 'MySQL directory already present, skipping creation'
    else
        INFO "MySQL data directory not found, creating initial DBs"

        chown -R mysql:mysql /var/lib/mysql

        # init database
        echo 'Initializing database'
        mysql_install_db --user=mysql > /dev/null
        echo 'Database initialized'

        INFO "MySql root password: $CONF_MYSQL_ROOT_PWD"

        # create temp file
        tfile=`mktemp`
        if [ ! -f "$tfile" ]; then
            return 1
        fi

        # save sql
        cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user;
GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '$CONF_MYSQL_ROOT_PWD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$CONF_MYSQL_ROOT_PWD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$CONF_MYSQL_ROOT_PWD' WITH GRANT OPTION;
EOF

        # Create new database
        if [ "$CONF_MYSQL_USER_DB" != "" ]; then
            INFO "Creating database: $CONF_MYSQL_USER_DB"
            # echo "CREATE DATABASE IF NOT EXISTS \`$CONF_MYSQL_USER_DB\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile

            # set new User and Password
            if [ "$CONF_MYSQL_USER" != "" ] && [ "$CONF_MYSQL_USER_PWD" != "" ]; then
            INFO "Creating user: $CONF_MYSQL_USER with password $CONF_MYSQL_USER_PWD"
            echo "GRANT ALL ON *.* to '$CONF_MYSQL_USER'@'%' IDENTIFIED BY '$CONF_MYSQL_USER_PWD';" >> $tfile
            fi
        else
            # don`t need to create new database,Set new User to control all database.
            if [ "$CONF_MYSQL_USER" != "" ] && [ "$CONF_MYSQL_USER_PWD" != "" ]; then
            INFO "Creating user: $CONF_MYSQL_USER with password $CONF_MYSQL_USER_PWD"
            echo "GRANT ALL ON *.* to '$CONF_MYSQL_USER'@'%' IDENTIFIED BY '$CONF_MYSQL_USER_PWD';" >> $tfile
            fi
        fi

        echo 'FLUSH PRIVILEGES;' >> $tfile
        echo 'EXIT;' >> $tfile

        # run sql in tempfile
        INFO "Flushing permissions on MySQL"
        /usr/sbin/mysqld --user=mysql --bootstrap --verbose=0 < $tfile
        rm -f $tfile
    fi
}

initRootPwd
createConfLog
createIniFile
initMySQL
printConfLog

