#!/usr/bin/env bash
# Independently verify Solution.lean against Challenge.lean with leanprover/comparator.
#
# Trust required: the Lean kernel, Mathlib, Challenge.lean (the statement), and comparator
# itself.  The proofs in the NashEmbedding library do NOT need to be trusted — comparator
# rebuilds Challenge and Solution in a sandbox, exports them with lean4export, compares the
# statements, checks the axioms, and replays the proof through the kernel.
#
# Modelled on kim-em/erdos-unit-distance-comparator/verify.sh.  Set SKIP_CACHE=1 to skip
# `lake exe cache get` (when Mathlib is already built locally).
set -euo pipefail
cd "$(dirname "$0")/.."

TOOLCHAIN_TAG=$(sed -e 's/^leanprover\/lean4://' lean-toolchain | tr -d '[:space:]')
# Key the cache by toolchain: a comparator built with one Lean cannot read oleans
# produced by another ("incompatible header"), so stale clones must never be reused
# across a pin bump.
WORK="${COMPARATOR_WORK:-$HOME/.cache/nash-comparator-$TOOLCHAIN_TAG}"
mkdir -p "$WORK"

resolve_tag() {
  local repo="$1" tag="$2"
  if git ls-remote --exit-code --tags "https://github.com/$repo" "refs/tags/$tag" >/dev/null 2>&1; then
    printf '%s' "$tag"
  else
    printf '%s' "$tag" | sed -E 's/^(v[0-9]+\.[0-9]+)\.[0-9]+$/\1.0/'
  fi
}

if [ ! -d "$WORK/comparator" ]; then
  git clone --branch "$(resolve_tag leanprover/comparator "$TOOLCHAIN_TAG")" --depth 1 \
    https://github.com/leanprover/comparator "$WORK/comparator"
fi
if [ ! -d "$WORK/lean4export" ]; then
  git clone --branch "$(resolve_tag leanprover/lean4export "$TOOLCHAIN_TAG")" --depth 1 \
    https://github.com/leanprover/lean4export "$WORK/lean4export"
fi
(cd "$WORK/comparator" && lake build)
(cd "$WORK/lean4export" && lake build)

# landrun, wrapped to grant the dynamic loader paths its -ldd resolution can miss.
if [ ! -x "$WORK/landrun-bin" ]; then
  curl -sL -o "$WORK/landrun-bin" \
    https://github.com/Zouuup/landrun/releases/download/v0.1.14/landrun-linux-amd64
  chmod +x "$WORK/landrun-bin"
fi
EXTRA=""
for d in /lib64 /lib /usr/lib /nix/store; do
  [ -e "$d" ] && EXTRA="$EXTRA --rox $d"
done
printf '#!/usr/bin/env bash\nexec "%s/landrun-bin"%s "$@"\n' "$WORK" "$EXTRA" > "$WORK/landrun"
chmod +x "$WORK/landrun"
export COMPARATOR_LANDRUN="$WORK/landrun"
export PATH="$WORK:$WORK/lean4export/.lake/build/bin:$PATH"

[ "${SKIP_CACHE:-0}" = "1" ] || lake exe cache get
lake env "$WORK/comparator/.lake/build/bin/comparator" comparator.json
