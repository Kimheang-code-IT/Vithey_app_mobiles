#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$BACKEND_ROOT"

SKIP_BUILD=false
DOWN=false
LOGS=false
INFRA_ONLY=false

for arg in "$@"; do
  case "$arg" in
    --skip-build|-SkipBuild)
      SKIP_BUILD=true
      ;;
    --down|-Down)
      DOWN=true
      ;;
    --logs|-Logs)
      LOGS=true
      ;;
    --infra-only|-InfraOnly)
      INFRA_ONLY=true
      ;;
    --help|-h)
      echo "Usage: ./scripts/start-all.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --infra-only    Start only databases, RabbitMQ, MinIO, Eureka, Config Server"
      echo "  --skip-build    Skip docker build and start existing images"
      echo "  --logs          Show tail of recent stack logs"
      echo "  --down          Stop and remove containers"
      exit 0
      ;;
  esac
done

if [ "$LOGS" = true ]; then
  echo -e "\033[0;36m=== Vithey stack logs (last 80 lines) ===\033[0m"
  docker compose logs --tail 80
  exit 0
fi

if [ "$DOWN" = true ]; then
  echo -e "\033[1;33mStopping Vithey stack...\033[0m"
  docker compose down
  exit 0
fi

if [ "$INFRA_ONLY" = true ]; then
  echo -e "\033[1;32mStarting infrastructure only (Postgres, Redis, RabbitMQ, MinIO, Eureka, Config Server)...\033[0m"
  cd "$BACKEND_ROOT/infrastructure"
  if [ "$SKIP_BUILD" = true ]; then
    docker compose up -d
  else
    docker compose up -d --build
  fi
  exit 0
fi

echo -e "\033[1;32mStarting Vithey full stack (infra + all services)...\033[0m"
echo -e "\033[0;90mFirst build can take several minutes to download dependencies.\033[0m"

if [ "$SKIP_BUILD" = true ]; then
  docker compose up -d
else
  BUILD_SERVICES=(
    "eureka-server"
    "config-server"
    "auth-service"
    "user-profile-service"
    "file-service"
    "content-service"
    "career-service"
    "finance-service"
    "chat-service"
    "notification-service"
    "ai-core"
    "map-service"
    "api-gateway"
  )

  echo -e "\033[1;36mBuilding microservice images with BuildKit cache...\033[0m"
  for svc in "${BUILD_SERVICES[@]}"; do
    echo -e "\033[0;33m==> Building $svc...\033[0m"
    docker compose build "$svc"
  done

  echo -e "\033[1;32mStarting containers...\033[0m"
  docker compose up -d
fi

wait_for_health() {
  local url="$1"
  local max_attempts="${2:-60}"
  local delay="${3:-5}"
  for ((i=1; i<=max_attempts; i++)); do
    if curl -s -f --max-time 3 "$url" 2>/dev/null | grep -q '"status":"UP"'; then
      return 0
    fi
    sleep "$delay"
  done
  return 1
}

echo ""
echo -e "\033[0;36mWaiting for Eureka / Config Server / API Gateway...\033[0m"
eureka_ready=false
config_ready=false
gateway_ready=false

if wait_for_health "http://localhost:8761/actuator/health" 36 5; then eureka_ready=true; fi
if wait_for_health "http://localhost:8888/actuator/health" 36 5; then config_ready=true; fi
if wait_for_health "http://localhost:8080/actuator/health" 72 5; then gateway_ready=true; fi

echo ""
echo -e "\033[1;32m=== Vithey stack status ===\033[0m"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

echo ""
if [ "$eureka_ready" = true ]; then
  echo -e "Eureka:   \033[1;32mhttp://localhost:8761 [UP]\033[0m"
else
  echo -e "Eureka:   \033[1;33mstill starting — run: docker compose logs eureka-server\033[0m"
fi

if [ "$config_ready" = true ]; then
  echo -e "Config:   \033[1;32mhttp://localhost:8888 [UP]\033[0m"
else
  echo -e "Config:   \033[1;33mstill starting — run: docker compose logs config-server\033[0m"
fi

if [ "$gateway_ready" = true ]; then
  echo -e "Gateway:  \033[1;32mhttp://localhost:8080/actuator/health [UP]\033[0m"
else
  echo -e "Gateway:  \033[1;33mstill starting — run: docker compose logs api-gateway\033[0m"
fi

echo "RabbitMQ: http://localhost:15672  (guest/guest)"
echo "MinIO:    http://localhost:19001  (minioadmin/minioadmin)"
echo "Postgres: localhost:15432"
echo "Redis:    localhost:16379"
echo ""
echo "Logs:     ./scripts/start-all.sh --logs"
echo "Stop:     ./scripts/start-all.sh --down"
echo "Infra:    ./scripts/start-all.sh --infra-only"
