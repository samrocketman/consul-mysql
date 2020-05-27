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

# Run a client external to the container

```bash
./mysql-client.sh
```

If you pass additional options to `mysql-client.sh`, then they will be passed
directly to mysql.  If the last argument you pass is a database, then the
database will automatically be selected upon connection.

# License

[MIT License](LICENSE)
