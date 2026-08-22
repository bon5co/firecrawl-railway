# Firecrawl for Railway.
#
# Wraps the official upstream image and adds the two things a Railway deploy
# needs and the upstream image does not provide:
#
#   1. An nginx gateway on $PORT that requires an API key on every route
#      except the unauthenticated health route. Self-hosted Firecrawl
#      authenticates nobody (apps/api/src/lib/withAuth.ts short-circuits
#      whenever USE_DB_AUTHENTICATION is false, which is the only supported
#      self-hosted value), so without this the public URL lets any visitor
#      scrape and crawl on the deployer's bill.
#   2. An entrypoint that pins the app to loopback, refuses to boot without
#      an API key, and fails fast when the queue backends are unreachable
#      instead of falling through to upstream's "spawn my own Postgres with
#      Docker" path, which cannot work inside a Railway container.
FROM ghcr.io/firecrawl/firecrawl:2.11.209

USER root

RUN apt-get update \
 && apt-get install -y --no-install-recommends nginx gettext-base \
 && rm -rf /var/lib/apt/lists/*

COPY nginx.conf.template /etc/nginx/firecrawl.conf.template
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod +x /usr/local/bin/railway-entrypoint.sh

# The app itself never binds the public port; nginx does.
ENV HOST=127.0.0.1 \
    INTERNAL_PORT=3002 \
    NUQ_BACKEND=pg \
    USE_DB_AUTHENTICATION=false \
    DO_NOT_TRACK=1

ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
