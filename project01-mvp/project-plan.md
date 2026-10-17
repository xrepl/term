---
project: project01-mvp
status: active
depends-on: []
blocks: []
related:
  - https://github.com/xrepl/xrepl
---

# xREPL Term MVP

## Goal and definition of done

Provide a reusable LFE terminal library for capability detection, terminal/cursor control, hyperlinks and notifications, ANSI colour/style composition, inline images and small UI components with graceful degradation. Public delivery belongs in `src/`, `include/`, `examples/`, `README.md` and the packaged `xrepl_term` application on the implementation branch.

The [original implementation guide](artifacts/xrepl-term-impl.md) remains the detailed design reference. Its nine phases cover scaffolding, four modules and the colour DSL, tests, examples and final integration. Preserve its full success criteria and completion checklist, including a warning-free build, unit and property tests (100+ property cases), measured coverage >80%, manual WezTerm checks and iTerm2/Kitty checks if available, accurate working examples, installation and release-readiness evidence. The [ledger](ledger.md) keeps these acceptance obligations visible; historical implementation claims do not close them.

## Roadmap

Only roadmap scope is seeded now. There are no active arc or slice assignments, and no arc/slice directories, prompts or close documents are fabricated. Plan those in detail when a concrete follow-up is selected. The three capability arcs below organize the existing design rather than authorize new implementation:

| Planned arc | Usable capability and delivery | Required input | Historical design |
|---|---|---|---|
| `arc01-terminal-and-colour` | Core controls/capabilities, ANSI styling and composable pure/printing DSL, usable from public APIs and colour examples | LFE/rebar application scaffold and dependency configuration | Phases 1–4, original lines 45–1272; `src/xrepl-term.lfe`, `src/xrepl-term-colour.lfe`, `include/colours.lfe` |
| `arc02-inline-graphics` | Capability-aware file/data rendering through iTerm2/Kitty sequences, errors/fallbacks and image example | Bounded terminal/capability contract from Arc01; image fixture and a compatible terminal for visual checks | Phase 5, lines 1273–1580; `src/xrepl-term-graphics.lfe`, `examples/image-demo.lfe` |
| `arc03-ui-components` | Styled tables, trees, progress and spinner output, with usable examples | Colour/visual-length helpers and core progress/cursor primitives from Arc01; no graphics dependency | Phase 6, lines 1581–2050; `src/xrepl-term-ui.lfe`, table/tree examples |

The first usable increment is terminal controls and ANSI/DSL styling through Arc01, with its checks, docs and example included. Phases 7–9 (lines 2051–2772) apply testing, examples, packaging and final composition across these capabilities; they are retained as obligations, not separate activity-only arcs. Final composition must demonstrate that the public APIs, includes and examples work together as an installable dependency.

## Current state and evidence

Source baseline: `a68278ccc5633ea142a5b6475f78ce433c8c244f`. The repository contains four library modules, the application descriptor, one macro include, four examples and three unit-test modules. Commit `803bf85` claims 20 tests passing (8 core, 7 colour, 5 graphics); that is historical attestation, not a fresh run or proof of coverage. No formal slice plans, ledgers, progress reports, issued prompts or close/independent-verification records were found in the inspected local/remote history. The guide's completion boxes are unchecked.

Only `main` exists locally and remotely after fetching origin; there is no feature branch to recover. Tag `0.1.0` exists. This proves a tag is present, not the guide's entire release-readiness contract. [COMMIT_MSG.txt](artifacts/COMMIT_MSG.txt) is an untracked draft for the `uri_string:quote` correction already present in commit `1619552`; retain it as supporting history. Both original files are preserved exactly in project `artifacts/`, with [provenance and migration checks](artifacts/migration.md).

## Open findings and ownership

- **Acceptance evidence:** all project rows remain open. The guide expects `test/xrepl-term-ui-tests.lfe`, `test/xrepl-term-colour-proper.lfe` and `test/colour-macro-test.lfe` at different points; none exists in the inspected tree. Current graphics sequence tests explicitly accept error results as passing, so they do not prove successful encoding/display. Owner: the contributor assigned a future follow-up; reconcile against the original contract before claiming acceptance.
- **Coverage and terminal checks:** no fresh coverage, property-run or real-terminal receipts were established here. Current CI uses LFE/ltest and coverage minimum zero, which does not prove the guide's >80% requirement. Byte/sequence assertions and a real terminal's visual result are distinct checks. Owner: future contributor with the Operator for terminal availability.
- **Sixel scope:** the README/graphics module description advertises Sixel, but the current renderer dispatches only iTerm2, Kitty or no support; the guide also lists Sixel as a future enhancement. This conflict remains open for an explicit Operator decision; migration neither promises a new encoder nor erases the claim. Owner: Operator with the maintainer.
- **Return conventions:** the guide claims uniform result tuples while its own colour functions return strings and controls return `ok`; current source follows those mixed conventions. Preserve the existing useful API and resolve intended contracts before future changes. Owner: Operator with the maintainer.
- **Runtime/version and release drift:** the historical guide discusses older LFE/OTP compatibility and a `v0.1.0` release; current CI targets OTP 25–28, dependencies use `~> 2.2`, and the observed tag is `0.1.0`. Use pinned current configuration when executing checks and disposition historical differences explicitly. Owner: future contributor and Operator at release acceptance.

The guide's future enhancements (Sixel, true colour, themes, menus/forms, animations and a full TUI/event/layout/widget framework) remain historical suggestions, with the Sixel inconsistency noted above. This migration creates no additional project or implementation assignment. Next action belongs to the Operator: select the actual follow-up, then detail its owning arc/slice and acceptance evidence.

## Workflow and planning conventions

The Operator's 2026-10-17 request to do the same migration as protocol carries forward one-contributor Expedited Mode and authorization to commit/push. Sofie is the sole contributor for planning, migration and self-review; self-checks are **attested**, never independent verification. Existing acceptance/Operator gates remain in force. Expedited Mode does not start implementation from this seed roadmap.

Planning: orphan branch `planning`, worktree `.worktrees/planning`, project `project01-mvp`, as requested. Canonical project/arc/slice plans use sibling `ledger.md` records. The two cross-project historical records and migration provenance live in project `artifacts/`; new slice-produced supporting records default to the owning slice's `artifacts/`. Source, README usage documentation, examples and tests remain on `main`. Detailed arc/slice files are intentionally deferred to keep this initial project proportionate and follow plan-late/plan-deep.

## Version History

- v1.0 — 2026-10-17: migrate the existing guide/draft, seed a three-arc project roadmap and open acceptance ledger, retain historical gaps and defer execution detail until requested.
