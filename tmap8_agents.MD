# AGENTS.md

## Environment
- Use the MOOSE conda environment (`conda activate moose`)
- If `./tmap8-opt` or `run_tests` throws an error, stop and ask the user
- Pre-commit hooks handle all formatting and input file validation on every `git commit` — do not invoke `clang-format`, `black`, or `hit format` manually
- `moose/framework/contrib/hit/hit check <file>.i` is available to validate input files during development — use it before committing

## Before writing any code or input file
- Browse `doc/content/` to understand documentation standards and existing patterns before starting work
- Before writing a new C++ class, look through existing MOOSE classes in the codebase to confirm expected syntax and patterns
- Documentation in `doc/content/` may not accurately reflect current code behavior — once you identify a class to use in an input file, find its C++ implementation and read it to confirm the class does what you expect before writing the input file

## C++ code
- Every new class requires a MOOSE test system test in `test/tests/` before committing
- Every new class requires a MooseDocs page following existing TMAP8 doc structure
- Never hardcode physical parameters — first check if it is already defined in `doc/content/source/utils/TMAP8PhysicalConstants`, and if not available, expose everything through `addParam`
- Code is unit-agnostic; units live in input files only

## Input files
- Before writing an input file, look through existing MOOSE and TMAP8 classes to confirm object names and parameter syntax
- Use `moose/framework/contrib/hit/hit check <file>.i` to validate before committing
- Use `./tmap8-opt -i <file>.i` to run input files
- Write parameter values in the units the reference source used; convert explicitly using the MOOSE units system with the conversion documented in a comment
- State the unit system at the top of every input file in a comment block

## Testing
- Run tests only when `.C`, `.h`, or `test/tests/` files change
- Run only the affected module: `./run_tests -j<N> --re <module>`

## Session log
- Every session must be associated with a GitHub issue on `idaholab/TMAP8`; ask the user for the issue number at the start of the session if one is not provided, or create one if the user instructs you to
- **SQA requirement:** When creating a GitHub issue with `gh`, you must use the appropriate template from `.github/ISSUE_TEMPLATE/`; read the available templates first, select the one that fits (e.g. `bug-report.md` for bugs, `feature-request.md` for new features or tasks), and populate all sections in the template body — passing a bare description without following the template structure is not acceptable
- Before committing, copy the raw `.jsonl` session file for the current session into `doc/content/agent/<issue-number>/`; the session file is the most recently modified `.jsonl` under `~/.claude/projects/-Users-bhavcv-projects-TMAP8/`

## Committing
- Commit at minimum after: every input file that successfully runs, every test that passes or fails, and every new class added
- If a test or run failed, commit the failure state first (include the full error message in the commit body), then commit the fix separately
- Every commit must reference the associated GitHub issue (e.g. `Refs #<issue-number>` or `Closes #<issue-number>` as appropriate) in the commit message
- **Every commit must include an updated copy of the session `.jsonl`** — before staging, copy the current session file from `~/.claude/projects/-Users-bhavcv-projects-TMAP8/<session-id>.jsonl` to `doc/content/agent/<issue-number>/` and stage it; this is a critical SQA requirement
- Every commit must include these trailers:
```
Refs #<issue-number>
AI-assisted: true
AI-model: <model name>
AI-version: <model version>
Co-Authored-By: <model name> <noreply@anthropic.com>
```

## Pull requests
- PR description must include: physics/modeling assumptions made, AI reasoning log (decision points and alternatives considered), and tests added
- Never merge autonomously

## Never do
- Modify existing passing tests without explicit user instruction
- Modify the build system without explicit user instruction
- Make physics modeling decisions without flagging them to the user
- Suppress or bypass test failures
