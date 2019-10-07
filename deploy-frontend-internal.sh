#!/usr/bin/env bash
set -e
source ./replicas.sh

# Description: Serves the internal Sourcegraph frontend API.
#
# Disk: 128GB / non-persistent SSD
# Network: 100mbps
# Liveness probe: n/a
# Ports exposed to other Sourcegraph services: 3090/TCP 6060/TCP
# Ports exposed to the public internet: none
#
docker run --detach \
    --name=sourcegraph-frontend-internal \
    --network=sourcegraph \
    --restart=always \
    --cpus=4 \
    --memory=8g \
    -e GOMAXPROCS=4 \
    -e PGHOST=pgsql \
    -e SRC_GIT_SERVERS="$(addresses "gitserver-" $NUM_GITSERVER ":3178")" \
    -e SRC_SYNTECT_SERVER=http://syntect-server:9238 \
    -e SEARCHER_URL="$(addresses "http://searcher-" $NUM_SEARCHER ":3181")" \
    -e SYMBOLS_URL="$(addresses "http://symbols-" $NUM_SYMBOLS ":3184")" \
    -e SRC_FRONTEND_INTERNAL=sourcegraph-frontend-internal:3090 \
    -e REPO_UPDATER_URL=http://repo-updater:3182 \
    -e REPLACER_URL=http://replacer:3185 \
    -e ZOEKT_HOST=zoekt-webserver:6070 \
    -e LSIF_SERVER_URL=http://lsif-server:3186 \
    -e GRAFANA_SERVER_URL=http://grafana:3000 \
    -v ~/sourcegraph-docker/sourcegraph-frontend-internal-0-disk:/mnt/cache \
    sourcegraph/frontend@sha256:a658bbe4cbb40ba16891d036bc2892c80c98a05c5c4184d336020e7ff6fab5cd

echo "Deployed sourcegraph-frontend-internal service"
