#!/bin/bash
source ~/git/github/docker-compose-ha-consul-vault-ui/scripts/vault-functions.sh
set -e
echo 'Get credentials from Vault.'
set_vault_infra_token
mysql_user="$(execute_vault_command vault kv get -field=user docker/mysql-admin)"
mysql_password="$(execute_vault_command vault kv get -field=password docker/mysql-admin)"
export mysql_user mysql_password
revoke_self
IMAGE="$(docker-compose images -q mysql)"
docker run -it --rm --network docker-compose-ha-consul-vault-ui_internal \
  --dns 172.16.238.2 \
  --dns 172.16.238.3 \
  -e mysql_user -e mysql_password \
  "${IMAGE}" \
  mysql -P3306 -h mysql.service.consul -u "${mysql_user}" -p"${mysql_password}" "$@"
