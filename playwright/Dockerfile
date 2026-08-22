# Firecrawl's Playwright renderer, pinned to a port of our own choosing.
#
# Railway injects PORT into every service, including private ones, and the
# injected value overrides the image's own ENV. This service has no public
# domain and no healthcheck, so nothing needs the injected port honoured --
# but the API dials it at a fixed address, so the port must be predictable.
# An entrypoint runs after the injection and therefore wins.
FROM ghcr.io/firecrawl/playwright-service@sha256:468009bae00911d40d7120d58489a1d529362c22c45585cb9076094fe61b0025

ENV BLOCK_MEDIA=true \
    MAX_CONCURRENT_PAGES=10

ENTRYPOINT ["/bin/sh", "-c", "export PORT=3000; exec pnpm start"]
