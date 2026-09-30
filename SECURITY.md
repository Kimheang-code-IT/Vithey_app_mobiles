# Security Policy

## Reporting a vulnerability

Please report security issues **privately**. Do not open a public issue for a
suspected vulnerability.

Use GitHub's private reporting mechanism for this repository:

- **GitHub Security Advisories** — "Report a vulnerability" on the repository's
  Security tab:
  <https://github.com/Kimheang-code-IT/Vithey_app_mobiles/security/advisories/new>

If that is unavailable to you, open a minimal issue titled `Security contact
request` that contains **no sensitive detail**, and a maintainer will arrange a
private channel.

Please include:

- a description of the issue and its impact,
- steps to reproduce,
- affected component(s) and version/commit,
- any suggested remediation.

Do **not** include secrets, credentials, or personal data in the report beyond
what is strictly necessary.

## Never include credentials in public issues

Never paste any of the following into issues, pull requests, discussions, or
commit messages:

- passwords, tokens, session cookies,
- API keys and OAuth client secrets (`client_secret*.json`),
- `.env` values,
- private keys, keystores, or certificates,
- database connection strings with credentials.

If you accidentally expose a secret, treat it as compromised: rotate/revoke it
immediately and notify a maintainer.

## Supported versions

This project is under active development and has no released version yet.
Security fixes are applied to the `dev` branch and promoted to `main`. Until a
release policy exists, only the latest `main` is considered supported.

## Responsible disclosure

We follow a coordinated disclosure approach:

1. You report privately.
2. We acknowledge and investigate.
3. We prepare and validate a fix on `dev`.
4. The fix is promoted to `main` through the normal review process.
5. We credit reporters who wish to be acknowledged (with your consent).

Please give us reasonable time to remediate before any public disclosure.

## Secret handling in this repository

- Only placeholder example files (`.env.example`) are committed.
- Real credentials live outside version control (local-only, e.g. the
  git-ignored `vithey-secrets/` folder) or in a secret manager / GitHub Secrets.
- `.gitignore` blocks `.env`, `client_secret*.json`, key material, and
  `vithey-secrets/`.
