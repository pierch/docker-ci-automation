# sample dockerfile for testing docker builds
FROM nginx:1.27-alpine as base

RUN useradd -u 10001 -m appuser
USER appuser

RUN apk add --no-cache curl

WORKDIR /test

COPY . .

#########################
FROM base as test

#layer test tools and assets on top as optional test stage
RUN apk add --no-cache apache2-utils

HEALTHCHECK CMD curl --fail http://localhost || exit 1

#########################
FROM base as final

# this layer gets built by default unless you set target to test
