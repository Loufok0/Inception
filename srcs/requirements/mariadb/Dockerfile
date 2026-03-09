FROM debian:12

RUN apt update -y && apt install -y mariadb-server vim curl # vim and curl optional

# mariadb conf dir
RUN mkdir -p /var/run/mariadb

# mariadb conf copy
COPY conf/50-server.cnf	/etc/mysql/mariadb.conf.d/50-server.cnf

# mariadb setup
COPY tools/mariadb-setup.sh /tmp/mariadb-setup.sh
RUN chmod +x /tmp/mariadb-setup.sh

EXPOSE 3306

#run mariadb
ENTRYPOINT [ "/tmp/mariadb-setup.sh" ]

