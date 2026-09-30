# Vithey AI Core (`vithey-ai`)

Self-contained Python package that powers the Vithey CV generation feature:
it reads a user's own posts, extracts structured activities, and turns them
into **one standard CV** — with profile data merged in and optional tailoring
towards a target role or job description.

Other developers do **not** need to know anything about prompts, JSON schemas,
or DeepSeek. They only import `VitheyAI` (or call the HTTP API) and use the result.

## What makes the output "standard"

Every generated CV is a `StandardCV` with a **guaranteed** shape:

```
contact      -> full name, headline, email, phone, location, links
summary      -> professional summary
experience   -> Work Experience        (always present)
education    -> Education              (always present)
projects     -> Projects               (always present)
skills       -> Skills, grouped        (always present)
certifications / languages / achievements / volunteer   (always present)
meta         -> language, target_role, job_tailored, model, counts, timestamp
```

A deterministic normalizer sits between the LLM and your code, so even if the
model returns garbage you still get a valid standard CV: canonical sections in
fixed order, missing sections rendered as empty lists, contact fields taken
only from the user profile, evidence (`source_id`s) filtered to known posts,
and a fact-based fallback summary. Every entry cites the post(s) it came from —
nothing is invented.

## Quick start

```bash
pip install -e .          # install the package
pip install -e ".[server]" # optional: FastAPI/uvicorn for the HTTP API
cp .env.example .env      # then put your DEEPSEEK_API_KEY in .env
```

## Usage

### One-off extraction

```python
from vithey_ai import VitheyAI

ai = VitheyAI()

activity = ai.extract_activity(
    content="We built a recycling pickup app at RUPP using Flutter and Firebase.",
    source_id="post_123",
)
print(activity.title)
print(activity.skills)
```

### Full standard CV from raw posts (with profile + job targeting)

```python
from vithey_ai import VitheyAI, RawPost

ai = VitheyAI()

posts = [
    RawPost(source_id="post_1", content="Built a smart campus app..."),
    RawPost(source_id="post_2", content="Shared a guide on Python data structures..."),
]

cv = ai.build_cv_from_raw_posts(
    posts=posts,
    profile={  # dict or UserProfile; wins over anything the AI produces
        "full_name": "Sok Dara",
        "email": "dara@example.com",
        "phone": "+855 12 345 678",
        "education": [{"degree": "BSc Computer Science", "institution": "RUPP"}],
    },
    target_role="Software Engineer Intern",
    job_description="Flutter mobile intern; Firebase experience a plus.",
    language="en",            # "en" or "km"
)

print(cv.contact.full_name)          # Sok Dara (from profile)
for project in cv.projects:          # canonical sections, fixed order
    print(project.name, project.evidence)

report = ai.quality_report(cv)       # deterministic 0-100 score + issues
print(report.score, report.grade, [i.code for i in report.issues])
```

### Batch extraction with failure visibility

```python
result = ai.extract_activities(posts)         # skips failures, never silently
print(result.ok_count, result.failure_count)  # failures list each bad post
```

Duplicate posts about the same activity are automatically **merged**
(all `source_id`s preserved as evidence).

## Public API (`VitheyAI`)

| Method | Description |
| --- | --- |
| `extract_activity(content, source_id, source_type="post")` | Reads raw text from one post/activity, returns `ExtractedActivity`. |
| `extract_activities(posts, on_error="skip")` | Batch extraction; dedupes repeats, reports failures (`ExtractionBatchResult`). `"fail"` aborts on first error. |
| `generate_cv(activities, profile=None, target_role="", job_description="", language="en")` | Takes extracted activities (+optional profile/job), returns `StandardCV`. |
| `build_cv_from_raw_posts(posts, profile=None, target_role="", job_description="", language="en", on_error="skip")` | Convenience: posts → extract → dedupe → generate → `StandardCV`. |
| `quality_report(cv)` | Deterministic completeness score (0-100), grade, actionable issues. |

Public models: `StandardCV`, `RawPost`, `UserProfile`, `ExtractedActivity`,
`CVQualityReport`, `ExtractionBatchResult`, `ExtractionFailure`, plus the CV
building blocks (`ContactInfo`, `ExperienceItem`, `EducationItem`,
`ProjectItem`, `SkillGroup`, ...).

