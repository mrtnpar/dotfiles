---
name: effectcraft
description: Operate the EffectCraft CLI — a headless Rust motion-graphics compositor (After Effects-style) for building comps, animating layers, applying effects, rendering video/stills, scripting, Lottie export. Use when the user wants to create or edit motion graphics, animations, title cards, renders, or asks about effectcraft-cli.
---

# EffectCraft CLI

Headless motion-graphics compositor (clean-room After Effects reimplementation, pure Rust). v0.6.0: 665 engine commands, 306 effects, AE-compatible scripting + expressions, renders to h264/hevc/av1/prores/webm/png/jpeg/tiff/exr/gif/wav/aiff, Lottie + FCP7 XML/OTIO/EDL/AAF interchange. Binary: `~/.local/bin/effectcraft-cli` (in PATH).

## The lifecycle model — read this first

**Every invocation is a fresh headless engine. Nothing persists between invocations except via project files.**

- Default project: the bundled **demo** project. Override with `--project F.ecproj`, a positional `.ecproj` path, or `--empty`.
- **GOTCHA: `script` mode starts with an EMPTY project by default** (unlike every other subcommand). Pass `--demo` or `--project` explicitly when scripting against content.
- Save with `--save` (to the opened file) or `--save-as F`. An edit without a following `--save` in the SAME invocation is lost.
- Exit codes: 0 ok; 1 = runtime error (prints `{"error": ...}`); 2 = usage error before anything ran.
- `--json` = one compact JSON document on stdout. `--gpu` = GPU compositor. `--bridge PORT` = drive a live desktop app instead of headless.

Create a project: `effectcraft-cli --empty exec file.saveAs --params '{"path":"main.ecproj"}'` (top-level `--save-as` alone does nothing — it needs a subcommand).

## CLI surface

```sh
effectcraft-cli info [--json]                        # project + engine summary
effectcraft-cli commands [--filter TEXT] [--json]    # engine command catalog (params docs included)
effectcraft-cli exec <command-id> [--params JSON]    # one engine command; positional JSON also works:
                                                     #   exec layer.newSolid '{"color":"#3366ff"}'
effectcraft-cli exec --list --schemas --json         # all commands with JSON Schemas
effectcraft-cli run [file.ecproj] <id> <json> [<id> <json> ...]   # chain engine commands in ONE session
effectcraft-cli props <comp> <layer> [--flat]        # property tree with paths  ('-' = active comp)
effectcraft-cli get <comp> <layer> <path> [--time S]
effectcraft-cli set <comp> <layer> <path> <value> [--time S] [--expression E]
effectcraft-cli render-frame [--comp C] [--time S | --frame N] [--max-side PX | --scale K] [--out F.png] [--transparent]
effectcraft-cli render [--comp C] --out FILE [--format F] [--start S] [--end S] [--work-area] [--fps N] [--channels rgb|rgba] ...
effectcraft-cli script FILE.jsx | --eval CODE        # AE-style JS; writeLn printed; errors → file:line:col, exit 1
effectcraft-cli mcp [--bridge PORT]                  # MCP server (JSON-RPC stdio)
effectcraft-cli bench [...]                          # render timings; --gpu compares CPU/GPU
```

Global flags go anywhere: `--project F | --demo | --empty`, `--save`, `--save-as F`, `--json`, `--gpu`, `--bridge PORT`.

## Engine command model

Everything is an engine command with a stable id and JSON params (menus, CLI, MCP all share them).

- **Only engine commands can go in `run`/`exec` chains.** Top-level subcommands (`get`, `set`, `render-frame`, `render`, `props`) CANNOT appear inside `run`. Rendering a movie inside `run` uses `renderQueue.add` + `renderQueue.render {"wait":true}`.
- Unknown param keys are rejected **with the accepted-key list** — read the error, it's the doc.
- Commands needing an active comp fail with "no composition is open" on `--empty` — create/open a comp first.
- `engine.batch` (MCP `batch`) runs steps in one call + one undo step; string params `"\"$N\""` / `"\"$N.key\""` reference step N's result (`{"layer":"$1.layer"}`). A failing step rolls back the whole batch.
- Namespaced highlights: `comp.*` (25), `layer.*` (105), `prop.*` (16), `keys.*` (40), `effect.*` (16), `track.*` (22), `camera.*` (19), `roto.*` (14), `mask.*`, `text.*`, `renderQueue.*` (20), `file.*` (58, incl. import/export), `footage.*`, `edit.*` (26, incl. history).

