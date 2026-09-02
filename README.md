# Nash's isometric embedding theorem in Lean

A formalization of **Nash's C<sup>∞</sup> isometric embedding theorem for closed manifolds**,
by Günther's method, in Lean 4 / Mathlib.

```lean
/-- **Nash's isometric embedding theorem.** -/
theorem NashEmbeddingTheorem.nash_isometric_embedding
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
            (mfderiv I 𝓘(ℝ, EuclideanSpace ℝ (Fin q)) w x v')
```

Every compact smooth manifold without boundary, with any smooth Riemannian metric g,
admits a smooth injective map w into some ℝ<sup>q</sup> whose differential pulls the
Euclidean inner product back to g. Two consequences, proved separately and not part of the
compared statement: since M is compact, w is a closed embedding
(`NashEmbedding.nashCompact_isClosedEmbedding`), and since g is positive definite, the
pullback identity makes dw injective at every point, so w is an immersion
(`NashEmbedding.PullsBackEuclidean.injective_mfderiv`) — together, a smooth isometric
embedding. "Without boundary" is Mathlib's `I.Boundaryless` (the model with corners has full
range), the usual formal expression of the notion; see `Challenge.lean` for the precise
reading.

The theorem is **Nash's** (1956). The proof formalized is **Günther's** (1989), which
replaces Nash's iteration by an elliptic fixed-point argument. The presentation followed
is **A. J. Wassermann's** Cambridge Part III lecture notes, the primary source for the
details. Nothing here is claimed to be new.

No bound on the embedding dimension q is formalized: the theorem asserts the existence of
some finite q, and the q the proof produces depends on the chosen bump covering and is far
from Nash's quantitative bounds.

### What to audit

