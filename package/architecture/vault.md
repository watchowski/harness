---
component: vault
tier: 1+
status: active
rev: v3-2026-07-23
supersedes: (new in v3)
model-limitation: Agents with direct access to plaintext credentials can leak them to logs, tool outputs, or misdirected tool calls; the blast radius of a mistake grows with credential scope.
source: Lance Martin — Claude for Long-Horizon Tasks (Anthropic)
---

# Credential Vault

**Active at Step 1.** Isolation cost is trivial; blast-radius benefit is real regardless of parallelism level.

## Rule

The model context never sees plaintext long-lived credentials. All secrets are requested by role from a vault that returns short-lived, scope-limited tokens for a single tool invocation.

## Minimum viable implementation per platform

You do not need enterprise secret management to satisfy this principle:

- **Claude Code:** use `settings.json` `env` or system credential manager (macOS Keychain, Windows Credential Manager, `pass`). Never inline secrets in CLAUDE.md.
- **Codex:** environment variables sourced from a `.env` outside the repo; never commit; add to `.gitignore`.
- **Antigravity / OpenCode:** same — env vars from a directory the agent cannot read directly.

The specific mechanism matters less than the principle: **the agent must not have plaintext long-lived credentials in its context or on its file-read path.**

## Every access is logged

At Step 3+, vault access emits a `vault.access` event to the session log (P07). At Step 1–2 without an event log, log via the tool's native telemetry (Claude Code analytics; equivalent for other tools).

## Rotation

Any credential that appeared in a session log — even a hashed reference — is treated as compromised at session close and rotated. The vault owns rotation; the harness does not.

## Anti-patterns

- `sk-...` keys pasted into a prompt "just for this run."
- Long-lived API tokens baked into the tool's global instruction file.
- A single credential with all-project scope handed to every agent.
