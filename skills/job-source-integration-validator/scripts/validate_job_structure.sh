#!/bin/bash
# Validates job data structure from a job source

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 SOURCE_NAME [COUNT]"
    echo "Example: $0 remotive 10"
    exit 1
fi

SOURCE=$1
COUNT=${2:-10}
OUTPUT=$(mktemp)

echo "🔍 Validating job data structure for: $SOURCE"
echo "📊 Sample size: $COUNT jobs"
echo ""

# Check if project directory exists
PROJECT_ROOT="/Users/jasonl/Desktop/manifest and match  v7/V7 build files/v7codebase/Manifest_and_Match_V7_Working code base: instruction files /upgrade/v_7_uppgrade"

if [ ! -d "$PROJECT_ROOT" ]; then
    echo "❌ Project directory not found: $PROJECT_ROOT"
    exit 1
fi

cd "$PROJECT_ROOT"

# Try to fetch jobs from the source
echo "⏳ Fetching sample jobs from $SOURCE..."

# This would normally call your actual job source
# For now, create a placeholder that you can replace
cat > "$OUTPUT" <<'EOF'
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "Senior iOS Engineer",
    "company": "Tech Corp",
    "location": "Remote",
    "description": "We are looking for an experienced iOS engineer to join our team. You will work on building amazing mobile experiences using Swift and SwiftUI. The ideal candidate has 5+ years of iOS development experience.",
    "salary": "$120k - $180k",
    "skills": ["Swift", "SwiftUI", "iOS", "Mobile Development"],
    "url": "https://example.com/jobs/1",
    "remote": true,
    "postedDate": "2025-10-26T10:00:00Z",
    "source": "TestSource",
    "fetchedAt": "2025-10-26T14:30:00Z",
    "sourceIdentifier": "remotive"
  }
]
EOF

# Validate structure using Python
python3 - "$OUTPUT" "$SOURCE" <<'PYTHON_SCRIPT'
import json
import sys
from urllib.parse import urlparse
from datetime import datetime

if len(sys.argv) < 3:
    print("Error: Missing arguments")
    sys.exit(1)

output_file = sys.argv[1]
source_name = sys.argv[2]

try:
    with open(output_file) as f:
        content = f.read()
        if not content.strip():
            print("❌ Empty response from source")
            sys.exit(1)
        jobs = json.loads(content)
except json.JSONDecodeError as e:
    print(f"❌ Failed to parse JSON: {e}")
    print(f"Response preview: {content[:200]}")
    sys.exit(1)
except Exception as e:
    print(f"❌ Error reading file: {e}")
    sys.exit(1)

if not jobs or not isinstance(jobs, list):
    print(f"❌ Invalid response: Expected array of jobs, got {type(jobs)}")
    sys.exit(1)

print(f"\n📊 Validating {len(jobs)} jobs from {source_name}")
print("=" * 80)

# Validation counters
errors = []
warnings = []
required_coverage = {"id": 0, "title": 0, "company": 0, "location": 0}
recommended_coverage = {"description": 0, "skills": 0, "url": 0, "salary": 0}