[`Challenge.lean`](Challenge.lean) is the statement of record: it imports only Mathlib,
declares no definitions, and states the theorem above with a `sorry`;
[`Solution.lean`](Solution.lean) proves it from the library's
[`NashEmbedding.nashCompact`](NashEmbedding/Compact/Main.lean). A reader who wants to know
*what* is proved need read only `Challenge.lean`. The proved declaration in `Solution.lean`
depends on `propext`, `Classical.choice` and `Quot.sound` only (the copy in `Challenge.lean`
is the deliberate `sorry`, so it depends on `sorryAx` by design; Comparator checks that the
two statements are identical and that the Solution's proof uses only the permitted axioms).

## Roadmap

The development has two layers: Nash's theorem for the flat torus, and the reduction of a
closed manifold to the torus.

### 1. The Sobolev toolkit on 𝕋ⁿ — [`NashEmbedding/Sobolev/`](NashEmbedding/Sobolev)

Everything is done on ℝⁿ with 2πℤⁿ-periodic data, in two
parallel pictures: **momentum space** (sequences on ℤⁿ, the weighted
ℓ² spaces Hˢ) and **position space** (distributions on trigonometric
polynomials; names carry the suffix `Distrib`).

| what | where |
|---|---|
| the scale Hˢ(ℤⁿ), Rellich compactness, the Sobolev sup bound | [`Basic`](NashEmbedding/Sobolev/Basic.lean), [`CompactInclusion`](NashEmbedding/Sobolev/CompactInclusion.lean), [`Inequalities`](NashEmbedding/Sobolev/Inequalities.lean) |
| three multiplication theorems (Hˢ is an algebra for s > n/2; the sharp and bootstrapped forms) | [`Multiplication`](NashEmbedding/Sobolev/Multiplication.lean), [`MultiplicationSharp`](NashEmbedding/Sobolev/MultiplicationSharp.lean), [`MultiplicationBootstrap`](NashEmbedding/Sobolev/MultiplicationBootstrap.lean) |
| convolution, Riemann sums, mollifiers, periodization | [`Convolution`](NashEmbedding/Sobolev/Convolution.lean), [`RiemannSum`](NashEmbedding/Sobolev/RiemannSum.lean), [`Mollifier`](NashEmbedding/Sobolev/Mollifier.lean), [`Periodization`](NashEmbedding/Sobolev/Periodization.lean) |
| Fourier inversion for smooth periodic functions, integration by parts, Parseval | [`FourierSynthesis`](NashEmbedding/Sobolev/FourierSynthesis.lean), [`SynthesisRegularity`](NashEmbedding/Sobolev/SynthesisRegularity.lean), [`IntegrationByParts`](NashEmbedding/Sobolev/IntegrationByParts.lean), [`Parseval`](NashEmbedding/Sobolev/Parseval.lean) |
| the resolvent (1+Δ)⁻¹, limits in Hˢ, the convolution algebra, the coefficient dictionary | [`Resolvent`](NashEmbedding/Sobolev/Resolvent.lean), [`Limits`](NashEmbedding/Sobolev/Limits.lean), [`ConvolutionAlgebra`](NashEmbedding/Sobolev/ConvolutionAlgebra.lean), [`CoeffTransport`](NashEmbedding/Sobolev/CoeffTransport.lean) |

### 2. Nash for the flat torus — [`NashEmbedding/Torus/`](NashEmbedding/Torus)

A metric is a smooth periodic positive-definite matrix field g on ℝⁿ; a map
u : ℝⁿ → ℝ<sup>N</sup> *realizes* g if ∂ᵢu · ∂ⱼu = gᵢⱼ
([`Torus/Basic`](NashEmbedding/Torus/Basic.lean)).

* **Realizable metrics form a cone** closed under sums and positive scalings, and every
  realizable metric can be promoted to an injectively realizable one by adjoining a
  scaled copy of the standard embedding of the torus —
  [`RealizableMetrics`](NashEmbedding/Torus/RealizableMetrics.lean).
* **Theorem A** (approximation): every smooth metric is an Hˢ-limit of realizable
  metrics, for every s — [`realizable_approx_all_s`](NashEmbedding/Torus/Approximation/RealizeMetric.lean),
  built from bumps with prescribed Gram matrix
  ([`BumpConstruction`](NashEmbedding/Torus/Approximation/BumpConstruction.lean),
  [`SmoothMetricApprox`](NashEmbedding/Torus/Approximation/SmoothMetricApprox.lean)).
* **Theorem B** (Günther's perturbation theorem): a *free* embedding u₀ (first and
  second partials linearly independent) can be perturbed to realize
  ∂u₀ · ∂u₀ + h for every sufficiently small smooth symmetric h —
  [`gunther_perturbation`](NashEmbedding/Torus/Perturbation/Main.lean). The perturbation
  is found as the fixed point of a contraction on coefficient sequences in Hʳ
  ([`GuntherIteration`](NashEmbedding/Torus/Perturbation/GuntherIteration.lean),
  [`GuntherOperator`](NashEmbedding/Torus/Perturbation/GuntherOperator.lean)), using the
  dual frame of {∂ᵢu₀, ∂ₚ∂_q u₀}
  ([`DualFrame`](NashEmbedding/Torus/Perturbation/DualFrame.lean)) and Günther's identity
  ([`GuntherIdentity`](NashEmbedding/Torus/Perturbation/GuntherIdentity.lean),
  [`GuntherIdentitySeq`](NashEmbedding/Torus/Perturbation/GuntherIdentitySeq.lean)).
* **A free embedding** of 𝕋ⁿ in ℝ^(n²+n) —
  [`FreeEmbedding`](NashEmbedding/Torus/FreeEmbedding.lean).
* **Assembly**: split off a small multiple of the flat metric, approximate the rest by a
  realizable metric, perturb the free embedding to absorb the difference, and adjoin the
  pieces — [`Assembly`](NashEmbedding/Torus/Assembly.lean),
  [`nashTorus`](NashEmbedding/Torus/Main.lean):

  > `nashTorus : 0 < n → IsPosDefSmoothMetric g → IsInjRealizable g`

### 3. From a closed manifold to the torus — [`NashEmbedding/Compact/`](NashEmbedding/Compact)

* **Whitney, and an extension along it.** Mathlib's bump-covering embedding
  Φ : M → ℝ<sup>N</sup> is a smooth injective immersion; any smooth function on M
  extends to a smooth function on ℝ<sup>N</sup> along it, chart by chart —
  [`WhitneyExtension`](NashEmbedding/Compact/WhitneyExtension.lean).
* **An ambient metric.** Using the pseudo-inverse of dΦ, the metric g extends to a
  smooth positive-definite bilinear form on a neighbourhood of Φ(M) in
  ℝ<sup>N</sup> — [`AmbientMetric`](NashEmbedding/Compact/AmbientMetric.lean).
* **Cutoff and periodization.** After scaling Φ(M) into the open cube (−π, π)ᴺ,
  the ambient form is cut off, symmetrized, made positive definite by adding a multiple
  of the identity, and periodized to a metric on ℝ<sup>N</sup> —
  [`Periodization`](NashEmbedding/Compact/Periodization.lean).
* **Conclusion.** `nashTorus` embeds the torus; composing with Φ gives w —
  [`nashCompact`](NashEmbedding/Compact/Main.lean), with its corollaries
  `nashCompact_isClosedEmbedding` and `PullsBackEuclidean.injective_mfderiv`.

### 4. Metrics and examples — [`Riemannian/`](NashEmbedding/Riemannian), [`Examples/`](NashEmbedding/Examples)

`ContMDiffRiemannianMetric`s from old ones: the metric induced by an immersion into an
inner-product space ([`Induced`](NashEmbedding/Riemannian/Induced.lean)), pullbacks and
products ([`Pullback`](NashEmbedding/Riemannian/Pullback.lean)). Hence the round spheres
𝕊ⁿ for every n and the products 𝕊ⁿ × 𝕊ᵐ
([`Examples/Sphere`](NashEmbedding/Examples/Sphere.lean)), the flat torus
𝕊¹ × 𝕊¹, and a consistency check between the two layers: the closed-manifold
embedding of 𝕊¹ × 𝕊¹, composed with the universal cover ℝ² → 𝕊¹ × 𝕊¹,
is exactly a witness of the kind `nashTorus` produces for the identity metric on
ℝ² —
[`torus2_matches_nashTorus`](NashEmbedding/Examples/FlatTorus.lean). A negative example
([`Examples/Negative`](NashEmbedding/Examples/Negative.lean)) records what the theorem
does not say.

## Trust

* No `sorry` and no project-defined `axiom`, with one deliberate exception:
  `Challenge.lean` states the theorem without proving it, which is what makes it the
  statement of record for Comparator to check `Solution.lean` against.
  [`scripts/audit.sh`](scripts/audit.sh) requires exactly that one hole and forbids
  `sorry` everywhere else, including `Solution.lean`.
* No `native_decide`, no `unsafe`, no floating point.
* `maxHeartbeats` (and one `synthInstance.maxHeartbeats`) settings appear only as
  deliberate resource knobs; the audit script lists them.
* The Mathlib linter set is enabled (`lakefile.toml`) for the checks that concern the shape
  of statements, signatures and section variables, with `autoImplicit` off; the linters that
  judge the style of proof bodies (`refine` vs `exact`, `show`, unused `simp` arguments, line
  length, whitespace, unused local hypotheses, …) are disabled, because most of the proof
  text was produced by Aristotle, and proof bodies are not reformatted or rewritten. The build has no warnings beyond the one deliberate `sorry` in `Challenge.lean`.
* The audit script prints the axiom dependencies of the principal results enumerated in
  ([`scripts/axioms.lean`](scripts/axioms.lean)); all are `propext`, `Classical.choice`,
  `Quot.sound`. It runs in CI on every push, followed by the Comparator check of
  `Challenge.lean` against `Solution.lean`.

The human author reviewed the design and the principal statements, but did not review
the Lean proofs in detail (see *How this was produced*). A prior GPT-5.6 Sol (OpenAI)
audit (not a proof review) of the earlier public `v4.28.0` submission identified no
statement-level defect in the versions it examined and led to a series of
provenance/editorial corrections in that pre-port tree. This `v4.31.0` candidate was
separately reviewed by a fresh GPT-5.6 Sol instance (not a proof review) and the
findings from that round were addressed in commits atop the audited port commit. The
yaml's `review` section and the commit history record the specifics.

## Building

```
lake exe cache get
lake build
bash scripts/audit.sh
```

Lean `v4.31.0`, Mathlib `v4.31.0` (commit `fabf563a7c95a166b8d7b6efca11c8b4dc9d911f`),
pinned in `lean-toolchain` and `lake-manifest.json`. `NashEmbeddingTest/` holds a few
regression checks that are built by `lake build` but not imported by the library. See
[PROVENANCE.md](PROVENANCE.md) for the toolchain history including the original
`v4.28.0` pin.

## Provenance and novelty

**No novelty is claimed anywhere in this repository.** The theorem is Nash's; the proof is
Günther's; the presentation followed is Wassermann's. Where the file docstrings note that
a constant, hypothesis or route differs from the notes, that describes this development,
not a claim of priority. A web search (Lean Zulip, the Isabelle AFP, general search for
formalizations of Nash's or Günther's theorem) found no earlier formalization of the
isometric embedding theorem in any proof assistant; that is the result of that search,
not a claim that none exists.

For the v4.28-era Mathlib coverage survey supporting this no-novelty claim, see
[PROVENANCE.md](PROVENANCE.md).

## How this was produced

This project is an **AI–AI collaboration, requested by a human**.

David Wiygul proposed the project, selected Wassermann's notes as the source, and
took part in the early design decisions (April–May 2026, working with Claude Opus 4.7).
He did not write Lean, and reviewed design decisions and statements rather than proofs.

The Lean development was produced by AI systems, in two roles:

* **Architecture, statement development, assembly and coordination — Claude (Anthropic).**
  In April–May 2026, Claude Opus 4.7 produced the informal blueprints of the torus layer
  (the Sobolev toolkit and Theorem A) and submitted them to Aristotle as successive
  formalization tasks. In August 2026 two persistent Claude Code sessions (Claude Fable 5
  and Claude Opus 4.7) designed Theorem B and the closed-manifold reduction, wrote the
  principal Lean statements of every August file and the file tree, wrote several files
  by hand (`DualFrame`, `SeqVector`, `GuntherIteration`, `BumpConstruction`,
  `RealizeMetric`, `IntegrationByParts`, the assemblies `Assembly`, `Torus/Main`,
  `Compact/Main`, and the statements of `Examples/FlatTorus`), submitted successive
  formalization tasks to Aristotle and integrated its contributions, and checked each
  other's work. In September 2026 the same two sessions ported the tree to Lean/Mathlib
  `v4.31.0` and prepared this Palomar submission; Aristotle did not participate in the
  port, the packaging, or the submission.
* **Formalization and proof development — [Aristotle](https://aristotle.harmonic.fun),
  [Harmonic](https://harmonic.fun)'s Lean formalization and proving system.** In April–May
  2026 Aristotle turned Claude's informal blueprints into most of the Lean statements and
  proofs of the torus toolkit and Theorem A; in August 2026 it supplied most proof bodies,
  and some auxiliary lemma statements, within the architecture the Claude sessions
  designed. Every Aristotle contribution was separately checked by both Claude sessions
  before integration: statements byte-identical, only the target file touched, no
  `sorry`/`admit`/`exact?`/`native_decide`, full build, standard axioms.

The human author reviewed the design and the principal statements, but did not review
the Lean source in detail; no other human review has been performed. The only external
scrutiny is the AI audit (not a proof review) described under *Trust*.

The per-file provenance table, toolchain history, Aristotle job identifiers,
and the detailed record of the September 2026 v4.31 port's compatibility
changes are in [PROVENANCE.md](PROVENANCE.md). The port made exactly one
source-level statement change: the `exists_extension` theorem in
`Compact/WhitneyExtension.lean` now states its conclusion through a wrapper
of a Mathlib constant that became non-public at v4.31.0 — the two forms are
definitionally equal; all other edits are proof- and elaboration-compatibility
work.

## License

Apache-2.0; see [`LICENSE`](LICENSE).
