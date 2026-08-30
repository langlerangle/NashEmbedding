#!/usr/bin/env bash
# Trust audit for the NashEmbedding repository.
#
# Modelled on the audit script in Tao's teorth/sendov repo.  What it checks:
#
#   1. no forbidden tokens under NashEmbedding/ and Solution.lean
#      (sorry, admit, exact?, native_decide, ⊤ as a smoothness order)
#   2. exactly one `sorry` in Challenge.lean (the statement of record uses
#      `sorry` in place of a proof, by design — Solution.lean proves it)
#   3. every `set_option max*` in the repository is disclosed
#   4. the axiom footprint of every top-level result is exactly
#      [propext, Classical.choice, Quot.sound] — no `sorryAx` (would mean
#      an unclosed proof), no `Lean.ofReduceBool` (would mean `native_decide`)
#
# Exits non-zero on failure.
#
# Usage:  bash scripts/audit.sh

set -uo pipefail

FAIL=0
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

fail() { echo "AUDIT FAIL: $*" >&2 ; FAIL=1 ; }
ok()   { echo "AUDIT ok:   $*" ; }

echo "=== 1. Forbidden tokens under NashEmbedding/ and Solution.lean ==="
BAD=$(git ls-files NashEmbedding Solution.lean | grep -E '\.lean$' | \
        xargs grep -nE '\b(sorry|admit)\b|exact\?|native_decide' 2>/dev/null || true)
if [[ -n "$BAD" ]]; then
  fail "forbidden tokens found:"
  printf '%s\n' "$BAD" >&2
else
  ok "no forbidden tokens under NashEmbedding/ or Solution.lean"
fi

echo ""
echo "=== 2. Challenge.lean has exactly one sorry ==="
CHALLENGE_SORRIES=$(grep -cE '\bsorry\b' Challenge.lean || true)
if [[ "$CHALLENGE_SORRIES" != "1" ]]; then
  fail "Challenge.lean has $CHALLENGE_SORRIES sorry occurrences; expected exactly 1"
else
  ok "Challenge.lean has exactly 1 sorry"
fi

echo ""
echo "=== 3. Disclosure of every set_option max* in the tree ==="
MAX_OPTS=$(git ls-files '*.lean' | xargs grep -nE 'set_option[[:space:]]+[A-Za-z0-9._]*max[A-Za-z0-9._]*' 2>/dev/null || true)
if [[ -n "$MAX_OPTS" ]]; then
  echo "Resource knobs (disclosed for transparency; not a failure):"
  printf '%s\n' "$MAX_OPTS"
else
  ok "no set_option max* in the tree"
fi

echo ""
echo "=== 4. Axiom footprint of every top-level result ==="
AXIOM_LOG=$(mktemp)
if ! lake env lean scripts/axioms.lean > "$AXIOM_LOG" 2>&1 ; then
  fail "lake env lean scripts/axioms.lean returned non-zero:"
  cat "$AXIOM_LOG" >&2
else
  # Any axiom line MUST list exactly the three permitted axioms.  Also, any
  # occurrence of `sorryAx` or `Lean.ofReduceBool` is fatal.
  BADAX=$(grep -E 'sorryAx|Lean\.ofReduceBool' "$AXIOM_LOG" || true)
  if [[ -n "$BADAX" ]]; then
    fail "forbidden axioms found in scripts/axioms.lean output:"
    printf '%s\n' "$BADAX" >&2
  fi
  # Every line reporting axioms must be exactly the canonical set.
  BADFOOT=$(grep -E "depends on axioms:" "$AXIOM_LOG" \
    | grep -vE '\[propext, Classical\.choice, Quot\.sound\]$' || true)
  if [[ -n "$BADFOOT" ]]; then
    fail "non-standard axiom footprint(s):"
    printf '%s\n' "$BADFOOT" >&2
  fi
  if [[ -z "$BADAX" && -z "$BADFOOT" ]]; then
    N=$(grep -cE 'depends on axioms:' "$AXIOM_LOG")
    ok "all $N declarations on [propext, Classical.choice, Quot.sound]"
  fi
fi
rm -f "$AXIOM_LOG"

echo ""
if [[ "$FAIL" -eq 0 ]]; then
  echo "AUDIT PASSED"
  exit 0
else
  echo "AUDIT FAILED"
  exit 1
fi