## Keyframe truth table (verified — common source of silent bugs)

| Method | On static property | Notes |
|---|---|---|
| engine `prop.set {layer, path, value, time}` | **NO keyframe** — overwrites static value, last write wins | Only keys when property already animated (stopwatch on) |
| engine `prop.addKey {layer, path, time, value}` | **creates keys + stopwatch** | Use this inside `run`/`exec` chains |
| top-level `set <comp> <layer> <path> <value> --time S` | **creates keyframe** | Still needs `--save` to persist |
| script `prop.setValueAtTime(t, v)` | **creates keys** | times are COMP seconds in scripts |
| MCP `add_keyframe {layer, path, keys:[...], interpolation}` | **creates keys** | best ergonomic |

Keyframe times are **layer time** (= comp time unless layer offset/stretched). `get_property`/`render-frame` take comp time. Times snap to frame boundaries (e.g. 1.0 → 1.001 at 29.97fps).

## Referencing

- Comp: id, name, or `-` (active). Layer: id, `#n` (1-based from top), or name. Property paths from `props`/`get_layer`: `transform/position`, `effects/#1/blurriness`, `text/sourceText`; `@57` = by uid, works as a whole path.
- **Name things at creation** — `layer.newText`, `layer.newSolid`, `layer.newNull`, `layer.newShape`, `layer.newCamera`, `layer.newLight` all take `name`; later calls reference them by name. Bad references error (never silent no-op).
- Values: JSON (`50`, `[960,540]`, `[1,0,0,1]` color, `"#ff0000"`).

## Scripting (AE-style)

```js
var c = app.project.items.addComp("Main", 1920, 1080, 1, 4, 30); // name w h aspect dur fps
var t = c.layers.addText("Hi");
var fx = t.property("Effects").addProperty("Gaussian Blur");
var o = layer.property("Transform").property("Opacity");
o.setValueAtTime(0, 0); o.setValueAtTime(1, 100);    // creates keys, COMP time
t.property("Transform").property("Position").expression = "wiggle(2,50)";
app.run("layer.new3dPrimitive", {kind:"cube"});      // call any engine command from script
app.beginUndoGroup(); ... app.endUndoGroup();        // wrap loops so one undo reverts all
```

- Write with `writeLn`/`$.writeln`/`alert`; last expression's value prints too.
- **Sandbox**: scripts may read files only in the project folder; no file writes or network unless Preferences ▸ Scripting & Expressions allows it.
- Script mode starts EMPTY (see lifecycle gotcha) → `effectcraft-cli --demo script --eval '...'` or `--project`.

## Rendering & export

```sh
# Movie via renderQueue (works inside run chains):
effectcraft-cli proj.ecproj run renderQueue.add '{"comp":"Main","format":"h264","output":"out.mp4","timeSpan":"comp"}' \
  renderQueue.render '{"wait":true}'
# Or top-level:
effectcraft-cli proj.ecproj render --comp Main --out out.mp4 --format prores
# Still frame (for agent self-verification):
effectcraft-cli proj.ecproj render-frame --time 1 --max-side 640 --out f.png
# Lottie (check returned warnings — most effects/cameras/layers styles can't be expressed):
effectcraft-cli proj.ecproj exec file.exportLottie '{"comp":"Main","path":"out.json","includeExpressions":true}'
# Premiere/NLE interchange:
effectcraft-cli exec file.importTimeline '{"path":"edit.xml"}' proj.ecproj --save
effectcraft-cli exec file.exportTimeline '{"comp":"Main","path":"Main.xml"}' proj.ecproj
```

