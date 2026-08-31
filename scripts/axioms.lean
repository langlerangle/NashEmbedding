/-
  Axiom footprint check for the principal results of NashEmbedding listed below, plus the
  Challenge/Solution bridge.  Each result must depend on exactly

    [propext, Classical.choice, Quot.sound]

  which is Lean core's standard axiom set.  Deliberately not a library module
  (excluded from lakefile lean_libs); run with `lake env lean scripts/axioms.lean`
  from `scripts/audit.sh`, which fails on any occurrence of `sorryAx` or
  `Lean.ofReduceBool` (i.e. `native_decide`).
-/
import NashEmbedding
import Solution

/-! ## The compared declaration -/

#print axioms NashEmbeddingTheorem.nash_isometric_embedding

/-! ## The Nash embedding for closed manifolds -/

#print axioms NashEmbedding.nashCompact
#print axioms NashEmbedding.nashCompact_isClosedEmbedding
#print axioms NashEmbedding.PullsBackEuclidean.injective_mfderiv

/-! ## The Nash embedding for the flat torus -/

#print axioms NashEmbedding.nashTorus

/-! ## The cross-check on 𝕋² and the general full-rank lemma -/

#print axioms NashEmbedding.torus2_matches_nashTorus
#print axioms NashEmbedding.hasFullRankDeriv_of_realizes

/-! ## Metric constructions -/

#print axioms NashEmbedding.inducedMetric
#print axioms NashEmbedding.pullbackMetric
#print axioms NashEmbedding.prodMetric

/-! ## Concrete-manifold witnesses -/

#print axioms NashEmbedding.sphereMetric
#print axioms NashEmbedding.sphere_nashCompact
#print axioms NashEmbedding.sphereProd_nashCompact
#print axioms NashEmbedding.circleMetric
#print axioms NashEmbedding.flatTorus2Metric
#print axioms NashEmbedding.not_pullsBackEuclidean_const
