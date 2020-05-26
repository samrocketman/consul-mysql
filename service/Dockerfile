FROM ubuntu:20.04

RUN set -ex; \
apt-get update; \
apt-get install -y curl mariadb-client mariadb-server; \
apt-get clean; \
rm -rf '/tmp/'* /var/lib/mysql


# install init process for handling shutdown
RUN set -ex; \
curl -Lo /bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64; \
echo '37f2c1f0372a45554f1b89924fbb134fc24c3756efaedf11e07f599494e0eff9  /bin/dumb-init' | \
sha256sum -c -; \
chmod 755 /bin/dumb-init

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

EXPOSE 3306

COPY run_mysql.sh /

CMD /run_mysql.sh
