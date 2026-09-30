#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_ROOT="$(dirname "$SCRIPT_DIR")"

SERVICE="$1"
ACTION="${2:---build}"

if [ -z "$SERVICE" ]; then
  echo "Usage: ./scripts/docker-build-service.sh <service-name> [--up|--build-only|--down]"
  echo ""
  echo "Available services:"
  echo "  eureka-server, config-server, api-gateway, auth-service, user-profile-service,"
  echo "  file-service, content-service, career-service, finance-service, chat-service,"
  echo "  notification-service, map-service"
  exit 1
fi

declare -A SERVICE_MAP=(
  ["eureka-server"]="infrastructure/eureka-server:8761"
  ["config-server"]="infrastructure/config-server:8888"
  ["api-gateway"]="services/api-gateway:8080"
  ["auth-service"]="services/auth-service:8081"
  ["user-profile-service"]="services/user-profile-service:8082"
  ["file-service"]="services/file-service:8083"
  ["content-service"]="services/content-service:8084"
  ["career-service"]="services/career-service:8085"
  ["finance-service"]="services/finance-service:8086"
  ["chat-service"]="services/chat-service:8087"
  ["notification-service"]="services/notification-service:8088"
  ["map-service"]="services/map-service:8090"
)

if [ -z "${SERVICE_MAP[$SERVICE]}" ]; then
  echo -e "\033[1;31mUnknown service: $SERVICE\033[0m"
  echo "Available: ${!SERVICE_MAP[*]}"
  exit 1
fi

ENTRY="${SERVICE_MAP[$SERVICE]}"
REL_PATH="${ENTRY%%:*}"
PORT="${ENTRY##*:}"
SERVICE_DIR="$BACKEND_ROOT/$REL_PATH"

if [ ! -f "$SERVICE_DIR/docker-compose.yml" ]; then
  echo -e "\033[1;31mNo docker-compose.yml found in $SERVICE_DIR\033[0m"
  exit 1
fi

# Ensure vithey-network exists
if ! docker network inspect vithey-network >/dev/null 2>&1; then
  echo -e "\033[1;33mCreating vithey-network...\033[0m"
  docker network create vithey-network
fi

cd "$SERVICE_DIR"

case "$ACTION" in
  --down|-Down)
    docker compose down
    ;;
  --up|-Up)
    docker compose up -d --build
    echo -e "\033[0;36mHealth check: http://localhost:$PORT/actuator/health\033[0m"
    ;;
  --build-only|-BuildOnly|--build)
    docker compose build
    echo -e "\033[1;32mBuilt $REL_PATH. Start with:\033[0m"
    echo "  (cd $SERVICE_DIR && docker compose up -d)"
    echo "  or: ./scripts/docker-build-service.sh $SERVICE --up"
    ;;
  *)
    docker compose up -d --build
    echo -e "\033[0;36mHealth check: http://localhost:$PORT/actuator/health\033[0m"
    ;;
esac
