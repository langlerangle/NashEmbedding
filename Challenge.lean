/-
Copyright (c) 2026 David Wiygul. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Claude Fable 5 (Anthropic), Claude Opus 4.7 (Anthropic)
  — at the request and direction of David Wiygul
-/
import Mathlib

/-!
# Nash's isometric embedding theorem for closed manifolds

This is the statement of record for the Palomar submission.  It states one theorem and
introduces no definitions of its own; every notion used is Mathlib's.

The underlying `NashEmbedding` development was substantially formalized by
Aristotle (Harmonic); see the repository provenance record.

## The statement

Let `M` be a compact smooth manifold without boundary (Hausdorff, modelled on a
finite-dimensional real normed space `E` through a boundaryless model with corners `I`), and
let `g` be a smooth Riemannian metric on `M` (`ContMDiffRiemannianMetric I ∞ E (TangentSpace I)`).

**Nash's theorem** (`NashEmbeddingTheorem.nash_isometric_embedding`): there are `q : ℕ` and a
smooth map `w : M → ℝ^q` (`EuclideanSpace ℝ (Fin q)`) which is injective and pulls the
Euclidean inner product back to `g`: for every `x : M` and tangent vectors `v v'` at `x`,

  `g_x(v, v') = ⟪dw_x v, dw_x v'⟫`.

Since `M` is compact and `w` is continuous and injective, `w` is a topological embedding
(a closed embedding); the pullback condition makes `dw_x` injective at every `x`, so `w` is an
immersion; the theorem thus produces a smooth *isometric embedding* of `(M, g)` into
Euclidean space.

## How the hypotheses are phrased

* `M` is a manifold in Mathlib's sense: `[ChartedSpace H M] [IsManifold I ∞ M]` for a model
  with corners `I : ModelWithCorners ℝ E H`.  "Without boundary" is expressed as
  `[I.Boundaryless]`: the model `I` has full range (`Set.range I = Set.univ`), so every chart
  image is open in `E`.  This is the usual formal way to say that `M` has no boundary, and it
  is the form the proof needs (its extension step pushes functions forward through charts
  and extends by zero, which requires open chart images).  It is stronger than Mathlib's
  pointwise notion `BoundarylessManifold I M` (every point of `M` is an interior point of
  some chart), which is not assumed here; a manifold satisfying only the pointwise notion
  would first have to be re-charted on a boundaryless model.  `[T2Space M]` and
  `[CompactSpace M]` make `M` a closed manifold.  No assumption is
  made on the dimension of `M`, on connectedness, or on `E` beyond finite-dimensionality; the
  empty manifold is allowed and the theorem is trivially true for it.
* The metric `g` is a `ContMDiffRiemannianMetric I ∞ E (TangentSpace I : M → Type _)`: a
  smooth section of the bundle of bilinear forms on `TM` (`contMDiff`) that is symmetric
  (`symm`) and positive definite (`pos`) at every point, and whose fibrewise norms are
  compatible with the topology of the fibres (`isVonNBounded`; automatic in finite dimension).
  Smoothness is Mathlib's `∞`, the inner top of `WithTop ℕ∞` (differentiable to every finite
  order, i.e. `C^∞`); the outer top `ω` means analytic, and a bare `⊤` written in a
  `WithTop ℕ∞` position would elaborate to `ω`, so `∞` is used throughout.
* `dw_x` is `mfderiv I 𝓘(ℝ, EuclideanSpace ℝ (Fin q)) w x`, the manifold derivative.  The
  tangent space to `EuclideanSpace ℝ (Fin q)` at any point is definitionally
  `EuclideanSpace ℝ (Fin q)`; the inner product is taken there, which is what the explicit type
  argument of `inner` records.
* The embedding dimension `q` is existentially quantified; no bound on it is claimed.

## Provenance and status

This is Nash's `C^∞` isometric embedding theorem (J. Nash, 1956) for closed manifolds.  The
proof formalized is Günther's (M. Günther, 1989: the embedding is obtained by an elliptic
perturbation argument, avoiding the Nash–Moser iteration), following the presentation in
A. J. Wassermann's lecture notes, which were the primary source.  Nothing here is claimed to
be new.

The proof is in the `NashEmbedding` library of this repository and is compared against this
statement by Comparator.  It uses `propext`, `Classical.choice` and `Quot.sound` only.
-/

open scoped Manifold ContDiff
open Bundle

namespace NashEmbeddingTheorem

/-- **Nash's isometric embedding theorem.**  Every closed smooth manifold with a smooth
Riemannian metric `g` admits a smooth injective map `w` into some Euclidean space `ℝ^q` whose
differential pulls the Euclidean inner product back to `g`. -/
theorem nash_isometric_embedding
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] [FiniteDimensional ℝ E]
    {H : Type*} [TopologicalSpace H] {I : ModelWithCorners ℝ E H} [I.Boundaryless]
    {M : Type*} [TopologicalSpace M] [ChartedSpace H M] [IsManifold I ∞ M]
    [T2Space M] [CompactSpace M]
    (g : ContMDiffRiemannianMetric I ∞ E (TangentSpace I : M → Type _)) :
    ∃ (q : ℕ) (w : M → EuclideanSpace ℝ (Fin q)),
      ContMDiff I 𝓘(ℝ, EuclideanSpace ℝ (Fin q)) ∞ w ∧ Function.Injective w ∧
      ∀ (x : M) (v v' : TangentSpace I x),
        g.inner x v v' =
          @inner ℝ (EuclideanSpace ℝ (Fin q)) _
            (mfderiv I 𝓘(ℝ, EuclideanSpace ℝ (Fin q)) w x v)
            (mfderiv I 𝓘(ℝ, EuclideanSpace ℝ (Fin q)) w x v') := by
  sorry

end NashEmbeddingTheorem
