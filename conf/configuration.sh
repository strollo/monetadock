#!/bin/bash

CONF_USER_ROOT_PWD=${USER_ROOT_PWD:-"root"}
CONF_MYSQL_ROOT_PWD=${MYSQL_ROOT_PWD:-"mysql"}
CONF_MYSQL_USER=${MYSQL_USER:-"moneta"}
CONF_MYSQL_USER_PWD=${MYSQL_USER_PWD:-"m0n3t@pwd"}
CONF_MYSQL_USER_DB=${MYSQL_USER_DB:-"moneta"}



# parameters
export CONF_USER_ROOT_PWD
export CONF_MYSQL_ROOT_PWD
export CONF_MYSQL_USER
export CONF_MYSQL_USER_PWD
export CONF_MYSQL_USER_DB