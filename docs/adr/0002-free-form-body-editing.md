# Free-form Body editing replaces Head/Tail path model

We dropped the single-path Dog (fixed Tail, one extendable Head, truncate-back removal, Tail-only loop closure) in favour of a **set of Body Cells** where any Cell can be removed at any time. The Dog may split into several Segments while editing; **Done is blocked until the Dog is one Connected Segment**. Touching between any Body Cells is legal, so loops need no special rule.

Why: playtesting showed truncate-from-middle was surprising; players expect a tapped Cell to be the one removed. Allowing removal anywhere and validating connectivity only at Done keeps editing forgiving while preserving the "one creature" rule at submit time.

Considered and rejected: keeping truncate-back (surprising in play); allowing removal only when the Dog stays connected (blocks natural edits on straight runs).

Consequences: supersedes the "Tail-closure only" exception and the simple-path invariant in ADR 0001 (its grid/tap/flood-fill reasoning still stands). Tail-fixed and Tail-anchored validation no longer apply. Hard to reverse once `BoardState`, the solver and generator assume a set of Cells rather than an ordered path.
