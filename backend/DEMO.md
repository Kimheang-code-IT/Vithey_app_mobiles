# Vithey Demo Stack (Profile M) — local PC
#
# Prerequisites:
#   1. Docker Desktop running
#   2. Copy external-services/ai-core/.env.example → external-services/ai-core/.env and set DEEPSEEK_API_KEY
#   3. Optional: set GOOGLE_PLACES_API_KEY in services/map-service/.env.example (or a real .env)
#
# Start (from backend/):
#   .\scripts\docker-up-demo.ps1
#
# Or:
#   docker compose -f docker-compose.yml -f docker-compose.demo.yml up -d --build
#
# Stop:
#   .\scripts\docker-down-demo.ps1
#
# Or:
#   docker compose -f docker-compose.yml -f docker-compose.demo.yml down
#
# Notes:
#   - All Vithey Java services + external-services/ai-core (Python owns /api/v1/ai/**); map-service is opt-in
#   - NO Java ai-service; NO GDCE / general-service (chat = stub)
#   - Resource caps are env-driven: copy .env.example → .env and tune (defaults for ~3 users)
#   - Optional map-service: .\scripts\docker-up-demo.ps1 -Profiles map (or COMPOSE_PROFILES=map)
#   - Gateway routes /api/v1/ai/** → http://ai-core:8100
#   - Flutter: API_BASE_URL=http://10.0.2.2:8080/api/v1 (emulator) or http://<LAN-IP>:8080/api/v1
#   - Set USE_MOCK_AI=false after stack is healthy to use live CV generate + stub chat

## Health checks

| Service | URL |
|---------|-----|
| Gateway | http://localhost:8080/actuator/health |
| map-service (only with `-Profiles map`) | http://localhost:8090/actuator/health |
| ai-core | http://localhost:8100/health |
| Eureka | http://localhost:8761 |

## Full API smoke (recommended)

From `backend/`:

```powershell
.\scripts\smoke-api.ps1
```

Expect AI chat, regenerate, sessions, cv/generate, cv/suggest, and places to PASS. Confirm no container `vithey-ai-service`.

## Manual AI probes

```http
POST http://localhost:8080/api/v1/ai/chat
POST http://localhost:8080/api/v1/ai/cv/generate
GET  http://localhost:8100/health
```
