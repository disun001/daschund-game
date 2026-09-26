# Domain Glossary — Dachshund Enclosure Game

## Dog

The player's creature. A single continuous flexible body of fixed length, rendered as a long dachshund.

- **Head** — the end of the Dog the player directly drags. The only input surface in the game.
- **Tail** — the trailing end of the Dog. Not pinned; it follows the Head's path history (snake-like), so it is always in motion and never a fixed anchor point.
- **Body** — the continuous stretch of the Dog between Head and Tail. Its shape is fully determined by the recent path the Head has travelled (a fixed-length trailing chain), not independently controlled by the player.

## Board

A discrete grid of **Cells**. Each Cell is either empty, part of the Dog's Body, or occupied by a board element (Water, Apple, Cherry, Bee).

## Enclosure

A region of Cells that has no path of empty/passable Cells connecting it to the edge of the Board, once Dog Body and Water are both treated as impassable walls. Water and Dog Body jointly act as boundary material — an Enclosure does not require the Dog to close a loop entirely with its own Body.

## Decisions locked so far

- Control model: **free Head, trailing Body** (both Head and Tail move; neither is pinned). Chosen specifically so the player can't see a static anchor point that would telegraph where the loop must close.
- Win condition: **connectivity-to-edge check**, not literal head-meets-tail. After each move, any Cell region disconnected from the Board edge (through Dog Body and/or Water) counts as an Enclosure.
- Input model: **tap-to-place / tap-to-remove on a discrete grid** (not continuous drag). Tapping a Cell adjacent to the current Head extends the Body into it; this doubles as the correction mechanism (no separate undo control needed) — the exact removal rule (retract from Head only, vs. truncate from anywhere) is still open.
- Board representation: **discrete grid**, chosen over continuous/freeform space specifically because it makes enclosure detection a standard grid flood-fill/BFS rather than polygon/segment geometry, and keeps procedural generation tractable. The on-screen dachshund can still be rendered as a smoothed curve over the underlying grid path — the grid is a simulation detail, not necessarily the visual.
- Movement adjacency: **8-directional (orthogonal + diagonal)**, provisional — may revert to orthogonal-only after playtesting if diagonal movement doesn't feel right.
- Diagonal wall convention: **diagonal Body/Water pairs seal the corner gap between them** ("no squeezing") — a diagonally-touching pair of wall cells blocks fill/movement through the gap, matching the visual read of a closed boundary.
- Removal rule: **tap any Body cell to truncate back to that point** (that cell becomes the new Head, everything after it is removed in one tap). Chosen over Head-only retraction so a player who spots a better placement late doesn't have to undo one tap at a time.
- Self-crossing: **forbidden**. Tapping a cell already occupied by the Dog's own Body is never an "extend" — it is always interpreted as the truncation gesture (A5). The Dog is always a simple path; a Body cell is never occupied twice. Combined tap semantics: empty + adjacent-to-Head → extend; own-Body cell → truncate to that point; anything else (Water/Apple/Cherry/Bee/non-adjacent empty) → invalid, no-op.
- Length budget: **fixed cap on simultaneous Body length** ("Dog Length" — analogous to enclose.horse's wall budget). Extending past the cap is illegal until the player truncates elsewhere to free up length. Truncation refunds length immediately (consistent with A5) — the cap constrains current occupancy, not cumulative moves made.
- Board end condition: **live score + explicit "Done" action**. Score updates continuously as the player edits; the player taps Done when satisfied, locking in the final score and moving to a Results screen.
- Multiple Enclosures: **all disconnected regions are scored and summed**, not just the single best one. The flood-fill naturally finds every disconnected region at once.
- Scoring formula: **each enclosed empty Cell is worth 1 point** on its own, plus/minus Apple/Cherry/Bee modifiers on top. Matches enclose.horse's own model (enclosed grass there is worth 1 too) — raw enclosed area is itself a valid strategy, not just object-targeting.
- Bee penalty: **subtracts a fixed penalty per Bee** from its Enclosure's score (additive, not voiding). An Enclosure containing a Bee can still score positively if its other contents outweigh the penalty.
- Board edge: **not a wall**. The outer rim of the Board is where the connectivity flood-fill starts from (it functions as "outside," per enclose.horse) — it contributes nothing extra to sealing a region. A Body path only walls off a corner if it physically occupies border Cells at both ends, exactly like Water; there is no implicit assist from merely reaching the edge.
- Valid Enclosure anchors: a simple Body path (no self-crossing) can only seal a region if both its ends land on something already impassable — the Board's border, Water, or (see below) itself via Tail-closure. This makes the core mechanic a "cut a chord across existing boundaries" puzzle rather than "draw a closed loop anywhere."
- Self-touch / loop closure: **reopened, but restricted to the Tail only**. The Head may close a loop by moving onto the current Tail cell (when adjacent), which is the sole exception to self-crossing being forbidden (A6). Tapping any *other* own-Body cell still means truncate (A5), never close — this keeps the tap gesture unambiguous. A single Tail-closure always yields exactly one enclosed area (loop, plus a harmless dead-end stalk if the Body is longer than the loop); a second closure is impossible since the Tail is consumed into the loop, so multiple disjoint areas from self-touch alone cannot occur.
- Tail mobility: **fixed at the starting Cell for the whole board attempt**. No mechanic shrinks/moves the Tail end; only the Head end changes via extend/truncate. This makes Tail-closure a legible, learnable target without adding a second interaction.
- Starting Cell: **player-chosen**. A board loads with no Dog placed; the player's first tap on any empty Cell becomes both Head and Tail (Dog length 1). No separate "start" control — it's the same tap gesture as extending.
- Board validation: a candidate board is only accepted if a **solver pass confirms at least one legal anchor-pair path (border-border, border-Water, Water-Water, or Tail-closure) costs ≤ Dog Length and yields positive net score**. The solver only needs to find *some* qualifying path, not the optimal one.
- Water shapes: generator may place **both freestanding interior lakes (island shapes, enabling Water↔Water anchors) and border-touching bays/inlets (enabling border↔Water anchors)**.
- MVP sequencing: **hand-placed test boards first (5-10 boards), no generator/solver in v0**. Generation (F1/F2) and difficulty tuning are explicitly deferred until the core loop is proven fun.
- Technical representation: **Godot `TileMap` node backed by a plain 2D data array** (Cell enum: empty/body/water/apple/cherry/bee). The array is the source of truth for game logic (flood-fill, solver, input hit-testing); the TileMap only reflects it visually.
- Starting point values (tunable): **Cell +1, Apple +5, Cherry +10, Bee -5**.
- MVP board sequencing: **fixed designed order** through the 5-10 hand-placed boards (not shuffled), so the spread of test situations is played deliberately.
