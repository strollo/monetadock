FROM ubuntu:14.04

MAINTAINER strollo <daniele.strollo@gmail.com>

RUN apt-get update -y

############################################################
# 1 - INSTALL REQUIRED PACKAGES
#       APACHE2/MYSQL/PHP5.5/SSHD
############################################################
RUN apt-get install -y \
    apache2 apache2-bin apache2-data apache2-utils \
    libapache2-mod-php5 php5-cgi php5-common php5-json \
    mysql-server-5.5 php5-mysql
    
RUN apt-get install -y \
    unzip wget zile dropbear dos2unix

############################################################
# 2 - CUSTOM VARIABLES - USER&MYSQL CREDENTIALS
# IF YOU WANT TO OVERRIDE DEFAULT VALUES 
############################################################
ENV USER_ROOT_PWD=
ENV MYSQL_ROOT_PWD=
ENV MYSQL_USER=
ENV MYSQL_USER_PWD=
ENV MYSQL_USER_DB=
############################################################


############################################################
# 4 - Remove apt cache to make the image smaller
############################################################
RUN rm -rf /var/lib/apt/lists/*
# FIRST INSTALL RESET MYSQL Data files
RUN rm -fr /var/lib/mysql/mysql

############################################################
# 5 - INITIALIZE ENVIRONMENT
############################################################
WORKDIR /scripts

COPY ./conf/configuration.sh /scripts/configuration.sh
RUN dos2unix /scripts/configuration.sh && chmod +x /scripts/configuration.sh
COPY ./scripts/init_mysql.sh /scripts/init_mysql.sh
RUN dos2unix /scripts/init_mysql.sh && chmod +x /scripts/init_mysql.sh
# Initialized DBMS
RUN /scripts/init_mysql.sh

COPY ./scripts/get_moneta.sh /scripts/get_moneta.sh
RUN dos2unix /scripts/get_moneta.sh && chmod +x /scripts/get_moneta.sh
RUN /scripts/get_moneta.sh

COPY ./scripts/run_services.sh /scripts/run_services.sh
RUN dos2unix /scripts/run_services.sh && chmod +x /scripts/run_services.sh

############################################################
# - PORTS AND VOLUMES
############################################################
VOLUME ["/var/lib/mysql"]
EXPOSE 22 80 443 3306

############################################################
# 6 - START CONTAINER
############################################################
CMD ["/scripts/run_services.sh"]


