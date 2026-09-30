#!/usr/bin/env bash

BASE_HOST="${1:-localhost}"
echo -e "\033[0;36mVithey service health check ($BASE_HOST)\033[0m"
echo "--------------------------------------------------"

services=(
  "eureka-server:8761"
  "config-server:8888"
  "api-gateway:8080"
  "auth-service:8081"
  "user-profile-service:8082"
  "file-service:8083"
  "content-service:8084"
  "career-service:8085"
  "finance-service:8086"
  "chat-service:8087"
  "notification-service:8088"
  "map-service:8090"
)

passed=0
failed=0

for entry in "${services[@]}"; do
  name="${entry%%:*}"
  port="${entry##*:}"
  url="http://${BASE_HOST}:${port}/actuator/health"
  
  status=$(curl -s --max-time 5 "$url" 2>/dev/null | grep -o '"status":"[^"]*"' | cut -d':' -f2 | tr -d '"' || true)
  
  if [ "$status" = "UP" ]; then
    echo -e "\033[1;32m[OK]   $name ($url)\033[0m"
    ((passed++))
  else
    echo -e "\033[1;31m[FAIL] $name status=${status:-DOWN} ($url)\033[0m"
    ((failed++))
  fi
done

echo "--------------------------------------------------"
echo "Passed: $passed  Failed: $failed"

if [ "$failed" -gt 0 ]; then
  exit 1
fi
