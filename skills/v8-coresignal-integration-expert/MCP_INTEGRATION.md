# CoreSignal MCP Server Integration Guide

**Using Model Context Protocol for Fastest Integration**

---

## What is MCP?

**Model Context Protocol (MCP)** lets you access CoreSignal API through tools instead of writing HTTP clients. Think of it as having CoreSignal API functions directly available in your development environment.

### Benefits vs REST API

| Feature | MCP Server | REST API Client |
|---------|------------|-----------------|
| **Setup Time** | 5 minutes | 2-4 hours |
| **Code Required** | ~50 lines | ~500 lines |
| **Maintenance** | Auto-updates | Manual updates |
| **Error Handling** | Built-in | Manual implementation |
| **Rate Limiting** | Handled by MCP | Manual implementation |
| **Testing** | Immediate | Requires test harness |

---

## Your MCP Configuration

### Current Setup

**API Key**: `9S5q3ZSpmUM8gnUm65gCvboj1SfVSFEn`
**MCP Server**: `https://mcp.coresignal.com/mcp`

**MCP Config** (already configured):
```json
{
  "mcpServers": {
    "coresignal_data_api": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://mcp.coresignal.com/mcp",
        "--header",
        "apikey:${AUTH_HEADER}"
      ],
      "env": {
        "AUTH_HEADER": "9S5q3ZSpmUM8gnUm65gCvboj1SfVSFEn"
      }
    }
  }
}
```

**Location**: `/Users/jasonl/.claude/mcp.json` or Claude Desktop settings

---

## How to Enable MCP Server

### Option 1: Claude Desktop (Easiest)

1. Open Claude Desktop settings
2. Navigate to "Developer" → "Edit Config"
3. Add the MCP server configuration above
4. Restart Claude Desktop
5. Verify: Type "search jobs on coresignal" and see if tools appear

### Option 2: Claude Code CLI

```bash
# Add to ~/.claude/mcp.json
mkdir -p ~/.claude
cat > ~/.claude/mcp.json <<'EOF'
{
  "mcpServers": {
    "coresignal_data_api": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://mcp.coresignal.com/mcp",
        "--header",
        "apikey:${AUTH_HEADER}"
      ],
      "env": {
        "AUTH_HEADER": "9S5q3ZSpmUM8gnUm65gCvboj1SfVSFEn"
      }
    }
  }
}
EOF

# Restart Claude Code session
```

### Option 3: Project-Specific MCP

**Location**: `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/.claude/mcp.json`

```bash
cd "/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8"
mkdir -p .claude
cat > .claude/mcp.json <<'EOF'
{
  "mcpServers": {
    "coresignal_data_api": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://mcp.coresignal.com/mcp",
        "--header",
        "apikey:${AUTH_HEADER}"
      ],
      "env": {
        "AUTH_HEADER": "9S5q3ZSpmUM8gnUm65gCvboj1SfVSFEn"
      }
    }
  }
}
EOF
```

---

## Available MCP Tools

Once enabled, these tools will be available:

### 1. `mcp__coresignal_data_api__search_jobs`

**Purpose**: Search jobs with Elasticsearch DSL query

**Parameters**:
```typescript
{
  query: string,           // Elasticsearch DSL JSON string
  limit?: number,          // Max results (default: 50)
  preview?: boolean        // Preview without using credits
}
```

**Example**:
```swift
// Search for iOS jobs in San Francisco
let query = """
{
  "query": {
    "bool": {
      "must": [
        {
          "multi_match": {
            "query": "iOS Developer",
            "fields": ["title^3", "description"]
          }
        }
      ],
      "filter": [
        { "term": { "city": "San Francisco" } }
      ]
    }
  },
  "from": 0,
  "size": 20
}
"""

// Call MCP tool (syntax depends on how Swift accesses MCP)
```

### 2. `mcp__coresignal_data_api__get_job`

**Purpose**: Get full details for a specific job

**Parameters**:
```typescript
{
  job_id: string           // CoreSignal job ID
}
```

