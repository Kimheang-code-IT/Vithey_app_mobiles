# AI Assistant (Vithey AI) Guide

> Status: **CV generation = real LLM; chat = Stub (no RAG / no GDCE)** · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/modules/chatbot/**`, `vithey_app/lib/modules/jobs/ai_cv/**`, `ai_core/vithey_ai/api/flutter_routes.py`, `api_docs.md` §10, `../06-api/12-ai-api.md`
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

> **Critical distinction.** Vithey AI has two surfaces:
> **(a) chat is a stub** that returns canned Markdown by topic; **(b) CV generation calls a real
> LLM.** Do not present the chat as a functional assistant
> [VERIFIED: `_meta/EVIDENCE-BASIS.md` §6; `../06-api/12-ai-api.md` §1, §3].

## 1. Opening the assistant

Vithey AI is bottom-nav tab 3 (sparkles icon) and opens as a **full-screen** route `/chatbot`
(no bottom bar) [VERIFIED: `lib/core/navigation/main_tab_navigation.dart`,
`lib/modules/home/shell/main_shell_screen.dart`]. It can also be opened with a starter prompt or a
topic from other screens [VERIFIED: `lib/modules/chatbot/chatbot_controller.dart` `_applyNavigationArguments`].

## 2. Chat experience (Stub)

The chat UI is fully built: sessions history drawer, streaming "typing" animation, Markdown/code
rendering, copy/share, regenerate, stop, rename/pin/delete sessions, starter prompts, and inline
attachments [VERIFIED: `chatbot_controller.dart`, `lib/modules/chatbot/widgets/**`].

| Action | Endpoint |
| --- | --- |
| Send (sync) | `POST /ai/chat` |
| Send (stream / SSE) | `POST /ai/chat/stream` |
| Regenerate | `POST /ai/messages/{message_id}/regenerate` |
| Stop | `DELETE /ai/chat/requests/{request_id}` |
| Sessions | `GET /ai/sessions` |
| Session messages | `GET /ai/sessions/{id}/messages` |
| Delete session | `DELETE /ai/sessions/{id}` |

[VERIFIED: `api_docs.md` §10, `../06-api/12-ai-api.md` §1]

**What the server actually returns:**

- The reply is **Markdown produced by `stub_reply`**, selected by topic
  (`CV | JOB | INTERVIEW | STUDENT | FINANCE`; unknown → `STUDENT`). There is **no retrieval, no
  RAG, and no GDCE**. `AI_CHAT_MODE=stub` is read but never branched on — chat always calls the
  stub [VERIFIED: `_meta/EVIDENCE-BASIS.md` §6, `../06-api/12-ai-api.md` §1].
- `POST /ai/cv/suggest` (section suggestions) is **also stubbed** [VERIFIED: `../06-api/12-ai-api.md` §3].
- Because sessions/messages are still persisted, browsing history and session management demonstrably
  work even though replies are canned [VERIFIED: `ai_docs.md` §10].

## 3. What is real: CV generation

The **Auto-Create CV** feature uses the real LLM pipeline in `ai_core` (fetch profile + posts →
extract → generate → normalize → quality score) [VERIFIED: `_meta/EVIDENCE-BASIS.md` §6]. See
[05-job-cv-guide.md](05-job-cv-guide.md) §4 for the full user flow.

- Endpoint: `POST /ai/cv/generate` (all fields optional) → `AiCvDraft`
  (`full_name`, `summary`, `skills`, `education`, `experience`, `projects`, `contact`,
  `quality_score`, `quality_grade`) [VERIFIED: `api_docs.md` §10].
- The LLM client defaults to OpenRouter GLM (`z-ai/glm-5.3-flash`) even though the env vars keep the
  `DEEPSEEK_*` prefix [VERIFIED: `_meta/EVIDENCE-BASIS.md` §6, `ai_core/.env.example`].
- Cost controls exist: `MAX_TOKENS=3000`, `TEMPERATURE=0.2`, per-IP HTTP rate limit (30/min), and
  body cap 512 KB [VERIFIED: `../06-api/12-ai-api.md` §4].

## 4. Chat attachments — Stub

The composer exposes Photo / Video / File attachments and can attach up to five items
[VERIFIED: `chatbot_controller.dart`]. However, attachments are folded into the **prompt text**
(`Photo: name`, `File: name`) rather than being processed by the assistant, and the UI also carries
a "File attachments are coming soon" string [VERIFIED: `ChatbotController._buildApiMessage`,
`AppStrings.chatbotAttachComingSoon`]. Treat attachment understanding as **not functional**.

## 5. Other UI-only features

- **Search chats (history search)** in the drawer is a **"coming soon"** tooltip
  [VERIFIED: `chatbot/widgets/chatbot_history_drawer.dart`].
- Job match, skills score, and feed recommendations endpoints are **not shipped**; Flutter returns
  neutral/mock values in live mode [VERIFIED: `api_docs.md` §10, §15].

## 6. Cost & availability notes

- If the LLM is unavailable or the profile is too empty, `cv/generate` returns an **incomplete
  draft** rather than an error [VERIFIED: `api_docs.md` §10].
- The demo runs on one local machine for ~10 concurrent users; CV generation is intentionally
  serialized [VERIFIED: `plan.md` §3, §7.3].

## 7. Related

- [05-job-cv-guide.md](05-job-cv-guide.md) · [07-chat-guide.md](07-chat-guide.md) · [10-FAQ.md](10-FAQ.md)
- [../06-api/12-ai-api.md](../06-api/12-ai-api.md) · [../09-ai/](../09-ai/)
- Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)
