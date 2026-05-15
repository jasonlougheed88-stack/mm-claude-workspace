# Tab 1: CRM (Application Tracker)

Tracks job applications. Fed entirely by the apply action in Tab 0. User manages their active job pipeline here.

```mermaid
flowchart TD
    subgraph SOURCE["What Writes to CRM"]
        APPLY["Tab 0: Tap Apply Now"]
        AT_WRITE["ApplicationTracker.addApplication\nstatus: applied, date: now, job metadata"]
    end

    subgraph STORE["Data Store"]
        AT[("ApplicationTracker\nSwiftData — separate from Core Data")]
    end

    subgraph CRM_UI["Tab 1 UI — ApplicationHistoryView"]
        FILTER["Filter by status"]
        SEARCH["Search applications"]
        NOTES["Notes per application"]
        ACTIVITY["Activity timeline"]
        ANALYTICS["Application analytics"]
    end

    APPLY --> AT_WRITE --> AT
    AT --> FILTER
    AT --> SEARCH
    AT --> NOTES
    AT --> ACTIVITY
    AT --> ANALYTICS
```

## Status in v1.1

- Data store: working (SwiftData, self-contained)
- UI: working (ApplicationHistoryView)
- Apply action write: **was disconnected in V7/V8 — wired correctly in v1.1**

## Gaps

- No push notifications for status changes
- Status updates (applied → interview → offer → rejected) are manual only — no external data source
- No connection to scoring engine — applying to a job doesn't currently change how the deck scores similar jobs
