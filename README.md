# Nash's isometric embedding theorem in Lean

A formalization of **Nash's $C^\infty$ isometric embedding theorem for closed manifolds**,
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

Every compact smooth manifold without boundary, with any smooth Riemannian metric $g$,
admits a smooth injective map $w$ into some $\mathbb{R}^q$ whose differential pulls the
Euclidean inner product back to $g$. Since $M$ is compact, $w$ is a closed embedding
(`NashEmbedding.nashCompact_isClosedEmbedding`) and an immersion
(`NashEmbedding.PullsBackEuclidean.injective_mfderiv`): a smooth isometric embedding.

The theorem is **Nash's** (1956). The proof formalized is **Günther's** (1989), which
replaces Nash's iteration by an elliptic fixed-point argument. The presentation followed
is **A. J. Wassermann's** Cambridge Part III lecture notes, the primary source for the
details. Nothing here is claimed to be new.

[`Challenge.lean`](Challenge.lean) is the statement of record: it imports only Mathlib,
declares no definitions, and states the theorem above with a `sorry`;
[`Solution.lean`](Solution.lean) proves it from the library's
[`NashEmbedding.nashCompact`](NashEmbedding/Compact/Main.lean). A reader who wants to know
*what* is proved need read only `Challenge.lean`. Both depend on `propext`,
`Classical.choice` and `Quot.sound` only.

## Roadmap

The development has two layers: Nash's theorem for the flat torus, and the reduction of a
closed manifold to the torus.

### 1. The Sobolev toolkit on $\mathbb{T}^n$ — [`NashEmbedding/Sobolev/`](NashEmbedding/Sobolev)

Everything is done on $\mathbb{R}^n$ with $2\pi\mathbb{Z}^n$-periodic data, in two
parallel pictures: **momentum space** (sequences on $\mathbb{Z}^n$, the weighted
$\ell^2$ spaces $H^s$) and **position space** (distributions on trigonometric
polynomials; names carry the suffix `Distrib`).

| what | where |
|---|---|
| the scale $H^s(\mathbb{Z}^n)$, Rellich compactness, the Sobolev sup bound | [`Basic`](NashEmbedding/Sobolev/Basic.lean), [`CompactInclusion`](NashEmbedding/Sobolev/CompactInclusion.lean), [`Inequalities`](NashEmbedding/Sobolev/Inequalities.lean) |
| three multiplication theorems ($H^s$ is an algebra for $s > n/2$; the sharp and bootstrapped forms) | [`Multiplication`](NashEmbedding/Sobolev/Multiplication.lean), [`MultiplicationSharp`](NashEmbedding/Sobolev/MultiplicationSharp.lean), [`MultiplicationBootstrap`](NashEmbedding/Sobolev/MultiplicationBootstrap.lean) |
| convolution, Riemann sums, mollifiers, periodization | [`Convolution`](NashEmbedding/Sobolev/Convolution.lean), [`RiemannSum`](NashEmbedding/Sobolev/RiemannSum.lean), [`Mollifier`](NashEmbedding/Sobolev/Mollifier.lean), [`Periodization`](NashEmbedding/Sobolev/Periodization.lean) |
| Fourier inversion for smooth periodic functions, integration by parts, Parseval | [`FourierSynthesis`](NashEmbedding/Sobolev/FourierSynthesis.lean), [`SynthesisRegularity`](NashEmbedding/Sobolev/SynthesisRegularity.lean), [`IntegrationByParts`](NashEmbedding/Sobolev/IntegrationByParts.lean), [`Parseval`](NashEmbedding/Sobolev/Parseval.lean) |
| the resolvent $(1+\Delta)^{-1}$, limits in $H^s$, the convolution algebra, the coefficient dictionary | [`Resolvent`](NashEmbedding/Sobolev/Resolvent.lean), [`Limits`](NashEmbedding/Sobolev/Limits.lean), [`ConvolutionAlgebra`](NashEmbedding/Sobolev/ConvolutionAlgebra.lean), [`CoeffTransport`](NashEmbedding/Sobolev/CoeffTransport.lean) |

### 2. Nash for the flat torus — [`NashEmbedding/Torus/`](NashEmbedding/Torus)

A metric is a smooth periodic positive-definite matrix field $g$ on $\mathbb{R}^n$; a map
$u : \mathbb{R}^n \to \mathbb{R}^N$ *realizes* $g$ if $\partial_i u \cdot \partial_j u = g_{ij}$
([`Torus/Basic`](NashEmbedding/Torus/Basic.lean)).