**Example**:
```swift
// Fetch job details
let jobDetails = await mcp_tool_call(
  tool: "mcp__coresignal_data_api__get_job",
  params: ["job_id": "abc123xyz"]
)
```

### 3. `mcp__coresignal_data_api__preview_search`

**Purpose**: Test query without using credits

**Parameters**:
```typescript
{
  query: string            // Elasticsearch DSL JSON string
}
```

---

## Integration Pattern for V8

### Approach 1: MCP-First with REST Fallback

```swift
// CoreSignalAPIClient.swift (MCP-aware version)

import Foundation
import V7Core
import V7Thompson

actor CoreSignalAPIClient: JobSourceProtocol {

    let sourceIdentifier = "coresignal"

    // Try MCP first, fall back to REST
    func fetchJobs(query: JobSearchQuery, limit: Int) async throws -> [RawJobData] {

        // Check if MCP server is available
        if await isMCPAvailable() {
            return try await fetchJobsViaMCP(query: query, limit: limit)
        } else {
            return try await fetchJobsViaREST(query: query, limit: limit)
        }
    }

    private func isMCPAvailable() async -> Bool {
        // Check if MCP tools are accessible
        // Implementation depends on how Claude Code exposes MCP to Swift
        return false  // TODO: Implement MCP detection
    }

    private func fetchJobsViaMCP(query: JobSearchQuery, limit: Int) async throws -> [RawJobData] {
        // Build Elasticsearch query
        let elasticsearchQuery = buildElasticsearchQuery(from: query, limit: limit)

        // Serialize to JSON string
        let jsonData = try JSONSerialization.data(withJSONObject: elasticsearchQuery)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        // Call MCP tool
        // TODO: Implement MCP tool calling mechanism
        // let response = await MCPClient.call(
        //     tool: "mcp__coresignal_data_api__search_jobs",
        //     params: ["query": jsonString, "limit": limit]
        // )

        // Parse response and normalize
        // return normalizeJobs(response)

        throw JobSourceError.notImplemented("MCP integration pending")
    }

    private func fetchJobsViaREST(query: JobSearchQuery, limit: Int) async throws -> [RawJobData] {
        // Existing REST API implementation
        // (See SKILL.md Part 3 for complete code)
        return []
    }
}
```

### Approach 2: Pure MCP (No REST Client)

If MCP server is always available in your environment:

```swift
actor CoreSignalMCPClient: JobSourceProtocol {

    let sourceIdentifier = "coresignal_mcp"

    func fetchJobs(query: JobSearchQuery, limit: Int) async throws -> [RawJobData] {
        // Build query
        let elasticsearchQuery = buildElasticsearchQuery(from: query, limit: limit)
        let jsonString = try serializeQuery(elasticsearchQuery)

        // Call MCP directly
        let response = try await callMCPTool(
            name: "mcp__coresignal_data_api__search_jobs",
            params: ["query": jsonString, "limit": limit]
        )

        return try parseAndNormalizeResponse(response)
    }

    private func callMCPTool(name: String, params: [String: Any]) async throws -> Data {
        // TODO: Implement based on how V8 accesses MCP tools
        // This might be through:
        // 1. Swift Package that wraps MCP protocol
        // 2. Bridge to Claude Code CLI
        // 3. HTTP requests to local MCP server
        throw JobSourceError.notImplemented("MCP tool calling pending")
    }
}
```

---

## Testing MCP Integration

### Test 1: Verify MCP Server is Running

```bash
# In terminal with Claude Code
npx mcp-remote https://mcp.coresignal.com/mcp --header "apikey:9S5q3ZSpmUM8gnUm65gCvboj1SfVSFEn"
```

### Test 2: Simple Job Search

Ask Claude Code:
```
Search for "Software Engineer" jobs in San Francisco using CoreSignal MCP
```

Expected: Claude Code will use `mcp__coresignal_data_api__search_jobs` tool

### Test 3: Preview Query (No Credits)

