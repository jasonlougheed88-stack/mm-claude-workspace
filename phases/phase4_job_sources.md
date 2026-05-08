# Phase 4 — Job Source Diversity

## Current: JSearch only (OpenWebNinja, paid)

## Free Sources Ready to Enable (no keys needed)
- **Greenhouse** — 62 major companies posting directly (Google, Airbnb, etc.)
- **Lever** — 50 companies (Shopify, Netflix, etc.)
- Enable by uncommenting registerCompanyAPISources() in JobDiscoveryCoordinator.swift line ~1301

## Free Sources Needing Keys
- **Jobicy** — remote jobs, free API
- **RemoteOK** — remote only, public API (no key)
- **USAJobs** — US government jobs, free registration
- **Adzuna** — broad aggregator, free tier (app_id + app_key)

## Disabled by User Request (revisit later)
- Jooble
- RSS feeds

## SmartSourceSelector
Already built — routes queries to best sources based on user profile.
Healthcare user → USAJobs weighted higher.
Remote preference → RemoteOK + Jobicy weighted higher.
