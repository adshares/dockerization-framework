FROM ubuntu:16.04

ENV TERM xterm
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV TZ=Europe/Warsaw

RUN apt-get update -y
RUN apt-get install -y apt-utils
RUN apt-get upgrade -y

RUN apt-get install -y apt-utils

RUN apt-get install -y libreadline6 libreadline6-dev libterm-readline-gnu-perl

RUN apt-get install -y software-properties-common curl wget locales

RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update -y
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get install -y php7.2-fpm php7.2-bcmath php7.2-curl php7.2-gd php7.2-gmp php7.2-intl php7.2-json php7.2-mysql php7.2-opcache php7.2-readline php7.2-xml php7.2-zip

WORKDIR /root

RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer

RUN apt-get install -y nginx git

COPY local.docker.site.nginx.conf /etc/nginx/conf.d/default.conf
RUN rm  /etc/nginx/sites-enabled/default
COPY ./docker /docker

WORKDIR /root
RUN git clone https://github.com/benkeen/generatedata.git
RUN mv generatedata /www
RUN mv /docker/settings.php /www/
WORKDIR /www
RUN chmod -R a+rw cache

ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]
