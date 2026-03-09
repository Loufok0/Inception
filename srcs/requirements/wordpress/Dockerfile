FROM debian:12

RUN apt update -y && apt install -y wget curl php php-fpm php-mysql php-gd php-mbstring php-xml php-curl php-zip php-bcmath mariadb-client

RUN mkdir -p /run/php

# Install WordPress
RUN wget https://wordpress.org/wordpress-6.9.1.tar.gz -P /var/www \
	&& tar -xzf /var/www/wordpress-6.9.1.tar.gz -C /var/www/ \
	&& rm /var/www/wordpress-6.9.1.tar.gz

# install cli for wp conf
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Set permissions
RUN chown -R www-data:www-data /var/www/wordpress
RUN chown -R www-data:www-data /var/www/wordpress/wp-content

# Copy configs
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY conf/wp-config.php /var/www/wordpress/wp-config.php

# core setup
COPY tools/wp-conf.sh /tmp/wp-conf.sh
RUN chmod +x /tmp/wp-conf.sh

EXPOSE 9000
ENTRYPOINT ["sh", "/tmp/wp-conf.sh"]
