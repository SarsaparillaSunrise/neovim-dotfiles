# nvim config — recent additions (personal notes, untracked)

Scratch reference for the stuff added in the 2026-07-25 overhaul. Not tracked by
git (add to .gitignore if you want it to stop showing in `git status`).

## New keymaps

### Completion (blink.cmp — replaced nvim-cmp)
- `<C-Space>` (insert) — open completion menu / toggle docs
- `<Tab>` / `<S-Tab>` — cycle items; **inserts as you cycle** — just keep typing,
  no confirm needed for plain-text matches
- `<CR>` — accept the selected item. Only *needed* when the item carries extras:
  auto-import edits or snippet expansion. Otherwise plain newline.
- `<C-e>` — dismiss (also undoes the Tab-inserted text)
- `<C-b>` / `<C-f>` — scroll docs
- Menu is instant now: LSP source is async, so buffer/path matches show
  immediately and pyright's items stream in (list may re-sort once).
- Signature popup: blink's built-in (`signature.enabled`). If it's flaky in real
  use, revisit — a manual trigger is one line.

### LSP quality-of-life
- Inlay hints: ON by default in LSP buffers. `<leader>ih` toggles.
- Document highlight: other uses of the symbol under the cursor light up on hover
  (CursorHold). No keymap; automatic.

### HTTP client (kulala) — `.http` files
- `<leader>Rs` — send request under cursor
- `<leader>Ra` — send all in file
- `<leader>Rr` — replay last
- `<leader>Rt` — toggle body/headers view
- `###` on its own line separates requests.

