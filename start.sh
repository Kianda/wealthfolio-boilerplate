#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [ ! -f .env ]; then
  echo "Error: .env file not found."
  echo "  Copy .env.example to .env and fill in the placeholder values."
  echo "  Example: cp .env.example .env && \${EDITOR:-vi} .env"
  exit 1
fi

mkdir -p data

docker compose up -d

echo
echo "Wealthfolio is starting. Once the healthcheck passes it will be available at:"
echo "  http://localhost:24568"
echo
echo "Status:   docker compose ps"
echo "Logs:     docker compose logs -f wealthfolio"
echo "Stop:     ./stop.sh"