Errors: all custom exceptions inherit from `VitheyAIError`
(`AIClientError`, `AIResponseValidationError`, `EmptyInputError`,
`RateLimitError`, `InputLimitError`, `UnsupportedLanguageError`).

## HTTP API (for the superapp backend)

```bash
python main.py serve --port 8100
# or: uvicorn vithey_ai.api.app:create_app --factory --port 8100
```

Every response uses the platform envelope `{success, data, meta}` with
`X-Request-ID`; errors carry `{code, message, details}`.

| Endpoint | Description |
| --- | --- |
| `GET /health` | Liveness + config check (`healthy` / `degraded`). |
| `POST /api/v1/activities/extract` | Extract one activity from raw post text. |
| `POST /api/v1/activities/extract-batch` | Extract many posts; returns activities + failures. |
| `POST /api/v1/cv/generate` | Posts XOR activities + optional profile/target role/job description/language → `{cv, quality}`. |

Example:

```bash
curl -X POST http://localhost:8100/api/v1/cv/generate \
  -H "Content-Type: application/json" \
  -d '{
    "posts": [{"source_id": "post_1", "content": "Built a smart campus app..."}],
    "profile": {"full_name": "Sok Dara", "email": "dara@example.com"},
    "target_role": "Software Engineer Intern",
    "language": "en"
  }'
```

Built-in protections: per-client IP rate limiting (429 envelope),
request body size limit (413), CORS allow-list, request-id tracing,
latency headers.

## CLI

Single entry point for developers who don't want to import the package.

```bash
# extract one activity from raw post text
python main.py extract --content "We built a recycling pickup app at RUPP" --source-id post_123

# generate a standard CV from raw posts, with profile + job ad tailoring
python main.py generate --posts posts.json --profile profile.json \
    --job-file job.txt --target-role "Software Engineer Intern" --with-quality

# generate from already-extracted activities, in Khmer
python main.py generate --activities activities.json --language km

# serve the HTTP API
python main.py serve --port 8100
```

Output is clean JSON on stdout (easy to pipe), errors go to stderr with a
non-zero exit code. The API key is read automatically from `.env`; pass
`--api-key` to override for a single call.

## Reliability & cost controls (all env-tunable)

- **Retries with exponential backoff** for transient LLM failures.
- **Rate limiting** of LLM calls (sliding window) — protects your budget.
- **Content caps**: max posts per build, max chars per post.
- **Extraction cache** keyed by content hash — identical text never pays twice.
- **Structured logging** (`LOG_LEVEL`) — skipped/failing posts are logged, not lost.

See `.env.example` for every knob.

## Development

```bash
pip install -e ".[dev]"
pytest
```

## Layout

```
ai_core/
├── main.py                 # CLI entry point (python main.py ...)
├── vithey_ai/
│   ├── config.py           # env-driven knobs (model, retries, limits, CORS...)
│   ├── schemas.py          # Pydantic models incl. StandardCV
│   ├── errors.py           # custom exceptions
│   ├── logging_conf.py     # structured logging
│   ├── ratelimit.py        # sliding-window LLM rate limiter
│   ├── cache.py            # bounded extraction cache
│   ├── deepseek_client.py  # JSON-mode client w/ retry+backoff
│   ├── prompts.py          # prompt templates (internal)
│   ├── extraction.py       # single/batch activity extraction
│   ├── dedupe.py           # merge duplicate activities across posts
│   ├── normalize.py        # LLM output -> guaranteed StandardCV
│   ├── quality.py          # deterministic CV scoring
│   ├── generation.py       # standard-CV generation service
│   ├── service.py          # public facade: VitheyAI
│   └── api/                # optional FastAPI wrapper
│       ├── app.py          # create_app() factory
│       ├── routes.py       # /api/v1 endpoints + /health
│       ├── middleware.py   # request-id, rate limit, body size
│       ├── envelope.py     # {success, data, meta} responses
│       └── schemas.py      # request models
├── tests/
├── pyproject.toml
└── .env.example
```
