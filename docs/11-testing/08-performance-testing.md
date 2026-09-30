# Performance Testing

> Status: **Not performed** · Last reviewed: 2026-09-30
> Evidence: no performance tooling/config found in `backend/`, `ai_core/`, `vithey_app/`, `.github/workflows/`
> Related: [01-test-strategy.md](01-test-strategy.md) §7

## 1. Status

**Performance/load testing has not been performed.** There is no JMeter, k6, Gatling,
Locust, Artillery, or similar harness in the repository, and no performance results of any
kind exist. All performance items below are `TBD — Requires confirmation.` unless they are
static design limits visible in config.

## 2. What exists (static, not measured)

These are configured bounds, **not** measured performance:

| Bound | Value | Evidence |
| --- | --- | --- |
| Gateway HTTP rate limit | 100 replenish / 100 burst (default) | `config-repo/api-gateway.yml` |
| Gateway map rate limit | 30 / 60 | `config-repo/api-gateway.yml` |
| ai_core per-IP HTTP limit | 30/min | `ai_core/vithey_ai/config.py` |
| ai_core LLM limiter | 120/60s | `ai_core/vithey_ai/config.py` |
| ai_core body cap | 512 KB | `ai_core/vithey_ai/config.py` |
| LLM max tokens / timeout / retries | 3000 / 30s / 2 | `ai_core/vithey_ai/config.py` |
| Extraction cache | 512 entries | `ai_core/vithey_ai/cache.py` |
| DB pool per service | 5 max / 1 min | `config-repo/application.yml` |
| Feign timeout / circuit breaker | 5s / 50% failure over 10 calls | `config-repo/application.yml` |
| Container memory caps | per `backend/.env` | `backend/.env.example` |
| Demo concurrency target | ~10 users on one PC | `plan.md` §0 |

## 3. Performance test matrix (proposed — none executed)

| ID | Scenario | Metric | Target | Status |
| --- | --- | --- | --- | --- |
| PF-01 | Gateway throughput baseline (public health) | RPS, p95 latency | TBD — Requires confirmation. | Not performed |
| PF-02 | Auth login/register under load | p95 latency | TBD | Not performed |
| PF-03 | Feed read (`GET /posts`) under load | p95 latency | TBD | Not performed |
| PF-04 | AI CV generation end-to-end | p95 latency | plan target < 60s | Not performed |
| PF-05 | AI chat (stub) throughput | p95 latency | TBD | Not performed |
| PF-06 | Concurrent users on demo PC | users sustained | ~10 (design) | Not performed |
| PF-07 | Redis rate-limit behaviour at burst | correct 429s | no over-admit | Not performed |
| PF-08 | Map search with Redis failure | graceful degrade | no hard failure | Not performed |
| PF-09 | DB connection pool saturation | error rate | TBD | Not performed |
| PF-10 | Large file upload (within MIME/size caps) | latency, memory | TBD | Not performed |

## 4. Measurement gaps

| Gap | Impact |
| --- | --- |
| No load harness | Capacity unknown |
| No APM/tracing beyond Prometheus metrics | Latency attribution limited |
| No LLM latency recording | Cost/latency trade-offs unmeasured |
| No memory profiling | Container caps may be mis-tuned |
| No baseline established | Cannot detect regressions |

## 5. Recommended approach (when scheduled)

1. Stand up the demo stack, then use k6/Locust against `/api/v1/auth/login` and `/api/v1/posts`.
2. Record p50/p95/p99 and error rate at increasing virtual users; find the knee.
3. For AI, sample CV generations (they hit the real LLM) and record end-to-end latency/cost.
4. Store results in [12-test-results.md](12-test-results.md) with date, commit, and host specs.

## 6. Result status

`Not performed.` Additionally, no functional tests were executed during this documentation task.

## 7. Cross-references

- [01-test-strategy.md](01-test-strategy.md) · [02-test-plan.md](02-test-plan.md) · [12-test-results.md](12-test-results.md)
- `../03-system-design/08-technology-stack.md` · `../03-system-design/01-system-architecture.md`