### Debugger (nvim-dap)
- `<leader>db` — toggle breakpoint
- `<leader>dB` — conditional breakpoint (prompts)
- `<leader>dc` — continue / start (pick a config on first run)
- `<leader>dn` — step over
- `<leader>di` — step into
- `<leader>do` — step out
- `<leader>dq` — terminate
- `<leader>du` — toggle the dap-ui panels
- **Setup:** needs `debugpy` in the project venv → `uv add --dev debugpy`.
- **FastAPI:** pick the "FastAPI (uvicorn)" config; it prompts for the app target
  (default `app.main:app`). Runs WITHOUT `--reload` on purpose (the reloader
  subprocess detaches from debugpy, so breakpoints wouldn't hit).

### Find & replace (grug-far)
- `<leader>sr` — project-wide search & replace with live preview (normal + visual)

### Harpoon — pin & jump (fits the tmux/i3/Aerospace mental model)
- `<leader>a` — pin the current file
- `<leader>h` — open the quick menu (reorder/remove here)
- `<leader>1` / `<leader>2` / `<leader>3` / `<leader>4` — jump to pinned file N
- Workflow: pin your router, service, schema, test → hop between them instantly,
  no fuzzy-find, no buffer cycling.

### Breadcrumbs (dropbar) — winbar
- Shows `path › Module › Class › method` at the top of the window. Passive, no
  keymap. This is the "I can finally see the path" fix.

### Refactoring
- LSP rename (already had it): `<leader>rn` — cursor on the symbol, type new name,
  renames every reference project-wide. This is the one you forgot how to use.
- Extract/inline (new, refactoring.nvim): `<leader>rr` — pops a menu of available
  refactors (extract function, extract variable, inline var, etc). Best in VISUAL
  mode: select the expression/block first, then `<leader>rr`.

## 2026-08-20 tuning session

### Kwargs filler — the big one
- `<leader>I` — the ghost `x=` labels at call sites are basedpyright inlay
  hints; this inserts them as REAL text. Type `greet("bob", 3)` positionally,
  `V` + `<leader>I` on the line → `greet(name="bob", times=3)`.
- Normal mode = one arg (dot-repeatable with `.`), visual = whole selection.
- Needs inlay hints on (they are by default; `<leader>ih` toggles).

### Diagnostics — no more nagging
- basedpyright now runs `typeCheckingMode = "standard"` (its default,
  "recommended", warned on EVERY unannotated parameter — 13 warnings on 14
  lines of normal untyped code). Standard = real type errors only.
- No auto-popup float anymore. `<leader>e` opens diagnostics on demand,
  `<leader>td` mutes them entirely (red DIAG OFF flag in statusline).
- NOTE: the typeCheckingMode setting must live under `basedpyright.analysis`,
  not `python.analysis` — it's silently ignored in the wrong namespace.

### Fixed: everything showing twice in gr/gd
- Cause: stale `pyright` still installed in mason alongside basedpyright, and
  `automatic_enable` enables EVERY installed server, not just ensure_installed.
  Both answered every request. Uninstalled pyright.
- If doubles ever come back: `:LspInfo` — and don't `:MasonInstall pyright`.

### Small stuff
- Persistent undo (`undofile`) — undo history survives closing files.
- `signcolumn = "yes"` — gutter no longer shoves code sideways when signs appear.

## Profiling — the plan (external tools, nothing in the repo)

Decision: **py-spy**. No ASGI middleware — deliberately keeping Python-specific
tooling out of the shared codebase. py-spy touches nothing: no code, no imports,
attach-look-detach. Dev is mostly on Linux (writing from a Mac).

Core commands (against a running uvicorn):
```
uvicorn app.main:app &                  # note the PID
sudo py-spy top --pid <pid>             # live top-style hot-function view; hammer endpoints
sudo py-spy record -o flame.svg --pid <pid> --duration 30   # flamegraph -> open in browser
```
- Flamegraph: width = time spent. Read hot paths straight off it.
- `--native` (Linux only): unwind into C extensions (pydantic-core, numpy, orjson).
  Add it when a hot path bottoms out in a Rust/C dep.
- Permissions: py-spy needs to ptrace the target. `sudo` works; or
  `sudo sysctl kernel.yama.ptrace_scope=0` for the session.
- Containers: run py-spy INSIDE the same container (or a sidecar sharing the PID
  namespace) with the `SYS_PTRACE` capability, targeting the in-namespace PID.

eBPF (Pyroscope / Parca): different job — always-on, fleet-wide continuous
profiling in prod. Not needed for ad-hoc "how do the hot paths break down." Also
Linux-only, so irrelevant for local work on the Mac.

Other profilers if py-spy isn't enough:
- `scalene` — line-level CPU + memory, splits Python vs native time. For digging
  into one hot path after py-spy points at the neighborhood.
- `line_profiler` (`kernprof` + `@profile`) — surgical per-line timing.
- `pyinstrument` — nice per-request call tree, BUT its best mode is ASGI
  middleware, which we're avoiding. CLI mode still fine for scripts/tests.

## Maintenance / watch list
- **refactoring.nvim** tracks an untagged `master` mid-rewrite and depends on
  `lewis6991/async.nvim` for its `async` module. If a `Lazy update` ever breaks
  refactoring, that's the first suspect — pin the commit or roll back.
- **blink signature popup**: still judging whether it's reliable. If it turns out
  flaky in real use, add a manual trigger (one line) rather than assuming.
- **Plugin installs**: use `:Lazy install` (adds missing only), NOT `:Lazy sync`,
  to avoid silently bumping unrelated plugins like treesitter/lspconfig.
- **Treesitter parsers** (main branch) install async into
  `~/.local/share/nvim/site/parser/`, not the plugin dir.

## Backlog — future alpha to explore (NOT installed)
Editing ergonomics (the real vim alpha now that IDE parity is mostly done):
- **nvim-surround** — add/change/delete surrounding quotes/brackets/tags
  (`ysiw"`, `cs"'`, `ds(`). Tiny, daily multiplier. Top pick.
- **treesitter-textobjects** — semantic motions: `vif`/`vaf` (function),
  select/swap arguments, `]m`/`[m` next/prev method. Great for refactor-heavy work.
- **neogen** — generate Python docstring stubs from a signature (PyCharm parity).
- **flash.nvim** / leap.nvim — jump anywhere on screen in a couple keystrokes
  (taste-dependent; some vimmers love it, some never want it).
- **fidget.nvim** — little LSP progress spinner (know when basedpyright is indexing).
- **nvim-coverage** — pytest coverage in the sign column.
- **persistence.nvim** — restore buffers/layout per project (nice for SSH/tmux
  reconnects).

## Removed / migrated
- coc-settings.json, vendored colors/solarized8.vim — deleted
- nvim-cmp + cmp-* + LuaSnip — replaced by blink.cmp
- `<CR>`=save and its BufWinEnter guard — gone; `<C-Space>`/`<leader>s` save,
  `<leader>S` saves without formatters