* **Realizable metrics form a cone** closed under sums and positive scalings, and every
  realizable metric can be promoted to an injectively realizable one by adjoining a
  scaled copy of the standard embedding of the torus —
  [`RealizableMetrics`](NashEmbedding/Torus/RealizableMetrics.lean).
* **Theorem A** (approximation): every smooth metric is an $H^s$-limit of realizable
  metrics, for every $s$ — [`realizable_approx_all_s`](NashEmbedding/Torus/Approximation/RealizeMetric.lean),
  built from bumps with prescribed Gram matrix
  ([`BumpConstruction`](NashEmbedding/Torus/Approximation/BumpConstruction.lean),
  [`SmoothMetricApprox`](NashEmbedding/Torus/Approximation/SmoothMetricApprox.lean)).
* **Theorem B** (Günther's perturbation theorem): a *free* embedding $u_0$ (first and
  second partials linearly independent) can be perturbed to realize
  $\partial u_0 \cdot \partial u_0 + h$ for every sufficiently small smooth symmetric $h$ —
  [`gunther_perturbation`](NashEmbedding/Torus/Perturbation/Main.lean). The perturbation
  is found as the fixed point of a contraction on coefficient sequences in $H^r$
  ([`GuntherIteration`](NashEmbedding/Torus/Perturbation/GuntherIteration.lean),
  [`GuntherOperator`](NashEmbedding/Torus/Perturbation/GuntherOperator.lean)), using the
  dual frame of $\{\partial_i u_0, \partial_p\partial_q u_0\}$
  ([`DualFrame`](NashEmbedding/Torus/Perturbation/DualFrame.lean)) and Günther's identity
  ([`GuntherIdentity`](NashEmbedding/Torus/Perturbation/GuntherIdentity.lean),
  [`GuntherIdentitySeq`](NashEmbedding/Torus/Perturbation/GuntherIdentitySeq.lean)).
* **A free embedding** of $\mathbb{T}^n$ in $\mathbb{R}^{n^2+n}$ —
  [`FreeEmbedding`](NashEmbedding/Torus/FreeEmbedding.lean).
* **Assembly**: split off a small multiple of the flat metric, approximate the rest by a
  realizable metric, perturb the free embedding to absorb the difference, and adjoin the
  pieces — [`Assembly`](NashEmbedding/Torus/Assembly.lean),
  [`nashTorus`](NashEmbedding/Torus/Main.lean):

  > `nashTorus : 0 < n → IsPosDefSmoothMetric g → IsInjRealizable g`

### 3. From a closed manifold to the torus — [`NashEmbedding/Compact/`](NashEmbedding/Compact)

* **Whitney, and an extension along it.** Mathlib's bump-covering embedding
  $\Phi : M \to \mathbb{R}^N$ is a smooth injective immersion; any smooth function on $M$
  extends to a smooth function on $\mathbb{R}^N$ along it, chart by chart —
  [`WhitneyExtension`](NashEmbedding/Compact/WhitneyExtension.lean).
* **An ambient metric.** Using the pseudo-inverse of $d\Phi$, the metric $g$ extends to a
  smooth positive-definite bilinear form on a neighbourhood of $\Phi(M)$ in
  $\mathbb{R}^N$ — [`AmbientMetric`](NashEmbedding/Compact/AmbientMetric.lean).
* **Cutoff and periodization.** After scaling $\Phi(M)$ into the open cube $(-\pi,\pi)^N$,
  the ambient form is cut off, symmetrized, made positive definite by adding a multiple
  of the identity, and periodized to a metric on $\mathbb{R}^N$ —
  [`Periodization`](NashEmbedding/Compact/Periodization.lean).
* **Conclusion.** `nashTorus` embeds the torus; composing with $\Phi$ gives $w$ —
  [`nashCompact`](NashEmbedding/Compact/Main.lean), with its corollaries
  `nashCompact_isClosedEmbedding` and `PullsBackEuclidean.injective_mfderiv`.

### 4. Metrics and examples — [`Riemannian/`](NashEmbedding/Riemannian), [`Examples/`](NashEmbedding/Examples)

