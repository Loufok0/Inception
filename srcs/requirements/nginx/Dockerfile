FROM debian:12

RUN apt update -y && apt install -y nginx openssl vim curl # vim and curl optional

# ssl key and certificate dir
RUN mkdir -p /etc/nginx/ssl

# certificates |type |no pswd| certificate location        | ssl key location                       | pre fill infos
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=CH/ST=VD/L=Lausanne/O=42/OU=42/CN=malapoug.42.fr/UID=malapoug"

# nginx conf dir
RUN mkdir -p /var/run/nginx
	
COPY conf/nginx.conf /etc/nginx/nginx.conf
RUN chmod 755 /var/www/html
RUN chown -R www-data:www-data /var/www/html

EXPOSE 443

#run nginx
ENTRYPOINT [ "nginx", "-g", "daemon off;" ]
