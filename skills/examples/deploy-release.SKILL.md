---
name: deploy-release
description: Guide and perform a FULL production release for ONE site — build from main, deploy to the dev environment, promote dev → test → live, then cut the GitHub release + changelog. Trigger when the user wants to release, ship to production, go live, promote, or generate release notes. For deploying an arbitrary branch to a review environment, use the deploy-multidev skill instead.
---

<!-- Sanitized example from a production multi-site deployment (PaaS-hosted
     CMS + SPA). Site names, tokens, and infrastructure specifics replaced
     with placeholders. The transferable parts: the 🟢/🔴 execution model,
     tee-to-log, one-site-per-run, and explicit input gathering. -->

# Full Release (`main` → Live)

Performs a **full production release** for **one site**: build from `main`, deploy to **Dev**, promote **Dev → Test → Live**, then cut the **GitHub release + changelog**.

> Just need a branch on a review environment? Use `deploy-multidev` — this skill is production-only and `main`-only.

Shared reference (site table, build internals, one-time setup, troubleshooting): `_deploy-common/deploy-reference.md` — read it before running.

## Execution model — who runs what

You (the agent) **drive every step except the two that move code to production.**

- 🟢 **Agent runs**: git preflight on `main` (clean tree, up to date), environment restart, SSH-agent check, production build, hosting-CLI auth *check*, tag math, `generate:release-notes`, and the GitHub release via `gh`. None of these are destructive; on a healthy setup all are non-interactive.
- 🔴 **Human runs — the deploy/promote commands only**: the deploy-to-Dev and the Test/Live promotions. The deploy has an interactive *"commit and deploy?"* prompt — a human must review the change-set — and Live is production. Offer each command **tee'd to a log** so you read the outcome yourself instead of asking for a paste:

  ```bash
  {deploy-command} 2>&1 | tee /tmp/deploy-dev.log
  ```

  After the human reports it finished, **read the log** and decide the next step from evidence.

**One site per run.** Releasing several sites = several runs of this skill, each with its own transcript.

## Step 0 — Gather inputs (ask, don't assume)

Collect via explicit question, before any command:

1. **Target site** — resolve to its environment name and hosting project via the site table in the shared reference. ⚠️ If two sites share an app-level identifier but deploy to different hosting projects, pin the exact one with the user — never assume.
2. **Cut the GitHub release at the end?** — tag + changelog + release, once code is Live.

## Step 1 — Preflight 🟢

- `git status` clean, on `main`, synced with origin
- environment up; SSH agent loaded; hosting CLI authenticated (check, don't login blind — hand the login to the human if a browser/passphrase is involved)
- production build succeeds locally

Any red here **stops the run** before anything moved.

## Step 2 — Deploy to Dev 🔴 (human)

Hand over the exact command (tee'd). When it returns: read the log; verify the deployed hash matches the built one.

## Step 3 — Promote Dev → Test → Live 🔴 (human)

One promotion at a time, log each, verify each before offering the next. Live only after Test is verified.

## Step 4 — Release notes + GitHub release 🟢

Compute the next tag, generate the changelog since the previous tag, create the GitHub release with `gh`. Link the release in the final summary, alongside the log paths for the whole run.
