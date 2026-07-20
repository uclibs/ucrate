#!/usr/bin/env bash
# Gate on merged SimpleCov line coverage vs coverage/coverage_baseline.txt.
# Fails only if coverage drops more than TOLERANCE percentage points.
# On pull_request, ratchets the baseline upward when coverage improves.
set -euo pipefail

TOLERANCE="${COVERAGE_TOLERANCE:-0.5}"
BASELINE_PATH="coverage/coverage_baseline.txt"
MERGED_PATH="coverage/merged_coverage.txt"
UPDATE_BASELINE="${UPDATE_COVERAGE_BASELINE:-false}"

round2() {
  # Normalize to two decimal places (avoids float/display flap).
  printf '%.2f' "$1"
}

if [ -f "$MERGED_PATH" ]; then
  COVERAGE_RAW="$(tr -d '[:space:]' < "$MERGED_PATH")"
elif [ -f coverage/index.html ]; then
  COVERAGE_RAW="$(grep -oE '[0-9]+\.[0-9]+%' coverage/index.html | head -n1 | tr -d '%')"
else
  echo "Merged coverage not found (expected $MERGED_PATH or coverage/index.html)."
  find coverage -maxdepth 2 -type f -print 2>/dev/null || true
  exit 1
fi

if [ -z "${COVERAGE_RAW}" ]; then
  echo "Unable to parse merged coverage percentage."
  exit 1
fi

if [ ! -f "$BASELINE_PATH" ]; then
  echo "Coverage baseline file not found: $BASELINE_PATH"
  exit 1
fi

COVERAGE="$(round2 "$COVERAGE_RAW")"
BASELINE="$(round2 "$(tr -d '[:space:]' < "$BASELINE_PATH")")"
FLOOR="$(round2 "$(echo "$BASELINE - $TOLERANCE" | bc -l)")"

echo "Current coverage:  ${COVERAGE}%"
echo "Baseline coverage: ${BASELINE}%"
echo "Allowed floor:     ${FLOOR}% (baseline - ${TOLERANCE})"

if (( $(echo "$COVERAGE < $FLOOR" | bc -l) )); then
  echo "Coverage dropped below tolerance: ${COVERAGE}% < ${FLOOR}%"
  exit 1
fi

if (( $(echo "$COVERAGE > $BASELINE" | bc -l) )); then
  echo "Coverage increased to ${COVERAGE}% (was ${BASELINE}%)"
  if [ "$UPDATE_BASELINE" = "true" ]; then
    echo "Updating baseline and pushing to PR branch"
    echo "$COVERAGE" > "$BASELINE_PATH"
    git config user.name "ci-bot"
    git config user.email "ci-bot@users.noreply.github.com"
    git add "$BASELINE_PATH"
    git commit -m "ci: update coverage baseline to ${COVERAGE}%" || true
    if [ -n "${GITHUB_HEAD_REF:-}" ]; then
      git push origin "HEAD:${GITHUB_HEAD_REF}" || true
    else
      echo "GITHUB_HEAD_REF unset; skipped push"
    fi
  else
    echo "Baseline update skipped (UPDATE_COVERAGE_BASELINE!=true)."
    echo "Commit coverage/coverage_baseline.txt with ${COVERAGE} locally if desired."
  fi
elif (( $(echo "$COVERAGE < $BASELINE" | bc -l) )); then
  echo "Coverage dipped slightly but within tolerance (${COVERAGE}% >= ${FLOOR}%)."
else
  echo "Coverage unchanged at ${COVERAGE}%."
fi
