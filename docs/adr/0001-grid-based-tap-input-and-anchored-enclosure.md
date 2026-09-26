# Grid-based tap input with anchor-only enclosures

The original concept was a continuously-dragged flexible body that closes a loop on itself ("nose meets tail"). We instead adopted a **discrete grid board with tap-to-place/tap-to-remove input** (Head extends into an adjacent empty Cell on tap; tapping an own-Body Cell truncates back to it), and made **self-crossing forbidden except a single Tail-closure**, meaning any Enclosure must be sealed by a simple path anchored at both ends to something already impassable (Board border, Water, or its own Tail).

We picked this over a freeform continuous/drag model or an unrestricted self-crossing model because: (1) it makes the mistake-correction problem (a wrong turn ruining the whole attempt) solvable with zero extra UI — tapping *is* the undo; (2) it turns enclosure detection into a standard grid flood-fill/BFS instead of polygon/segment geometry, which is dramatically simpler to implement and to validate procedurally; (3) it gives Water and the Board border genuine strategic weight as anchor points, rather than being purely decorative obstacles.

Considered and rejected: continuous drag with trailing body (Snake-like) — rejected because a wrong turn is unrecoverable without a full restart; continuous drag with a pinned Tail — rejected because a static anchor telegraphs the solution; unrestricted self-crossing (multiple simultaneous loops) — rejected because it reintroduces double-occupied-cell geometry and can split the board into multiple disjoint regions, which we explicitly want to avoid (always exactly one enclosed area from self-touch).

This is hard to reverse once the grid, flood-fill, and generator/validator are built around it — a future reader seeing "why is this a grid game with tap controls, not a smooth drag-the-dog game?" should look here.


> **Partly superseded by [ADR 0002](0002-free-form-body-editing.md):** the single-path Dog, truncate-back removal and Tail-closure exception no longer apply. The grid, tap input and flood-fill reasoning still stand.
