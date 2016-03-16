FROM debian:jessie
MAINTAINER apostol victor
ENV LAST_UPDATED 2016-02-08
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y wget
RUN echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list.d/dotdeb.org.list && \
	echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list.d/dotdeb.org.list
RUN wget http://www.dotdeb.org/dotdeb.gpg
RUN apt-key add dotdeb.gpg

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y php7.0-fpm php7.0-cli php7.0-mysql php7.0-mcrypt php7.0-curl php7.0-gd


RUN sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/7.0/fpm/php.ini

#ADD www.conf /etc/php/7.0/fpm/pool.d/www.conf

RUN mkdir -p /run/php

RUN set -ex \
	&& cd /usr/local/etc \
	&& if [ -d php-fpm.d ]; then \
		# for some reason, upstream's php-fpm.conf.default has "include=NONE/etc/php-fpm.d/*.conf"
		sed 's!=NONE/!=!g' php-fpm.conf.default | tee php-fpm.conf > /dev/null; \
		cp php-fpm.d/www.conf.default php-fpm.d/www.conf; \
	else \
		# PHP 5.x don't use "include=" by default, so we'll create our own simple config that mimics PHP 7+ for consistency
		mkdir php-fpm.d; \
		cp php-fpm.conf.default php-fpm.d/www.conf; \
		{ \
			echo '[global]'; \
			echo 'include=etc/php-fpm.d/*.conf'; \
		} | tee php-fpm.conf; \
	fi \
	&& { \
		echo '[global]'; \
		echo 'error_log = /proc/self/fd/2'; \
		echo; \
		echo '[www]'; \
		echo '; if we send this to /proc/self/fd/1, it never appears'; \
		echo 'access.log = /proc/self/fd/2'; \
		echo; \
		echo 'clear_env = no'; \
		echo; \
		echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
		echo 'catch_workers_output = yes'; \
	} | tee php-fpm.d/docker.conf \
	&& { \
		echo '[global]'; \
		echo 'daemonize = no'; \
		echo; \
		echo '[www]'; \
		echo 'listen = [::]:9000'; \
	} | tee php-fpm.d/zz-docker.conf

EXPOSE 9000
CMD ["php-fpm7.0"]