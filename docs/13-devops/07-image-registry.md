# Image Registry

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `.github/workflows/ci-promote-dev.yml`, `backend/docker-compose.yml`, `backend/scripts/docker-build-service.ps1`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [CI/CD](05-CI-CD.md) · [Release process](08-release-process.md)

## 1. Registry

| Property | Value |
|---|---|
| Registry | GitHub Container Registry (GHCR) |
| Image pattern | `ghcr.io/<owner>/vithey-<service>` |
| Owner | `${{ github.repository_owner }}`, lowercased in the workflow |
| Authentication | `docker/login-action@v3` with `secrets.GITHUB_TOKEN` (actor username) |
| Permissions | `packages: write` |

[VERIFIED — `ci-promote-dev.yml:154-164`]

`<owner>` resolves to the GitHub account that owns the repository at run time (`kimheang-code-it` for `origin`, lowercased). The repository also has an `upstream` remote, but the workflow uses whichever repo runs it. [VERIFIED — `git remote -v`, workflow owner expression]

## 2. Tagging

Tags are produced by `docker/metadata-action@v5`:

```yaml
tags: |
  type=raw,value=latest
  type=sha,prefix=sha-,format=short
```

| Tag | Meaning |
|---|---|
| `latest` | most recent successful build on the tracked branches |
| `sha-<short>` | immutable tag for the short (7-char) commit SHA |

[VERIFIED — `ci-promote-dev.yml:166-182`]

> `latest` is mutable and not unique. For reproducibility, reference the `sha-<short>` tag. [VERIFIED]

## 3. Published images

The `docker-build-push` matrix publishes **13 images**:

| Image | Port |
|---|---|
| `ghcr.io/<owner>/vithey-eureka-server` | 8761 |
| `ghcr.io/<owner>/vithey-config-server` | 8888 |
| `ghcr.io/<owner>/vithey-api-gateway` | 8080 |
| `ghcr.io/<owner>/vithey-auth-service` | 8081 |
| `ghcr.io/<owner>/vithey-user-profile-service` | 8082 |
| `ghcr.io/<owner>/vithey-file-service` | 8083 |
| `ghcr.io/<owner>/vithey-content-service` | 8084 |
| `ghcr.io/<owner>/vithey-career-service` | 8085 |
| `ghcr.io/<owner>/vithey-finance-service` | 8086 |
| `ghcr.io/<owner>/vithey-chat-service` | 8087 |
| `ghcr.io/<owner>/vithey-notification-service` | 8088 |
| `ghcr.io/<owner>/vithey-ai-core` | 8100 |
| `ghcr.io/<owner>/vithey-map-service` | 8090 |

[VERIFIED — `ci-promote-dev.yml` matrix and `docker-summary` loop]

The matrix also maps each image to its Dockerfile and the `SERVICE_PORT` build arg used for `ENV SERVER_PORT` / `EXPOSE`. [VERIFIED]

## 4. Local vs registry images

| Image reference | Produced by | Pushed |
|---|---|---|
| `vithey-<service>:local` | `docker compose ... build` (base/demo compose) | No |
| `vithey-<service>:ci` | per-service workflow `docker build` | No |
| `ghcr.io/<owner>/vithey-<service>:latest` | `ci-promote-dev.yml` (push) | Yes |
| `ghcr.io/<owner>/vithey-<service>:sha-<short>` | `ci-promote-dev.yml` (push) | Yes |

[VERIFIED — compose `image:` fields, `auth-service-ci.yml`, `ci-promote-dev.yml`]

Local compose files reference the `:local` tags; they do **not** pull from GHCR. Pulling a published image and running it in a deployed environment is **not automated anywhere**. [VERIFIED]

## 5. Pulling published images

```powershell
# authenticate (if the package is private)
$env:CR_PAT = "<REDACTED>"
"$env:CR_PAT" | docker login ghcr.io -u <github-user> --password-stdin

# pull a pinned build
docker pull ghcr.io/<owner>/vithey-auth-service:sha-<short>
```

Image packages are created under the repository owner's GHCR namespace. Public/private visibility is a repository setting, not captured here. [TBD] GHCR package visibility and retention policy — TBD — Requires confirmation.

## 6. Gaps

- No image vulnerability scanning or SBOM generation. [VERIFIED]
- No image signing (cosign/Notary). [VERIFIED]
- No registry retention/pruning policy in the workflow. [VERIFIED]
- No promotion between registries or environments; GHCR is the only registry used. [VERIFIED]
