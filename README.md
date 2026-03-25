# WordPress for Once

Run WordPress on your own server with [Once](https://once.com). One container, no subscriptions.

This packages WordPress with MariaDB, WP-CLI, and automatic SMTP configuration into a single Docker image that meets Once's requirements.

## Install Once

```sh
curl https://get.once.com | sh
```

This installs the Once CLI and launches the setup dashboard.

## Deploy WordPress

```sh
once deploy ghcr.io/hallmatt/once_wordpress --host yourdomain.com
```

Image: `ghcr.io/hallmatt/once_wordpress`

That's it. Once will:

1. Pull the image
2. Start the container with persistent storage at `/storage`
3. Set up TLS via its built-in reverse proxy
4. Verify the `/up` healthcheck

Visit your domain to complete the WordPress setup wizard.

## Configure email

Press `s` in the Once dashboard to configure SMTP settings. WordPress will automatically pick up the credentials — no plugin needed.

## Backups

Once handles backups automatically via the background service. You can also run manual backups:

```sh
once backup wordpress backup-2024-01-15.tar
```

This triggers a database dump (via the `pre-backup` hook) before archiving everything in `/storage`.

To restore:

```sh
once restore backup-2024-01-15.tar
```

## Updates

To deploy a new version of the image:

```sh
once deploy ghcr.io/hallmatt/once_wordpress --host yourdomain.com
```

Once also supports automatic image updates via its background service.

## Stop / start / remove

```sh
once stop wordpress
once start wordpress
once remove wordpress              # keeps data
once remove wordpress --remove-data # deletes everything
```

## Storage layout

All persistent data lives in `/storage`:

```
/storage/
├── wordpress/          # WordPress core + wp-content (auto-updates in place)
│   ├── wp-admin/
│   ├── wp-includes/
│   └── wp-content/
│       ├── themes/
│       ├── plugins/
│       ├── uploads/
│       └── mu-plugins/
├── db/
│   ├── mysql/          # MariaDB data files
│   └── database.sql    # backup dump (created by pre-backup hook)
└── config/
    ├── wp-config.php   # generated on first run
    └── .db_password    # MariaDB credentials
```

## See also

- [wordpress.md](wordpress.md) — WP-CLI commands and WordPress admin reference
