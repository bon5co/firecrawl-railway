# RabbitMQ for Firecrawl's job queue.
#
# Only reason this image exists: RABBITMQ_DEFAULT_USER has to be a literal,
# and a literal published as a template variable is dropped at generate time
# and reappears as a blank required field on the deploy form. The default
# `guest` account cannot authenticate from another host, so the queue needs a
# named user. The password stays a template variable, per deploy.
FROM rabbitmq:4.1.4-alpine

ENV RABBITMQ_DEFAULT_USER=firecrawl