Channels `rgba` for alpha; ProRes 4444 / WebM VP9 for alpha video. `--transparent` on render-frame keeps alpha.

## Agent workflow loop

1. Orient: `effectcraft-cli <proj> info --json` → project items + active comp.
2. Build: one `run` chain per logical step (create comp → layers → keys → effects). `exec` returns JSON you can chain from.
3. Verify visually: `render-frame --max-side 640 --out /tmp/f.png` and Read the PNG. Check values with `get`, expression errors with `exec expr.errors '{"comp":"Main"}'`.
4. Save: `--save` on the final invocation of each milestone.

Canonical example (verified end-to-end):

```sh
effectcraft-cli --empty run \
  comp.new '{"name":"Demo","width":1280,"height":720,"frameRate":30,"duration":3}' \
  layer.newText '{"text":"Hello","size":120,"position":[640,360],"name":"Title"}' \
  prop.addKey '{"layer":"Title","path":"transform/opacity","time":0,"value":0}' \
  prop.addKey '{"layer":"Title","path":"transform/opacity","time":1,"value":100}' \
  prop.addKey '{"layer":"Title","path":"transform/opacity","time":2,"value":0}' \
  renderQueue.add '{"comp":"Demo","format":"h264","output":"demo.mp4","timeSpan":"comp"}' \
  renderQueue.render '{"wait":true}' --save-as demo.ecproj
```

## Effects

306 effects, AE-compatible names/params (e.g. `Glow`, `Keylight (1.2)`, `Warp Stabilizer`). Address by name or id (`ec.blur.gaussian`). Params by id under `effects/#n/`.

```sh
effectcraft-cli proj.ecproj exec effect.list '{"filter":"glow"}'        # catalog with param defaults
effectcraft-cli proj.ecproj run effect.apply '{"layer":"Title","effect":"Glow"}' \
  prop.set '{"layer":"Title","path":"effects/#1/intensity","value":2}'
```

`effect.apply` returns `{effects:[uid], paths:["effects/#2"]}` — use the returned path for subsequent `prop.set`. WASM plug-ins: `effect.plugins.load/list`.

## Advanced (see references/agents.md)

- **Motion tracking** `track.motion/setPoint/analyze{wait}/apply`, **mask tracking** `track.mask` (incl. face), **Warp Stabilizer** `warp.analyze`, **3D camera tracker** `track.camera`/`camera.points/createFromSolve`, **Roto Brush** `roto.stroke/propagate/freeze` (+ downloadable ML models `roto.model.download`).
- **Text**: runs, per-range styling via `layer.setText {range:[s,e], size, fill}`, fonts via `text.fonts {query}` (3 bundled + system), OpenType features `text.fontFeatures`.
- **Expressions**: full AE expression language; `get_property` returns `evaluated` vs `value` + `expressionError`; failed syntax stays disabled, renders `value`.
- **Gradients**: `set_property {"path":"contents/gfill/colors","value":["#0080ff","#ffff00"]}`.
- **History**: `edit.history.list` tree + `goto` any state/branch. Undo levels: `prefs.set {"key":"general.undoLevels","value":99}`.
- **Templates**: `templates.list/create/saveAs`.
- **MCP mode**: `claude mcp add effectcraft -- ~/.local/bin/effectcraft-cli mcp --project work.ecproj`; `--autosave` checkpoints each edit; `--bridge 9877` attaches a live desktop app (adds `screenshot`, `ui_*` tools).

## References

- `references/agents.md` — **official agent guide** (564 lines): MCP tools, cookbook, pitfalls, tracking/roto/3D/text deep-dives. Read before complex work.
- `references/effects.md` — all 306 effects: ids, param counts, GPU/HDR support.
- `references/mcp.md` — MCP conventions, progress/cancellation.
- Live truth beats these files: `effectcraft-cli commands [--filter] --json` (always current), `exec --list --schemas --json`, `effectcraft-cli exec app.capabilities '{}'`.
- Upstream: github.com/storytold/effectcraft (docs/agents.md, docs/parity.md — 94% AE 2026 feature parity).