```
Preview CoreSignal query for iOS jobs (don't use credits)
```

Expected: Claude Code uses `mcp__coresignal_data_api__preview_search`

---

## UserProfile → MCP Query Builder

```swift
func buildMCPQueryFromUserProfile(_ profile: UserProfile) -> String {
    var mustClauses: [[String: Any]] = []
    var filterClauses: [[String: Any]] = []

    // Title from desired roles
    if let roles = profile.desiredRoles, !roles.isEmpty {
        mustClauses.append([
            "multi_match": [
                "query": roles.joined(separator: " "),
                "fields": ["title^3", "description"],
                "type": "best_fields"
            ]
        ])
    }

    // Location
    if let city = profile.primaryLocationCity {
        filterClauses.append(["term": ["city": city]])
    }

    // Remote preference
    if profile.remotePreference == "remote" {
        mustClauses.append(["term": ["accepts_remote": true]])
    }

    // Salary range
    if let minSalary = profile.salaryMin?.intValue,
       let maxSalary = profile.salaryMax?.intValue {
        filterClauses.append([
            "nested": [
                "path": "salary",
                "query": [
                    "bool": [
                        "must": [
                            ["range": ["salary.min_value": ["gte": minSalary]]],
                            ["range": ["salary.max_value": ["lte": maxSalary]]]
                        ]
                    ]
                ]
            ]
        ])
    }

    // Build final query
    let query: [String: Any] = [
        "query": [
            "bool": [
                "must": mustClauses,
                "filter": filterClauses
            ]
        ],
        "from": 0,
        "size": 50,
        "sort": [
            ["date_posted": "desc"]
        ]
    ]

    // Serialize to JSON string
    let jsonData = try! JSONSerialization.data(withJSONObject: query)
    return String(data: jsonData, encoding: .utf8)!
}
```

---

## MCP vs REST: When to Use Each

### Use MCP When:
✅ Rapid prototyping (get jobs in 5 minutes)
✅ Claude Code environment with MCP support
✅ Don't want to maintain HTTP client code
✅ Want automatic API updates
✅ Testing queries interactively

### Use REST API When:
✅ Production iOS app (MCP not available on device)
✅ Need offline caching
✅ Custom retry logic required
✅ Specific performance optimizations
✅ Air-gapped environments

### Hybrid Approach (RECOMMENDED):
1. **Development**: Use MCP for fast iteration
2. **Production**: Use REST API in shipped iOS app
3. **Testing**: Use MCP for quick API validation

---

## Next Steps

### Immediate (5 minutes):
1. ✅ Add MCP config to `~/.claude/mcp.json`
2. ✅ Restart Claude Code session
3. ✅ Test: "Search CoreSignal for iOS jobs"
4. ✅ Verify MCP tools are available

### Short-term (1 hour):
1. Build UserProfile → Query mapper
2. Test with real user data
3. Verify results quality
4. Check credit usage

### Long-term (1 day):
1. Decide: MCP-only or Hybrid approach
2. Implement chosen pattern in V8
3. Add to JobDiscoveryCoordinator as 11th source
4. Performance test vs existing sources

---

## Troubleshooting

### MCP Server Not Available
**Problem**: Tools don't appear
**Solution**:
1. Check `~/.claude/mcp.json` exists
2. Verify API key is correct
3. Restart Claude Code
4. Check network connectivity to `https://mcp.coresignal.com/mcp`

### Authentication Errors
**Problem**: 401 Unauthorized
**Solution**:
1. Verify API key: `9S5q3ZSpmUM8gnUm65gCvboj1SfVSFEn`
2. Check it's set in `env.AUTH_HEADER`
3. Get new key from https://dashboard.coresignal.com/

### Rate Limits
**Problem**: Too many requests
**Solution**:
1. Use `preview_search` for testing (no credits)
2. Implement caching in V8
3. Batch requests

---

**Summary**: MCP Server is the FASTEST way to integrate CoreSignal. Use it for development, then decide if you need REST API for production iOS app.
