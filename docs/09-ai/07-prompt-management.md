# Prompt Management

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `ai_core/vithey_ai/prompts.py`, `ai_core/vithey_ai/extraction.py`, `ai_core/vithey_ai/generation.py`

Part of the Vithey documentation set · Master index:
[`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) ·
Siblings: [LLM integration](04-llm-integration.md) · [CV generation](05-cv-generation.md) ·
[Limitations](11-ai-limitations.md).

## 1. Location and management model

All prompts live in a single module, `ai_core/vithey_ai/prompts.py`, as module-level constants. There
is **no** external prompt store, database, templating engine, A/B framework or version control beyond
git. Prompt changes require a code change and redeploy. [VERIFIED]

| Constant | Used by |
|---|---|
| `EXTRACTION_SYSTEM_PROMPT` | `ExtractionService.extract` |
| `CV_GENERATION_SYSTEM_PROMPT` | `CVGenerationService.generate` |

Both are system messages; the user message is assembled dynamically (post content + `source_id` for
extraction; activities + profile + target role + job description + language for generation).
[VERIFIED]

## 2. Extraction prompt (`EXTRACTION_SYSTEM_PROMPT`)

Goal: extract structured activity data from one post/activity. Key rules:

- Return **only** valid JSON.
- Do not invent information not present in the post.
- Missing fields → `null` or empty string.
- `activity_type` ∈ `project | knowledge_share | achievement | volunteer | work | other`.
- `skills` and `tools` are lists of short phrases; dates are `YYYY-MM-DD`.

Output JSON shape: `activity_type, title, role, summary, tools[], skills[], outcome, date,
source_id`. The client overwrites `source_id` with the authoritative value. [VERIFIED]

## 3. CV generation prompt (`CV_GENERATION_SYSTEM_PROMPT`)

Goal: produce a standard CV JSON from verified activities + optional profile, tailored to an optional
target role/job description. It enumerates the exact top-level keys
`contact, summary, experience, education, projects, skills, certifications, languages,
achievements, volunteer` and their nested shapes (matching `StandardCV`). Hard rules:

1. Use only facts present in the provided activities/profile.
2. Never invent jobs, projects, tools, skills, outcomes, dates or contact details.
3. Contact fields come from the profile only.
4. Every experience/project/certification/achievement/volunteer entry must cite ≥ 1 `source_id`.
5. Classify activities sensibly (paid/internship → experience; personal/team builds → projects;
   knowledge_share → skills/achievements; volunteer stays volunteer).
6. Group skills into categories (e.g. Technical, Tools, Soft skills); never leave skills empty if any
   activity lists skills.
7. Bullets under 25 words, action verbs, professional tone.
8. Tailor emphasis without fabricating.
9. Write human-readable text in the requested language (`en` = English, `km` = Khmer); keep technical
   names as-is.

[VERIFIED]

## 4. Prompt safety considerations (observed)

- The model output is **not** trusted blindly: `normalize_cv` coerces types, drops unknown headings,
  filters evidence to known `source_id`s, and forces contact/education from the profile. This limits
  the impact of prompt injection in post content. [VERIFIED: `normalize.py`]
- However, no explicit prompt-injection guard (delimiter hardening, instruction hierarchy) is applied
  to post text before it is embedded in the prompt. [INFERRED] Inferred from implementation —
  requires business confirmation.
- `MAX_CONTENT_CHARS` truncation bounds the size of injected post text. [VERIFIED]

## 5. Open items

- No prompt versioning/canary mechanism; prompt changes ship with code. `TBD — Requires confirmation.`
- No prompt-injection test coverage evidenced. `TBD — Requires confirmation.`
- Localisation of prompts beyond `en`/`km` CV text: `TBD — Requires confirmation.`
