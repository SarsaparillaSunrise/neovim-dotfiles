# nvim config — recent additions (personal notes, untracked)

Scratch reference for the stuff added in the 2026-07-25 overhaul. Not tracked by
git (add to .gitignore if you want it to stop showing in `git status`).

## New keymaps

### Completion (blink.cmp — replaced nvim-cmp)
- `<C-Space>` (insert) — open completion menu / toggle docs
- `<Tab>` / `<S-Tab>` — cycle items
- `<CR>` — confirm
- `<C-b>` / `<C-f>` — scroll docs
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

## Removed / migrated
- coc-settings.json, vendored colors/solarized8.vim — deleted
- nvim-cmp + cmp-* + LuaSnip — replaced by blink.cmp
- `<CR>`=save and its BufWinEnter guard — gone; `<C-Space>`/`<leader>s` save,
  `<leader>S` saves without formatters
