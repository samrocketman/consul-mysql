#!/bin/bash

source /usr/local/share/vault-functions.sh

function upload_vault_creds() (
  set +x
  set_vault_addr
  set_vault_infra_token
  execute_vault_command \
    vault kv put docker/mysql-admin \
      user="$(< /mnt/mysql_admin_user)" \
      password="$(< /mnt/mysql_admin_password)"
  revoke_self
  echo 'Wrote vault credentials to docker/mysql-admin'
)

set -ex

function rand_password() {
  tr -dc -- '-;.~,.<>[]{}!@#$%^&*()_+=`0-9a-zA-Z' < /dev/urandom | head -c64;echo
}

function create_sql_admin() {
  echo 'Creating remote SQL Admin credentials.'
  ADMIN_USER=sqladmin
  ADMIN_PASSWORD="$(rand_password)"
  touch /mnt/mysql_admin_user /mnt/mysql_admin_password
  chmod 600 /mnt/mysql_admin_user /mnt/mysql_admin_password
  echo "${ADMIN_USER}" > /mnt/mysql_admin_user
  echo "${ADMIN_PASSWORD}" > /mnt/mysql_admin_password
  mysql -u root -p"$INITIAL_ROOT_PASSWORD" <<EOF
CREATE USER '${ADMIN_USER}'@'%' IDENTIFIED BY '${ADMIN_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${ADMIN_USER}'@'%' IDENTIFIED BY '${ADMIN_PASSWORD}';
EOF
  upload_vault_creds
}

# initialize database if not already initialized
if [ ! -d /var/lib/mysql/mysql ]; then
  set +x
  RAND_ROOT_PASSWORD="$(rand_password)"
  INITIAL_ROOT_PASSWORD="${INITIAL_ROOT_PASSWORD:-$RAND_ROOT_PASSWORD}"
  if [ "$INITIAL_ROOT_PASSWORD" = "$RAND_ROOT_PASSWORD" ]; then
    # save the initial root password since it was generated
    passfile=/mnt/mysql_root_pass
    touch "$passfile"
    chmod 600 "$passfile"
    echo "$INITIAL_ROOT_PASSWORD" > "$passfile"
    unset passfile
  fi
  echo 'Starting initial mysql daemon.'
  mysqld_safe --basedir=/usr &
  MYSQL_PID=$!
  echo 'Initializing /var/lib/mysql.'
  mysql_install_db
  until mysqladmin ping; do sleep 5; done
  echo 'Changing root password.'
  mysqladmin -u root password "$INITIAL_ROOT_PASSWORD"
  create_sql_admin
  echo 'Shutting down initial mysql daemon.'
  kill $(pgrep -P $MYSQL_PID)
  while pgrep -P $MYSQL_PID;do
    sleep 1
    echo 'Waiting for shutdown...'
  done
  echo 'Wrote passwords to:'
  ls -1 /mnt/mysql_* | sed 's/^/    /'
  set -x
fi

rm -f /var/log/mariadb/mariadb.log
mkdir -p /var/log/mariadb
mkfifo /var/log/mariadb/mariadb.log
chown mysql: /var/log/mariadb /var/log/mariadb/mariadb.log
/usr/bin/mysqld_safe --bind-address 0.0.0.0 --basedir=/usr &
MYSQL_PID=$!

trap "kill -SIGQUIT $MYSQL_PID" INT
tail -f /var/log/mariadb/mariadb.log
