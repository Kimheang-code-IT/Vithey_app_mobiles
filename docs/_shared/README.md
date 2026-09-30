# Shared Prompt Index

Single sources of truth used by all prompt layers. **Do not copy these tables into other files — link here.**

| File | Owns |
| --- | --- |
| [REPO_PATHS.md](REPO_PATHS.md) | Output folder names (`backend/`, `vithey_app/`) |
| [SERVICE_REGISTRY.md](SERVICE_REGISTRY.md) | Build order, ports, Eureka names, screen → service map |
| [READ_ORDER.md](READ_ORDER.md) | Standard read order per layer and per backend service |

## Layer ownership

| Layer | Folder | Owns | Must reference (not copy) |
| --- | --- | --- | --- |
| Frontend | `Prompt Frontend/` | UI, GetX, screen flows | `api-intergration/integration-contract.md` for API |
| Backend | `Prompt Backend/` | Spring Boot, domain logic, DB | `integration-contract.md`, `_shared/SERVICE_REGISTRY.md` |
| DevOps | `Prompt Devops/` | Docker, CI/CD, runbooks | `_shared/REPO_PATHS.md`, `v1/06-per-service-docker-compose-prompt.md` |

## Entry points

| Human | AI session |
| --- | --- |
| `Project Overview.txt` + `Prompt Backend/LEARNING.md` | `Prompt Backend/MASTER_AI_PROMPT.md` |
