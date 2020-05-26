# Consul MySQL

This demo shows an example of MySQL using consul for service discovery.

This is a companion project for
https://github.com/samrocketman/docker-compose-ha-consul-vault-ui

This assumes you have cloned this repository and
docker-compose-ha-consul-vault-ui to `${HOME}/git/github`.

docker-compose-ha-consul-vault-ui must be started before this project and be
healthy.

# Connection

    mysql.service.consul:3306

# License

[MIT License](LICENSE)
