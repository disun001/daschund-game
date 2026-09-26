# Domain Glossary — Dachshund Enclosure Game

## Dog

The player's creature: a set of **Body** Cells, rendered as a long dachshund. It has no fixed Head or Tail — every Body Cell is equal and any Body Cell can be removed.

- **Body** — the Cells the Dog currently occupies. Total Body size is limited by Dog Length.
- **Segment** — a maximal group of Body Cells connected to each other through 8-directional adjacency (see diagonal convention below).
- **End** — a Body Cell with at most one adjacent Body Cell. A Segment shaped like a ring has no Ends.
- **Connected Dog** — the Dog has exactly one Segment. The Dog may be split into several Segments while editing, but the player cannot press Done until it is Connected.

## Board

A discrete grid of **Cells**. Each Cell is either empty, part of the Dog's Body, or occupied by a board element (Water, Apple, Cherry, Bee).

## Enclosure

A region of Cells that has no path of empty/passable Cells connecting it to the edge of the Board, once Dog Body and Water are both treated as impassable walls. Water and Dog Body jointly act as boundary material — an Enclosure does not require the Dog to close a loop entirely with its own Body.

## Decisions locked so far

- Control model: **free-form Body editing** — no pinned or distinguished Head/Tail. Superseded the earlier "free Head, trailing Body" model (see ADR 0002).
- Win condition: **connectivity-to-edge check**, not literal head-meets-tail. After each move, any Cell region disconnected from the Board edge (through Dog Body and/or Water) counts as an Enclosure.
- Input model: **tap-to-place / tap-to-remove on a discrete grid** (not continuous drag). Tapping is also the correction mechanism; no separate undo control.
- Board representation: **discrete grid**, chosen over continuous/freeform space specifically because it makes enclosure detection a standard grid flood-fill/BFS rather than polygon/segment geometry, and keeps procedural generation tractable. The on-screen dachshund can still be rendered as a smoothed curve over the underlying grid path — the grid is a simulation detail, not necessarily the visual.
- Movement adjacency: **8-directional (orthogonal + diagonal)**, provisional — may revert to orthogonal-only after playtesting if diagonal movement doesn't feel right.
- Diagonal wall convention: **diagonal Body/Water pairs seal the corner gap between them** ("no squeezing") — a diagonally-touching pair of wall cells blocks fill/movement through the gap, matching the visual read of a closed boundary.
- Removal rule: **tapping a Body Cell removes only that Cell**, at any time, including middle Cells. The Dog may become split into several Segments; Done is disabled until it is a Connected Dog.
- Split Dog scoring: **all Body Cells count as walls even when the Dog is split**, so the live score always matches the board. The UI shows a "Dog is split" warning and Done is disabled until the Dog is Connected.
- Extension rule: **an empty Cell can be placed only if it is adjacent to an End** (or it is the very first Body Cell on the Board). Body Cells may not be added next to a middle Cell, so the Dog stays a set of simple paths rather than a branching blob.
- Self-crossing: a Cell is never occupied twice. Tapping an own-Body Cell is always removal, never extension.
- Length budget: **fixed cap on simultaneous Body length** ("Dog Length" — analogous to enclose.horse's wall budget). Extending past the cap is illegal until the player removes Body Cells elsewhere. Removal refunds length immediately — the cap constrains current occupancy, not cumulative moves made.
- Board end condition: **live score + explicit "Done" action**. Score updates continuously as the player edits; the player taps Done when satisfied, locking in the final score and moving to a Results screen.
- Done behaviour: Done appears once a Dog is placed. Pressing it **freezes** the board (taps are ignored) and stores a **final report** — a snapshot of the Enclosure/score query. The Results screen shows the total and per-Enclosure tally from that snapshot.
- Multiple Enclosures: **all disconnected regions are scored and summed**, not just the single best one. The flood-fill naturally finds every disconnected region at once.
- Scoring formula: **each enclosed empty Cell is worth 1 point** on its own, plus/minus Apple/Cherry/Bee modifiers on top. Matches enclose.horse's own model (enclosed grass there is worth 1 too) — raw enclosed area is itself a valid strategy, not just object-targeting.
- Own-value scoring: an Apple/Cherry/Bee Cell scores **only its own value, replacing the +1** (e.g. an enclosed Bee is -5, not -4). Only empty enclosed Cells score +1.
- Bee penalty: **subtracts a fixed penalty per Bee** from its Enclosure's score (additive, not voiding). An Enclosure containing a Bee can still score positively if its other contents outweigh the penalty.
- Board edge: **not a wall**. The outer rim of the Board is where the connectivity flood-fill starts from (it functions as "outside," per enclose.horse) — it contributes nothing extra to sealing a region. A Body path only walls off a corner if it physically occupies border Cells at both ends, exactly like Water; there is no implicit assist from merely reaching the edge.
- Valid Enclosure anchors: a Body path can only seal a region if both its ends land on something already impassable — the Board's border, Water, or the Dog's own Body. This makes the core mechanic a "cut a chord across existing boundaries" puzzle rather than "draw a closed loop anywhere."
- Loop closure: **touching is free** — a new Body Cell may touch any other Body Cell, so a ring is just Body Cells adjacent to each other and needs no special rule. Enclosure detection (flood-fill) seals it like any other wall.
- Tail mobility: **retired** — there is no Tail (see ADR 0002).
- Starting Cell: **player-chosen**. A board loads with no Dog; the first tap on any empty Cell places a Body Cell (Dog length 1).
- Board validation: a candidate board is only accepted if a **solver pass confirms at least one legal anchor-pair path (border-border, border-Water, Water-Water, or a Body ring) costs ≤ Dog Length and yields positive net score**. The solver only needs to find *some* qualifying path, not the optimal one.
- Water shapes: generator may place **both freestanding interior lakes (island shapes, enabling Water↔Water anchors) and border-touching bays/inlets (enabling border↔Water anchors)**.
- MVP sequencing: **hand-placed test boards first (5-10 boards), no generator/solver in v0**. Generation (F1/F2) and difficulty tuning are explicitly deferred until the core loop is proven fun.
- Technical representation: **Godot `TileMap` node backed by a plain 2D data array** (Cell enum: empty/body/water/apple/cherry/bee). The array is the source of truth for game logic (flood-fill, solver, input hit-testing); the TileMap only reflects it visually.
- Starting point values (tunable): **Cell +1, Apple +5, Cherry +10, Bee -5**.
- MVP board sequencing: **fixed designed order** through the 5-10 hand-placed boards (not shuffled), so the spread of test situations is played deliberately.
- Board data: each board is **plain data** (`BoardData`: glyph rows + Dog Length cap) authored in `BoardCatalog`, separate from `BoardState` logic. `BoardSequence` plays them in fixed order; after Results, "Next board" instantiates a fresh `BoardState`. After the last board the game shows an **end-of-sequence** screen ("All boards complete") — no loop back.
