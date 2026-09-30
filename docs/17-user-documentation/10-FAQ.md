# Frequently Asked Questions (FAQ)

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/**`, `api_docs.md`, `_meta/EVIDENCE-BASIS.md`
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

This FAQ answers both end-user and demo-stakeholder questions. Where a feature is a stub or not
active, that is stated explicitly.

## General

**What is Vithey?**
A student "superapp" (feed, jobs/CV, student finance, peer chat, AI assistant, notifications, map)
built for the ACLEDA Bank App Competition 2026 [VERIFIED].

**Which platforms are supported?**
Android and iOS targets exist, but the only verified runtime is Android (emulator or device).
**Web/Chrome is unsupported** because Isar, secure storage, and camera are unavailable
[VERIFIED: `AGENTS.md`, `_meta/EVIDENCE-BASIS.md` §7].

**Is there a live production server?**
No. Only a **local demo stack** exists. **Staging does not exist. Production does not exist**
[VERIFIED: `_meta/EVIDENCE-BASIS.md` §9, §12].

## Accounts & login

**I forgot my password.** Use **Forgot password?** on Sign In. In the demo, mail mode is `log`, so
the reset token appears in the auth-service logs rather than an inbox
[VERIFIED: `auth-service/.env.example`].

**Does Google sign-in work?** No — it is a **placeholder**. The UI exists but the provider handoff
is stubbed, and it is gated by `ENABLE_GOOGLE_AUTH` (default off) [VERIFIED].

**Why was I logged out?** Access tokens last 15 minutes and refresh tokens 7 days. A failed silent
refresh logs you out [VERIFIED: `api_docs.md` §1].

## Feed, posts, search

**Why can't I edit a post?** Edit calls `PATCH /posts/{post_id}`, which is **not implemented** on
the backend and returns `404` [VERIFIED: `api_docs.md` §6, §15].

**Why are search results limited?** Search fans out to `GET /users/search` and `GET /posts`; the
minimum query length is 2 characters and recent history is stored only on your device
[VERIFIED: `api_docs.md` §13].

**Do push notifications work?** No. The in-app notifications inbox works (REST), but **device push
(FCM) is disabled** — no Firebase packages or `google-services.json` [VERIFIED].

## Jobs & CV

**Is the AI CV real?** **Yes** — `POST /ai/cv/generate` calls the real LLM via `ai_core`
(OpenRouter GLM by default) [VERIFIED: `_meta/EVIDENCE-BASIS.md` §6].

**Why is my AI CV incomplete?** If your profile/posts are too sparse, the server returns an
"incomplete profile" message without calling the LLM. A mapper field-name mismatch can also drop
some fields [VERIFIED: `api_docs.md` §10, `../06-api/12-ai-api.md` §5].

**Where do job listings come from?** Job listings are content posts (`GET /posts?type=JOB`); there
is no `GET /jobs` controller [VERIFIED: `api_docs.md` §7, §15].

## Finance

**Can I pay my tuition in the app?** No. The finance feature is a **read-only fee/payment viewer**.
"Pay with ACLEDA" deep-links into the official ACLEDA Mobile app; the in-app payment screen is a
**preview flow that processes no real payment** [VERIFIED].

**Why is Finance locked for me?** Finance requires the `STUDENT` role, obtained via
`POST /students/verify`; otherwise the API returns `403` [VERIFIED].

## Chat & AI

**Is the AI chat a real assistant?** **No** — Vithey AI chat returns **canned stub replies** by
topic. There is **no RAG and no GDCE**. Only CV generation is LLM-backed [VERIFIED: `_meta/EVIDENCE-BASIS.md` §6].

**Are calls/video real?** No — chat calls and video are **simulated** UI only [VERIFIED: `chat_repository.dart`].

**Can I send files to Vithey AI?** The composer offers attachments, but they are folded into the
prompt text, not processed; the UI labels attachments "coming soon" [VERIFIED: `chatbot_controller.dart`].

## Map

**The map shows a config error.** `map-service` needs a server-side `GOOGLE_PLACES_API_KEY` and is
only started under the `map` Compose profile [VERIFIED].

## Settings

**Which settings are placeholders?** Two-Factor Authentication, Biometric Login, Data & storage,
Accessibility, and chatbot history search are **"coming soon"** [VERIFIED].

**Can I use Khmer?** You can select Khmer, and it is stored as a preference (and used as a CV
language label), but app UI strings are currently hardcoded in English (no `.arb` files)
[VERIFIED: `_meta/EVIDENCE-BASIS.md` §7].

## Troubleshooting

**The app can't reach the server.** Start the demo stack
(`backend/scripts/docker-up-demo.ps1`) and confirm `http://localhost:8080/actuator/health`. On a
device, set `API_BASE_URL` to the PC LAN IP; on an emulator use `10.0.2.2` [VERIFIED `api_docs.md` §1].

**Everything looks like demo data.** Mocks are on. Set the `USE_MOCK_*` flags to `false` in `.env`
— live API is the default when flags are unset [VERIFIED: `.env.example`].

**I see "Something went wrong" everywhere.** The gateway or a dependent service is down; check the
demo stack and Eureka (`:8761`) [VERIFIED].

## Related

- [01-user-manual.md](01-user-manual.md) · [02-login-registration.md](02-login-registration.md) · [06-finance-guide.md](06-finance-guide.md) · [08-ai-assistant-guide.md](08-ai-assistant-guide.md)
- Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)
