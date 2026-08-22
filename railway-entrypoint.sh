#!/bin/sh
set -eu

log() { echo "[railway-entrypoint] $*"; }

# ---------------------------------------------------------------------------
# 1. Refuse to boot without an API key.
#
# Self-hosted Firecrawl has no authentication of its own: withAuth() returns a
# mock success whenever USE_DB_AUTHENTICATION is false, and true routes auth to
# a Supabase instance a Railway deploy does not have. The gateway key is the
# only thing standing between the public URL and the deployer's bill, so an
# empty one is a fatal misconfiguration rather than a warning.
# ---------------------------------------------------------------------------
if [ -z "${FIRECRAWL_API_KEY:-}" ]; then
  log "FATAL: FIRECRAWL_API_KEY is empty. Refusing to start an unauthenticated scraping API on a public URL."
  exit 1
fi

PORT="${PORT:-8080}"
INTERNAL_PORT="${INTERNAL_PORT:-3002}"
export PORT INTERNAL_PORT

# ---------------------------------------------------------------------------
# 2. Queue backends must be supplied, not spawned.
#
# harness.ts falls back to starting its own Postgres and RabbitMQ containers
# when NUQ_DATABASE_URL / NUQ_RABBITMQ_URL are unset, and dies with
# "Neither Docker nor Podman found" inside any container runtime. Say which
# variable is missing instead of letting that message stand as the diagnosis.
# ---------------------------------------------------------------------------
for var in NUQ_DATABASE_URL NUQ_RABBITMQ_URL REDIS_URL; do
  eval "value=\${$var:-}"
  if [ -z "$value" ]; then
    log "FATAL: $var is empty. Firecrawl cannot start its own queue backends inside a container."
    exit 1
  fi
done

# The app binds loopback; nginx owns the public port.
export HOST=127.0.0.1
export PORT_INTERNAL="$INTERNAL_PORT"

# ---------------------------------------------------------------------------
# 3. Gateway.
# ---------------------------------------------------------------------------
mkdir -p /tmp/nginx-body /tmp/nginx-proxy /tmp/nginx-fastcgi /tmp/nginx-uwsgi /tmp/nginx-scgi
envsubst '${PORT} ${INTERNAL_PORT} ${FIRECRAWL_API_KEY}' \
  < /etc/nginx/firecrawl.conf.template > /tmp/nginx.conf
nginx -t -c /tmp/nginx.conf
nginx -c /tmp/nginx.conf &
NGINX_PID=$!
log "gateway listening on ${PORT}, app on 127.0.0.1:${INTERNAL_PORT}"

trap 'kill $NGINX_PID 2>/dev/null || true' TERM INT

# ---------------------------------------------------------------------------
# 4. Hand over to Firecrawl's own harness, with PORT pointing at the loopback
#    listener rather than at Railway's injected public port.
# ---------------------------------------------------------------------------
export PORT="$INTERNAL_PORT"
exec node dist/src/harness.js
