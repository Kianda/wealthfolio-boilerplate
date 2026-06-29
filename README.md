# Wealthfolio Boilerplate

Docker setup for running a self-hosted [Wealthfolio](https://github.com/wealthfolio/wealthfolio)
instance using the official `wealthfolio/wealthfolio:latest` image.

Unlike Ghostfolio (3 containers: app + Postgres + Redis), Wealthfolio is a
**single Rust container** with **embedded SQLite**: trivial backups (one file
`data/wealthfolio.db`) and a very small footprint (~150 MB RAM, < 200 MB image).

## Requirements

- Docker Engine >= 20.10
- Docker Compose v2 (plugin `docker compose`)

## Quickstart

```bash
cp .env.example .env
# Generate the secrets key and replace <INSERT_BASE64_32_BYTES>:
#   openssl rand -base64 32
./start.sh
```

Once the healthcheck passes, open http://localhost:24568.

### Variables in `.env`

| Variable                | Description                                         | Default                  |
|-------------------------|-----------------------------------------------------|--------------------------|
| `WF_LISTEN_ADDR`        | Address:port the process listens on (inside container) | `0.0.0.0:8088`        |
| `WF_DB_PATH`            | SQLite database path (inside container)             | `/data/wealthfolio.db`   |
| `WF_SECRET_KEY`         | 32-byte base64 key for secrets encryption and JWT   | (required)               |
| `WF_AUTH_PASSWORD_HASH` | Argon2id PHC string, enables password auth on the web UI | (disabled)          |

To enable a password on the web UI, generate an Argon2id hash and set it in
`WF_AUTH_PASSWORD_HASH`:

```bash
printf 'your-password' | argon2 yoursalt16chars! -id -e
```

Copy the full output (starts with `$argon2id$...`). Inside `.env` the `$`
characters are not interpolated by Compose when the line is unquoted, so paste
it as-is (wrapped in single quotes as shown in the example).

## Useful commands

```bash
docker compose ps                       # Container status
docker compose logs -f wealthfolio      # App logs
./stop.sh                               # Stop everything
docker compose pull && ./start.sh       # Update to the latest image
```

## Persistent data

- The DB is a single file `./data/wealthfolio.db` (bind mount).
- Encrypted secrets are in `./data/secrets.json` (key: `WF_SECRET_KEY`).

### Backup

With the container stopped (for DB consistency):

```bash
./stop.sh
tar czf wealthfolio-backup-$(date +%F).tar.gz data/
./start.sh
```

Or online via the SQLite `.backup` command (preferred for large DBs):

```bash
docker compose exec wealthfolio sqlite3 /data/wealthfolio.db ".backup /data/backup.db"
cp data/backup.db wealthfolio-$(date +%F).db
rm data/backup.db
```

### Full reset (deletes the database)

```bash
./stop.sh
rm -f data/wealthfolio.db data/secrets.json
./start.sh
```

> **Permissions note:** if `data/*.db` files are owned by a different user
> than the host (container UID), you may need `sudo rm`.

## Importing broker data

To convert a broker CSV export (e.g. Directa) into Wealthfolio's
"Import Activities" format and optionally push via API, see the companion
repo [`wealthfolio-importer-gui`](https://github.com/Kianda/wealthfolio-importer-gui).
