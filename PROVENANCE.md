# Provenance record

Detailed per-file provenance, toolchain history, and Aristotle job identifiers
for the Nash isometric embedding formalization. This document supports the
README's summary account of who did what, and records the specifics needed for
independent verification against Harmonic's Aristotle logs and against the two
Mathlib pins this repository has used.

## Toolchain

- **Every Aristotle job** ran against Lean `v4.28.0`, Mathlib `v4.28.0`
  (commit `8f9d9cff6bd728b17a24e163c9402775d9e6a365`), Aristotle CLI 2.1.0.
- **Post-port build (September 2026)**: Lean `v4.31.0`, Mathlib `v4.31.0`
  (commit `fabf563a7c95a166b8d7b6efca11c8b4dc9d911f`).

## Per-file provenance table

Per file (A = authored by Aristotle — in the May 2026 stages the statements too, from Claude's
informal blueprints; from August, proofs from Claude-written principal statements, plus
auxiliary lemmas of Aristotle's own; H = directly authored by Claude; A/H = mixed: Claude
supplied the principal statements and some declarations and proofs, Aristotle the remaining
proof bodies and, where applicable, auxiliary lemma statements), with the Aristotle
project identifiers (first eight characters) where a file's leaves were proved in a
dedicated job. `Origin` records principal / original authorship; later compatibility or
linter-maintenance edits do not change a file's classification:

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
| `Examples/FlatTorus` | A/H (statements by Claude, leaves A) | `1c05ddd8` |

The v4.31 port did not shift any file's Origin classification — proof bodies
inherited from Aristotle remain Aristotle proof bodies, and the compatibility
declarations added by the port (`SmoothBumpCovering.embPiTan` and two lemma
wrappers in `Compact/WhitneyExtension`, `contDiff_matrix` in
`Torus/RealizableMetrics`, one `ChartedSpace` bridge instance in
`Compact/Main`) are Claude-authored. See the v4.31 port compatibility
disclosure below for the full account.

## v4.31 port compatibility disclosure

In the September 2026 v4.31 port, `NashEmbedding/Compact/WhitneyExtension.lean`
was converted to a module and uses `import all` to reach Mathlib's
`SmoothBumpCovering.embeddingPiTangent` API (non-public at v4.31.0 per Mathlib
PR #39886). The module adds three public wrappers (`embPiTan`,
`embPiTan_injective`, `embPiTan_injective_mfderiv`); the `exists_extension`
theorem (now `public`) has its conclusion adjusted to reference the wrapper
(`F (f.embPiTan x)` in place of `F (f.embeddingPiTangent x)`). The two are
definitionally equal within the defining module (as witnessed by the opening
`change` in the proof); the public wrapper is intentionally opaque downstream —
its definition body is not exposed. Two further compatibility declarations were added: `contDiff_matrix`
(a `@[fun_prop]` helper in `NashEmbedding/Torus/RealizableMetrics.lean`) and one
global `ChartedSpace` bridge instance in `NashEmbedding/Compact/Main.lean`.
Four declarations in `NashEmbedding/Examples/FlatTorus.lean` carry
`set_option backward.isDefEq.respectTransparency false` (Mathlib's own lever at
this boundary); their elaborated statements are not byte-identical across the
pins, but the drift consists entirely of instance-level, definitionally-equal
re-routes (Fintype instance choice, instance renames, derived TangentSpace
instance constants, coercion and class-hierarchy re-routes), classified
hunk-by-hunk with none outside these classes. Among pre-existing declarations,
the `exists_extension` API adaptation is the only source-level
theorem/definition type change (verified by parsed-signature comparison across
the port diff); no pre-existing NashEmbedding instance was renamed. All other
edits are proof- and elaboration-compatibility work, deprecation and API-name
migrations, and documentation/header cleanup.

## Ingredients absent from Mathlib (historical v4.28 survey)

Checked against Mathlib `v4.28.0` (the original pin, February 2026) and against
Mathlib master as of 2026-04-27; "absent" below means absent from both. This
survey was not rerun against the current `v4.31.0` pin and is retained here as
historical context for what the formalization added when it was assembled.

* The Sobolev scale on the torus — weighted ℓ² spaces on ℤⁿ with Rellich
  compactness, the sup bound and the three multiplication theorems, transported
  to position space. Mathlib master has since gained Sobolev (Bessel-potential)
  spaces on ℝⁿ via tempered distributions
  (`TemperedDistribution.memSobolev`, April 2026, after the pin); that is a
  different setting, and the compactness and algebra results used here are not
  among its statements.
* Extension of smooth functions along Mathlib's bump-covering embedding
  (`SmoothBumpCovering.exists_extension`); smoothness of the Moore–Penrose
  pseudo-inverse of an injective linear map (`contDiffAt_pinv`).
* Induced, pullback and product Riemannian metrics as
  `ContMDiffRiemannianMetric`s.

Not absent, and used: Mathlib's L² Fourier theory on the d-torus
(`UnitAddTorus.hasSum_sq_mFourierCoeff`), which `parseval_stdFourierCoeff`
transports to continuous 2π-periodic functions on ℝⁿ in this development's
conventions; the bump-covering embedding
`SmoothBumpCovering.embeddingPiTangent`; and the definition
`ContMDiffRiemannianMetric` itself.

## Aristotle job identifiers (May 2026 stage jobs)

May 2026 stage jobs (torus Sobolev toolkit stages 1–8 and Theorem A stage 1,
with retakes), in submission order: `c9c0c69f`, `18d0b04c`, `2d9e0e3e`,
`5c12ab8a`, `7d4a1962`, `86cf1204`, `db5011bc`, `5260b235`, `044f9474`,
`f7492130`, `c927618e`, `dd125817`, `ff0fa63a`, `fab6317d`, `de5768c3`,
`2a6a9795`. The per-stage correspondence is recorded in the working
repository from which this one was assembled.

One further project on the account, `f3ca88c8`, was a second submission of
`GuntherIdentity` whose result was not used.
