# WordPress Reference

WP-CLI is pre-installed in the container. Run commands with:

```sh
docker exec -it <container-name> wp <command>
```

To find your container name:

```sh
docker ps --filter "name=once-app" --format '{{.Names}}'
```

## Database

**Export a database backup:**

```sh
docker exec -it <container> wp db export /storage/db/manual-backup.sql
```

**Import a database backup:**

```sh
docker exec -it <container> wp db import /storage/db/manual-backup.sql
```

**Open a MySQL shell:**

```sh
docker exec -it <container> wp db cli
```

**Run a raw SQL query:**

```sh
docker exec -it <container> wp db query "SELECT * FROM wp_users;"
```

**Search and replace (useful after domain changes):**

```sh
docker exec -it <container> wp search-replace 'old-domain.com' 'new-domain.com'
```

## Users

**List users:**

```sh
docker exec -it <container> wp user list
```

**Create an admin user:**

```sh
docker exec -it <container> wp user create alice alice@example.com --role=administrator
```

**Reset a password:**

```sh
docker exec -it <container> wp user update 1 --user_pass=newpassword
```

## Plugins

**List installed plugins:**

```sh
docker exec -it <container> wp plugin list
```

**Install and activate a plugin:**

```sh
docker exec -it <container> wp plugin install wordpress-seo --activate
```

**Deactivate a plugin:**

```sh
docker exec -it <container> wp plugin deactivate wordpress-seo
```

**Update all plugins:**

```sh
docker exec -it <container> wp plugin update --all
```

## Themes

**List themes:**

```sh
docker exec -it <container> wp theme list
```

**Install and activate a theme:**

```sh
docker exec -it <container> wp theme install flavor --activate
```

## Core

**Check WordPress version:**

```sh
docker exec -it <container> wp core version
```

**Update WordPress core:**

```sh
docker exec -it <container> wp core update
```

**Verify file integrity:**

```sh
docker exec -it <container> wp core verify-checksums
```

## Maintenance

**Flush all caches:**

```sh
docker exec -it <container> wp cache flush
```

**Flush rewrite rules:**

```sh
docker exec -it <container> wp rewrite flush
```

**Run cron events manually:**

```sh
docker exec -it <container> wp cron event run --all
```

**Optimize the database:**

```sh
docker exec -it <container> wp db optimize
```
