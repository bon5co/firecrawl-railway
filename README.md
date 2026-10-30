# firecrawl-railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/firecrawl-or-just-updated-web-scraper-ap?referralCode=Z1xivh&utm_medium=integration&utm_source=template&utm_campaign=generic)

**Deploy on Railway:** [Firecrawl template](https://railway.com/deploy/firecrawl-or-just-updated-web-scraper-ap?referralCode=Z1xivh&utm_medium=integration&utm_source=template&utm_campaign=generic)

Wrapper image for the Railway template
**Firecrawl | (Just Updated) Web Scraper API for LLMs, Not Open to the Internet**.

Built on the official `ghcr.io/firecrawl/firecrawl` image. It adds:

- an nginx gateway on `$PORT` that requires this deployment's own
  `FIRECRAWL_API_KEY` on every route except the health route — self-hosted
  Firecrawl authenticates nobody, so the stock deploy lets any visitor scrape
  and crawl on the deployer's bill;
- a boot guard that refuses to start without that key, and without the queue
  backends (`NUQ_DATABASE_URL`, `NUQ_RABBITMQ_URL`, `REDIS_URL`) — upstream
  otherwise tries to spawn its own Postgres and RabbitMQ with Docker and dies
  with `Neither Docker nor Podman found` inside any container runtime.

Image: `ghcr.io/bon5co/firecrawl-railway:2.11.209`
