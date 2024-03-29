FROM php:7.2-fpm-alpine 

MAINTAINER JH <hopper.jerry@gmail.com> 

ENV WORKDIR "/var/www/app" 

COPY telegram /telegram
RUN chmod +x /telegram

#RUN wget https://raw.githubusercontent.com/fabianonline/telegram.sh/master/telegram
#RUN chmod +x ./telegram
#ADD telegram /root/telegram

RUN apk upgrade --update && apk --no-cache add \
    git autoconf tzdata openntpd libcurl curl-dev coreutils \
    libmcrypt-dev freetype-dev libxpm-dev libjpeg-turbo-dev libvpx-dev \
    libpng-dev libressl-dev libxml2-dev postgresql-dev icu-dev \
    nodejs npm yarn sshpass openssh-client

RUN apk add --no-cache --upgrade bash
RUN apk add --no-cache --virtual build-dependencies libxpm-dev libmcrypt-dev gmp-dev curl-dev postgresql-dev icu-dev libxml2-dev freetype-dev libpng-dev libjpeg-turbo-dev g++ make autoconf 


RUN docker-php-ext-configure intl \
    && docker-php-ext-configure opcache \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
    --with-xpm-dir=/usr/include/ 

RUN docker-php-ext-install -j$(nproc) gd iconv pdo pdo_mysql pdo_pgsql curl \
    bcmath mbstring json xml xmlrpc zip intl opcache gmp

# Add mcrypt
RUN yes '' | pecl install -f mcrypt 
RUN echo "extension=mcrypt.so" > /usr/local/etc/php/conf.d/mcrypt.ini

# Add timezone RUN rm /etc/localtime && \
#    ln -s /usr/share/zoneinfo/UTC /etc/localtime && \ "date" Install composer

RUN curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/local/bin --filename=composer

# Cleanup
RUN rm -rf /var/cache/apk/* \
    && find / -type f -iname \*.apk-new -delete \
    && rm -rf /var/cache/apk/* 

RUN mkdir -p ${WORKDIR} 

RUN chown www-data:www-data -R ${WORKDIR} 
WORKDIR ${WORKDIR} 
EXPOSE 9000 
CMD ["php-fpm"]