`ContMDiffRiemannianMetric`s from old ones: the metric induced by an immersion into an
inner-product space ([`Induced`](NashEmbedding/Riemannian/Induced.lean)), pullbacks and
products ([`Pullback`](NashEmbedding/Riemannian/Pullback.lean)). Hence the round spheres
$S^n$ for every $n$ and the products $S^n \times S^m$
([`Examples/Sphere`](NashEmbedding/Examples/Sphere.lean)), the flat torus
$S^1 \times S^1$, and a consistency check between the two layers: the closed-manifold
embedding of $S^1 \times S^1$, composed with the universal cover $\mathbb{R}^2 \to S^1 \times S^1$,
is exactly a witness of the kind `nashTorus` produces for the identity metric on
$\mathbb{R}^2$ —
[`torus2_matches_nashTorus`](NashEmbedding/Examples/FlatTorus.lean). A negative example
([`Examples/Negative`](NashEmbedding/Examples/Negative.lean)) records what the theorem
does not say.

## Ingredients absent from Mathlib

* The Sobolev scale on the torus with Rellich compactness, the sup bound and the
  multiplication theorems (§1 above), stated on $\mathbb{Z}^n$ and transported to
  position space.
* Parseval's identity for continuous periodic functions on $\mathbb{T}^n$
  (`parseval_stdFourierCoeff`).
* Extension of smooth functions along Mathlib's bump-covering embedding
  (`SmoothBumpCovering.exists_extension`); smoothness of the Moore–Penrose pseudo-inverse
  of an injective linear map (`contDiffAt_pinv`).
* Induced, pullback and product Riemannian metrics as `ContMDiffRiemannianMetric`s.

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
  length, whitespace, unused local hypotheses, …) are disabled, because the proofs were
  produced by Aristotle and are not reformatted or rewritten. The build has zero warnings.
* The audit script prints the axiom dependencies of every top-level result
  ([`scripts/axioms.lean`](scripts/axioms.lean)); all are `propext`, `Classical.choice`,
  `Quot.sound`. It runs in CI on every push, followed by the Comparator check of
  `Challenge.lean` against `Solution.lean`.

No human has read the Lean proofs in this repository (see *How this was produced*).

## Building

```
lake exe cache get
lake build
bash scripts/audit.sh
```

Lean `v4.28.0`, Mathlib `v4.28.0` (commit `8f9d9cff6bd728b17a24e163c9402775d9e6a365`),
pinned in `lean-toolchain` and `lake-manifest.json`. `NashEmbeddingTest/` holds a few
regression checks that are built by `lake build` but not imported by the library.

## Provenance and novelty

**No novelty is claimed anywhere in this repository.** The theorem is Nash's; the proof is
Günther's; the presentation followed is Wassermann's. Where the file docstrings note that
a constant, hypothesis or route differs from the notes, that describes this development,
not a claim of priority. A web search (Lean Zulip, the Isabelle AFP, general search for
formalizations of Nash's or Günther's theorem) found no earlier formalization of the
isometric embedding theorem in any proof assistant; that is the result of that search,
not a claim that none exists.

## How this was produced

This project is an **AI–AI collaboration, requested by a human**.

**David Wiygul** proposed the project, selected Wassermann's notes as the source, and
took part in the early design decisions (April–May 2026, working with Claude Opus 4.7).
He did not write Lean, and reviewed design decisions and statements rather than proofs.

The Lean development was produced by AI systems, in three roles:

