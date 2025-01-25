#!/bin/bash

# Configuration
COMPOSE_FILE="compose.yaml"
CADDYFILE="Caddyfile"
HEALTH_CHECK_PATH="/health"  # Adjust to your health endpoint


# docker plugin install grafana/loki-docker-driver:latest --alias loki
# docker plugin enable loki

# Determine current active deployment (blue or green)
get_active_deployment() {
    grep -A1 "reverse_proxy" $CADDYFILE | grep "to" | awk '{print $2}' | cut -d: -f1
}

# Get target deployment
get_target_deployment() {
    current=$1
    if [ "$current" = "app_blue" ]; then
        echo "app_green"
    else
        echo "app_blue"
    fi
}

# Pull latest image
docker compose pull

# Get current and target deployments
CURRENT_DEPLOYMENT=$(get_active_deployment)
TARGET_DEPLOYMENT=$(get_target_deployment $CURRENT_DEPLOYMENT)

echo "Current deployment: $CURRENT_DEPLOYMENT"
echo "Target deployment: $TARGET_DEPLOYMENT"

# Start new deployment
docker compose up -d --scale "${TARGET_DEPLOYMENT}=1" --no-deps $TARGET_DEPLOYMENT

# Wait for container to be healthy
for i in {1..30}; do
    if curl -s "http://${TARGET_DEPLOYMENT}:8080${HEALTH_CHECK_PATH}" >/dev/null; then
        echo "New deployment is healthy"
        
        # Update Caddyfile
        sed -i "s/$CURRENT_DEPLOYMENT/$TARGET_DEPLOYMENT/" $CADDYFILE
        
        # Reload Caddy
        docker compose exec caddy caddy reload
        
        # Stop old deployment
        docker compose stop $CURRENT_DEPLOYMENT
        
        echo "Deployment successful!"
        exit 0
    fi
    echo "Waiting for new deployment to be healthy..."
    sleep 2
done

# If we got here, health check failed
echo "New deployment failed health check"
docker compose stop $TARGET_DEPLOYMENT
exit 1
