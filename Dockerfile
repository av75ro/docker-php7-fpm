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



EXPOSE 9000
CMD ["/bin/bash"]