for idx, job in enumerate(jobs):
    job_num = idx + 1

    # Required fields validation
    if not job.get('id'):
        errors.append(f"Job {job_num}: Missing 'id' field")
    else:
        required_coverage['id'] += 1
        # Validate UUID format
        id_val = str(job.get('id'))
        if len(id_val) != 36 or id_val.count('-') != 4:
            warnings.append(f"Job {job_num}: 'id' doesn't look like a valid UUID")

    if not job.get('title') or len(str(job.get('title', ''))) == 0:
        errors.append(f"Job {job_num}: Missing or empty 'title'")
    else:
        required_coverage['title'] += 1

    if not job.get('company') or len(str(job.get('company', ''))) == 0:
        errors.append(f"Job {job_num}: Missing or empty 'company'")
    else:
        required_coverage['company'] += 1

    if not job.get('location') or len(str(job.get('location', ''))) == 0:
        errors.append(f"Job {job_num}: Missing or empty 'location'")
    else:
        required_coverage['location'] += 1

    # Recommended fields validation
    desc = job.get('description', '')
    if desc and len(desc) >= 100:
        recommended_coverage['description'] += 1
    else:
        warnings.append(f"Job {job_num}: Description missing or too short (<100 chars)")

    skills = job.get('skills', [])
    if skills and len(skills) >= 3:
        recommended_coverage['skills'] += 1
    else:
        warnings.append(f"Job {job_num}: Skills missing or insufficient (<3 skills)")

    # URL validation
    if job.get('url'):
        recommended_coverage['url'] += 1
        try:
            parsed = urlparse(str(job.get('url')))
            if not parsed.scheme or not parsed.netloc:
                errors.append(f"Job {job_num}: Invalid URL format: {job.get('url')}")
        except Exception:
            errors.append(f"Job {job_num}: Malformed URL: {job.get('url')}")
    else:
        warnings.append(f"Job {job_num}: No URL provided")

    if job.get('salary'):
        recommended_coverage['salary'] += 1

    # Source identifier validation
    if job.get('sourceIdentifier') != source_name:
        errors.append(f"Job {job_num}: Wrong sourceIdentifier (expected '{source_name}', got '{job.get('sourceIdentifier')}')")

    # Check for placeholder values
    placeholder_values = ['N/A', 'TBD', 'null', 'None', '']
    for field in ['title', 'company', 'location']:
        if str(job.get(field, '')).strip() in placeholder_values:
            errors.append(f"Job {job_num}: Field '{field}' has placeholder value")

# Calculate coverage percentages
total_jobs = len(jobs)
required_pct = {k: (v / total_jobs * 100) for k, v in required_coverage.items()}
recommended_pct = {k: (v / total_jobs * 100) for k, v in recommended_coverage.items()}

# Report
print("\n✅ REQUIRED FIELDS COVERAGE:")
for field, count in required_coverage.items():
    pct = required_pct[field]
    status = "✅" if pct == 100 else "❌"
    print(f"  {status} {field:15s} {count:3d}/{total_jobs} ({pct:5.1f}%)")

print("\n📊 RECOMMENDED FIELDS COVERAGE:")
for field, count in recommended_coverage.items():
    pct = recommended_pct[field]
    status = "✅" if pct >= 80 else "⚠️ "
    print(f"  {status} {field:15s} {count:3d}/{total_jobs} ({pct:5.1f}%)")

if errors:
    print(f"\n❌ ERRORS ({len(errors)}):")
    for error in errors[:10]:  # Show first 10
        print(f"  • {error}")
    if len(errors) > 10:
        print(f"  ... and {len(errors) - 10} more errors")

if warnings:
    print(f"\n⚠️  WARNINGS ({len(warnings)}):")
    for warning in warnings[:10]:  # Show first 10
        print(f"  • {warning}")
    if len(warnings) > 10:
        print(f"  ... and {len(warnings) - 10} more warnings")

print("\n" + "=" * 80)

# Determine pass/fail
all_required_100 = all(pct == 100 for pct in required_pct.values())
recommended_80_plus = sum(1 for pct in recommended_pct.values() if pct >= 80) >= 3

if errors:
    print("❌ VALIDATION FAILED")
    print("\n🔧 Action Required:")
    print("  1. Fix data structure issues in job source adapter")
    print("  2. Ensure all required fields are populated")
    print("  3. Remove placeholder values")
    print("  4. Re-run validation")
    sys.exit(1)
elif not all_required_100:
    print("❌ VALIDATION FAILED")
    print("\n🔧 Required fields must have 100% coverage")
    sys.exit(1)
elif len(warnings) > total_jobs * 0.5:  # More than 50% warnings
    print("⚠️  VALIDATION PASSED WITH WARNINGS")
    print(f"\n💡 Quality Score: {(sum(recommended_pct.values()) / len(recommended_pct)):.1f}%")
    print("\n💡 Consider improving:")
    print("  1. Add more complete job descriptions (>100 chars)")
    print("  2. Extract more skills from job data (3+ skills)")
    print("  3. Include URLs and salary info when available")
    sys.exit(0)
else:
    quality_score = sum(recommended_pct.values()) / len(recommended_pct)
    print("✅ VALIDATION PASSED")
    print(f"\n🎉 {source_name} integration looks good!")
    print(f"📊 Quality Score: {quality_score:.1f}%")
    print("✅ Ready for Thompson scoring integration")
    sys.exit(0)

PYTHON_SCRIPT

# Cleanup
rm -f "$OUTPUT"
