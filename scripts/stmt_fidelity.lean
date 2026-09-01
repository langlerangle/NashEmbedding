/-
Statement-fidelity capture for the principal results (the declarations checked in
`scripts/axioms.lean`).  Run `lake env lean scripts/stmt_fidelity.lean > capture.txt`
at each toolchain pin being compared and diff the outputs.

Theorems are captured as types only (`#check @name`; proof terms may differ across
pins).  Defs are captured with bodies (`#print`; the body is content).  Two passes:
the default pretty printer (the reader-facing rendering) and `pp.all` (catches
instance, universe, and coercion drift invisible at default settings).  The
`===PASS2===` marker line separates the passes for tooling that diffs them apart.
-/
import Challenge
import NashEmbedding

set_option pp.universes true
set_option maxHeartbeats 1000000

/-! ## Pass 1: default pretty printer -/

#check @NashEmbeddingTheorem.nash_isometric_embedding
#check @NashEmbedding.nashCompact
#check @NashEmbedding.nashCompact_isClosedEmbedding
#check @NashEmbedding.PullsBackEuclidean.injective_mfderiv
#check @NashEmbedding.nashTorus
#check @NashEmbedding.torus2_matches_nashTorus
#check @NashEmbedding.hasFullRankDeriv_of_realizes
#check @NashEmbedding.sphere_nashCompact
#check @NashEmbedding.sphereProd_nashCompact
#check @NashEmbedding.not_pullsBackEuclidean_const

#print NashEmbedding.inducedMetric
#print NashEmbedding.pullbackMetric
#print NashEmbedding.prodMetric
#print NashEmbedding.sphereMetric
#print NashEmbedding.circleMetric
#print NashEmbedding.flatTorus2Metric

/-! ## Pass 2: pp.all -/

#check "===PASS2==="

section AllPP
set_option pp.all true

#check @NashEmbeddingTheorem.nash_isometric_embedding
#check @NashEmbedding.nashCompact
#check @NashEmbedding.nashCompact_isClosedEmbedding
#check @NashEmbedding.PullsBackEuclidean.injective_mfderiv
#check @NashEmbedding.nashTorus
#check @NashEmbedding.torus2_matches_nashTorus
#check @NashEmbedding.hasFullRankDeriv_of_realizes
#check @NashEmbedding.sphere_nashCompact
#check @NashEmbedding.sphereProd_nashCompact
#check @NashEmbedding.not_pullsBackEuclidean_const

#print NashEmbedding.inducedMetric
#print NashEmbedding.pullbackMetric
#print NashEmbedding.prodMetric
#print NashEmbedding.sphereMetric
#print NashEmbedding.circleMetric
#print NashEmbedding.flatTorus2Metric

end AllPP