* **Design, statements, architecture, assembly — Claude (Anthropic).** In April–May 2026,
  Claude Opus 4.7 produced the informal blueprint of the torus layer and the statements
  of its first eight stages. In August 2026 two persistent Claude Code sessions — named
  **Tor** (Claude Fable 5) and **Slate** (Claude Opus 4.7), the names chosen by the model
  instances in the course of their collaboration — designed Theorem B and the
  closed-manifold reduction, wrote every Lean statement and the file tree, wrote several
  files by hand (`DualFrame`, `SeqVector`, `GuntherIteration`, `BumpConstruction`,
  `RealizeMetric`, `IntegrationByParts`, the assemblies `Assembly`, `Torus/Main`,
  `Compact/Main`, and the statements of `Examples/FlatTorus`, which are Slate's),
  prompted Aristotle file by file, and checked each other's work.
* **The large majority of proof text — [Aristotle](https://aristotle.harmonic.fun),
  [Harmonic](https://harmonic.fun)'s Lean prover.** Given a file with complete statements
  and `sorry` placeholders, Aristotle returned the proofs. Every return was checked
  independently by both Claude sessions before merging: statements byte-identical, only
  the target file touched, no `sorry`/`admit`/`exact?`/`native_decide`, full build,
  standard axioms. In the August campaign every submission whose result was used returned
  clean the first time (21 submissions, one an unused duplicate).

No external or independent review has been performed, and no human has read the Lean
source in full.

### Provenance record

Toolchain for every Aristotle job and every build: Lean `v4.28.0`, Mathlib `v4.28.0`
(`8f9d9cff6bd728b17a24e163c9402775d9e6a365`), Aristotle CLI 2.1.0.

Per file (A = proofs by Aristotle from Claude-written statements; H = written by hand by
Claude; A/H = statements and some lemmas by hand, leaves by Aristotle), with the Aristotle
project identifiers (first eight characters) where a file's leaves were proved in a
dedicated job:

| File | Origin | Aristotle job(s) |
|---|---|---|
| `Sobolev/Basic`, `Periodicity`, `Summability`, `Differentiation`, `CompactInclusion`, `FourierSynthesis`, `Distribution` | A (stages 1–2, May 2026) | May 2026 stage jobs (see below) |
| `Sobolev/Multiplication`, `MultiplicationSharp`, `MultiplicationBootstrap` | A (stages 3–5, May 2026) | May 2026 stage jobs |
| `Sobolev/Convolution`, `RiemannSum` | A (stages 6–7, May 2026) | May 2026 stage jobs |
| `Sobolev/Periodization`, `Mollifier`, `PositionSpace`, `Inequalities` | A/H (stage 8, May 2026; remaining leaves by hand, August 2026) | May 2026 stage jobs |
| `Sobolev/IntegrationByParts` | H (August 2026) | — |
| `Sobolev/SynthesisRegularity` | A/H | `67f7e21e` |
| `Sobolev/Resolvent` | A/H (no dedicated job) | — |
| `Sobolev/Limits` | A/H | `6a508abb` |
| `Sobolev/ConvolutionAlgebra` | A/H | `897d7884` |
| `Sobolev/CoeffTransport` | A/H | `089e4116` |
| `Sobolev/Parseval` | A/H | `34c62afa` |
| `Torus/Basic`, `RealizableMetrics` | A (May 2026) | May 2026 stage jobs |
| `Torus/Approximation/SmoothMetricApprox` | A (stage 8, May 2026) | May 2026 stage jobs |
| `Torus/Approximation/BumpConstruction` | H, three leaves A (August 2026) | `4596fb83` |
| `Torus/Approximation/RealizeMetric` | H (August 2026) | — |
| `Torus/Perturbation/GuntherIdentity` | H statements, leaves A | `774d9d87` |
| `Torus/Perturbation/DualFrame`, `SeqVector`, `GuntherIteration` | H (August 2026) | — |
| `Torus/Perturbation/GuntherOperator` | A/H | `358bcf22`, `8d800e96` |
| `Torus/Perturbation/GuntherIdentitySeq` | A/H | `39088b0b` |
| `Torus/Perturbation/Main` (Theorem B) | A/H (assembly H) | `c61c938f` |
| `Torus/FreeEmbedding` | A/H | `94390b24` |
| `Torus/Assembly` | A/H | `88556cc5` |
| `Torus/Main` (`nashTorus`) | H (August 2026) | — |
| `Compact/WhitneyExtension` | A/H (design and statements H, all leaves A) | `564db993` |
| `Compact/AmbientMetric` | A/H | `6f927eaf` |
| `Compact/Periodization` | A/H | `bf61e09c` |
| `Compact/Main` (`nashCompact`) | A/H (statement and assembly proof H, four lemmas A) | `7856eea9` |
| `Riemannian/Induced`, `Examples/Sphere`, `Examples/Negative` | A/H | `c61ad094` |
| `Riemannian/Pullback` | A/H | `d8adebcb` |
| `Examples/FlatTorus` | A/H (statements by Slate, leaves A) | `1c05ddd8` |

May 2026 stage jobs (torus Sobolev toolkit stages 1–8 and Theorem A stage 1, with
retakes), in submission order: `c9c0c69f`, `18d0b04c`, `2d9e0e3e`, `5c12ab8a`, `7d4a1962`,
`86cf1204`, `db5011bc`, `5260b235`, `044f9474`, `f7492130`, `c927618e`, `dd125817`,
`ff0fa63a`, `fab6317d`, `de5768c3`, `2a6a9795`. The per-stage correspondence is recorded
in the working repository from which this one was assembled. One further project on the
account, `f3ca88c8`, was a second submission of `GuntherIdentity` whose result was not used.

## Licence

Apache-2.0; see [`LICENSE`](LICENSE).
