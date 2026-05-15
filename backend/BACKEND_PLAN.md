# Backend Plan — Manifest & Match
**Strategy: Lightweight API Proxy → Full Backend when needed**

---

## Phase 1 — API Proxy (Cloudflare Workers)

### Why Cloudflare Workers
- Free tier: 100,000 requests/day, 10ms CPU time
- Zero infrastructure to manage (no servers, no Docker)
- Deploys in seconds via `wrangler deploy`
- TypeScript-native
- Grows into full backend: add Cloudflare D1 (SQLite), KV (key-value), R2 (storage) as needed
- Code you write here is portable to Node.js if you ever need to migrate

### Phase 1 Endpoints (Required Before App Store)

**1. Job Search Proxy**
```
GET /api/jobs?query=<title>&location=<loc>&page=<n>
```
Proxies to JSearch API. Hides `X-RapidAPI-Key` from app binary.
App calls this endpoint — never calls JSearch directly.

**2. Affiliate URL Builder**
```
POST /api/affiliate/url
Body: { provider: "coursera" | "udemy", courseUrl: string, courseId: string }
Returns: { affiliateUrl: string }
```
Builds Rakuten LinkShare URL (Coursera) or appends referral code (Udemy).
Hides affiliate credentials from app binary.
App sends course URL → gets back affiliate URL → opens in Safari.

### Phase 1 Non-Endpoints (stay on-device)
- Thompson Sampling scoring — on-device (performance-critical, <10ms)
- Core Data persistence — on-device (privacy)
- Foundation Models inference — on-device (the whole point)
- Ad injection (AdMob SDK) — on-device (AdMob manages this)
- Course recommendations — on-device (NLEmbedding + static JSON)

---

## Phase 2 — If/When Needed

Add these endpoints to the same Worker when the need arises:

**User Auth** — if cross-device sync becomes a feature
```
POST /api/auth/register
POST /api/auth/login
GET  /api/auth/me
```
Use Cloudflare D1 (SQLite) for user records.
No passwords — Sign in with Apple only.

**Anonymous Analytics Aggregation** — if you need aggregate product metrics
```
POST /api/analytics/session
Body: { adImpressions: int, courseClicks: int, swipeCount: int, date: string }
```
Aggregates — no user identifiers.
Store in Cloudflare D1.

**Push Notifications** — if job alerts are added
```
POST /api/notifications/register
Body: { deviceToken: string, searchQuery: string }
```
Schedule via Cloudflare Cron Triggers.

---

## Setup (Phase 1)

### Prerequisites
- Cloudflare account (free) — cloudflare.com
- Node.js + `npm install -g wrangler` (Cloudflare CLI)
- JSearch API key from RapidAPI
- Coursera affiliate ID (Rakuten LinkShare)
- Udemy referral code

### File Structure
```
backend/
├── BACKEND_PLAN.md          ← This file
├── wrangler.toml            ← Cloudflare config (created during setup)
├── package.json
├── src/
│   ├── index.ts             ← Route handler
│   ├── routes/
│   │   ├── jobs.ts          ← JSearch proxy
│   │   └── affiliate.ts     ← Affiliate URL builder
│   └── types.ts
└── test/
    └── routes.test.ts
```

### Secrets (stored in Cloudflare, NOT in code)
```bash
wrangler secret put JSEARCH_API_KEY
wrangler secret put COURSERA_AFFILIATE_ID
wrangler secret put UDEMY_REFERRAL_CODE
```
These are never committed to git. Never in the iOS app binary.

### Deploy
```bash
cd backend/
wrangler deploy
# → https://manifest-match-api.YOUR_SUBDOMAIN.workers.dev
```

---

## iOS App Configuration

The app gets the backend URL from a config plist (not hardcoded):
```swift
// Config.plist
BACKEND_BASE_URL = https://manifest-match-api.YOUR_SUBDOMAIN.workers.dev

// App reads:
let backendURL = Bundle.main.infoDictionary?["BACKEND_BASE_URL"] as? String
```

Different values per scheme:
- Debug: `http://localhost:8787` (local `wrangler dev`)
- Release: `https://manifest-match-api.YOUR_SUBDOMAIN.workers.dev`

---

## Security Notes

- All endpoints are unauthenticated in Phase 1 (no user accounts yet)
- Rate limiting: Cloudflare provides basic rate limiting on free tier (10 req/s per IP)
- CORS: Allow only the app's bundle ID (not a web domain)
- No user data stored on server in Phase 1

---

## When to Move to Phase 2

Trigger Phase 2 backend work when:
- You want cross-device sync (user logs into app on new phone)
- You need aggregate analytics (how many course clicks per day?)
- You want push notifications (job alert when a new matching job posts)
- Workers free tier is consistently hitting 100k req/day limit

None of these are Day 1 concerns. Phase 1 is all that's needed for App Store launch.
