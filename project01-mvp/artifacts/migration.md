# Term planning migration — 2026-10-17

The Operator requested the same standard planning migration as protocol, scaled to a few initial files. One contributor (Sofie), Expedited Mode, commit/push authority and the standard `project01-mvp` layout carry forward. The orphan branch/worktree is `planning` at `.worktrees/planning`. The project has a plan, an open ledger and a three-arc roadmap; detailed arc/slice records wait for actual assignments.

## Provenance and relocation

Source baseline: `a68278ccc5633ea142a5b6475f78ce433c8c244f`. The tracked guide has historical revisions at `803bf851ce364295c47aac92fa470d7e176e0954` (initial implementation) and `16195527ff745698b3b95db92fefa2ce26a1345f` (URI encoding correction). Main retains both historical revisions; planning holds exact current snapshots without inheriting implementation ancestry. The commit-message draft was untracked at intake and now gains durable history.

| Original source path | Destination relative to project | SHA-256 | Provenance |
|---|---|---|---|
| `docs/design/xrepl-term-impl.md` | `artifacts/xrepl-term-impl.md` | `1eeb008c4c608e27fcaf59f5095836b2a4c95b01fb7cc5f508b8a7b345b1de4e` | tracked at source baseline; 73264 bytes, 2884 lines |
| `COMMIT_MSG.txt` | `artifacts/COMMIT_MSG.txt` | `c8e8297fd968a0a9fc9d41f44ba38f1f9f5974852072f72a7a2a70246bbad3f8` | untracked at intake; 333 bytes, 8 lines |

Archived text, example code, unchecked completion boxes, historical paths and claims remain byte-for-byte unchanged. The guide spans the whole library, so its project-level artifact placement follows the same migration convention as protocol. Future slice outputs use the slice's `artifacts/`. Neither file is executable source or a fresh verification receipt.

A successful `git fetch origin` confirmed only `main` locally/remotely and discovered tag `0.1.0`; no extra feature branch or unique branch documents need recovery. `git log --all --name-only` found only the existing guide among planning records. The static test inventory is 8 core, 7 colour and 5 graphics tests; the implementation commit's “20 tests, 100% passing” is historical attestation.

## Self-check and limits

Exact archive hashes, tracked-blob provenance, removal of the old source paths, authored local links, seven open project rows, orphan ancestry and unchanged implementation/test/include/example/config/CI/license files are checked during migration. The source diff is limited to planning navigation/instructions, ignoring `.worktrees/` and deleting the tracked guide after preservation.

Runtime, coverage, property and terminal-display tests are not run for this documentation migration. Their acceptance remains open. Initial design prose is preserved, including inherited whitespace; authored-file whitespace is checked separately. Self-checks do not claim independent implementation acceptance.

## Repeat the migration checks

From `.worktrees/planning`, run the following with Python 3. It checks the relocation mapping above, current source preservation relative to the pinned baseline, canonical project records and navigation. Run after both branches have been committed.

```sh
python3 - <<'CHECK'
from pathlib import Path
import hashlib, re, subprocess
root = Path.cwd()
source = (root / '../..').resolve()
project = root / 'project01-mvp'
record = (project / 'artifacts/migration.md').read_text()
rows = re.findall(r'^\| `([^`]+)` \| `([^`]+)` \| `([a-f0-9]{64})` \|', record, re.M)
assert len(rows) == 2
for old, new, expected in rows:
    assert hashlib.sha256((project / new).read_bytes()).hexdigest() == expected
    assert not (source / old).exists(), old
    if old.startswith('docs/'):
        blob = subprocess.check_output(['git', '-C', str(source), 'show', 'a68278ccc5633ea142a5b6475f78ce433c8c244f:' + old])
        assert hashlib.sha256(blob).hexdigest() == expected
subprocess.run(['git', '-C', str(source), 'diff', '--exit-code', 'a68278ccc5633ea142a5b6475f78ce433c8c244f', '--', 'src', 'include', 'test', 'examples', 'rebar.config', 'rebar.lock', '.github', 'LICENSE'], check=True)
assert subprocess.check_output(['git', 'branch', '--show-current'], text=True).strip() == 'planning'
assert subprocess.run(['git', 'merge-base', 'HEAD', 'a68278ccc5633ea142a5b6475f78ce433c8c244f'], capture_output=True).returncode == 1
tracked = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', 'HEAD'], text=True).splitlines()
assert not any(p.startswith(('src/', 'test/', 'include/', 'examples/', '.github/')) or p in ('rebar.config', 'rebar.lock') for p in tracked)
ledger = (project / 'ledger.md').read_text()
claims = [line for line in ledger.splitlines() if line.startswith('| P-')]
assert len(claims) == 7 and all(line.split('|')[6].strip() == 'open' for line in claims)
links = 0
for doc in root.rglob('*.md'):
    if doc == project / 'artifacts/xrepl-term-impl.md':
        continue
    for target in re.findall(r'\[[^\]]*\]\(([^)]+)\)', doc.read_text()):
        if '://' not in target and not target.startswith('#'):
            assert (doc.parent / target.split('#')[0]).exists(), (doc, target)
            links += 1
assert not list(project.glob('arc*')) and not list(project.glob('slice*'))
print(f'PASS: 2 exact archives, unchanged implementation, orphan planning, 7 open rows, {links} authored local links; arc/slice detail deferred.')
CHECK

git diff-tree --root --no-commit-id -r --check HEAD -- . ':(exclude)project01-mvp/artifacts/xrepl-term-impl.md' ':(exclude)project01-mvp/artifacts/COMMIT_MSG.txt'
```

Commit and push receipts are in each branch's Git log and the task completion report. [Project plan](../project-plan.md) records current findings and next-action ownership; the original guide remains the detailed design reference.
