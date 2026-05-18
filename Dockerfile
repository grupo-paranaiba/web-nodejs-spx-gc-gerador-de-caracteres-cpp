FROM node:20-bookworm-slim

WORKDIR /app

RUN apt-get update \
  && apt-get install -y --no-install-recommends tini \
  && rm -rf /var/lib/apt/lists/*

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY . .
COPY docker/config.docker.json docker/config.docker.json

RUN sed -i 's/\r$//' docker/entrypoint.sh \
  && chmod +x docker/entrypoint.sh

ENV NODE_ENV=production
EXPOSE 3011

ENTRYPOINT ["/usr/bin/tini", "--", "/bin/sh", "/app/docker/entrypoint.sh"]
