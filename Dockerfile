FROM resin/rpi-raspbian:latest

MAINTAINER Franck Pichard <web-dev@live.fr>

# ENVIORNMENT VARIABLES TO CONFIGURE PHP
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

# INSTALL LIBS
RUN apt-get update \
	&& apt-get install -y libmcrypt-dev \
		libgd2-xpm-dev \
		libjpeg62-turbo-dev \
		libpng12-dev \
		libfreetype6-dev \
		libxml2-dev \
		mysql-client \
		mysql-server \
		wget \
		unzip \
		git \
		supervisor \
		apache2 \
		libapache2-mod-php5 \
		php5-mysql \
		pwgen \
		php-apc \
		php5-gd \
		php5-mcrypt \
		php5-memcache \
		php5-cli \
		htop \
		nano

# REMOVE PRE-INSTALLED DATABASE
RUN rm -rf /var/lib/mysql/*

# ADD CONFIGURATION AND SCRIPTS
ADD conf/apache_default.conf /tmp/apache_default.conf
ADD conf/start-apache2.sh /tmp/start-apache2.sh
ADD conf/start-mysqld.sh /tmp/start-mysqld.sh
ADD conf/run.sh /tmp/run.sh
RUN chmod +x /tmp/*.sh

ADD conf/my.cnf /etc/mysql/conf.d/my.cnf
ADD conf/php.ini /etc/php5/apache2/php.ini
ADD conf/supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD conf/supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# CONFIG APACHE2
RUN a2enmod rewrite

# ADD VOLUMES
VOLUME  ["/etc/mysql", "/var/lib/mysql", "/var/www/html"]

# OPEN PORTS
EXPOSE 80 3306

CMD ["/tmp/run.sh"]