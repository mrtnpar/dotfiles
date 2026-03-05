# dotfiles

Bootstrap script for terminal tooling, dotfiles, and AI-agent setup.

## What This Sets Up

- Homebrew tools: `nvm`, `git-town`, `jj`, `opencode`
- Node runtime via `nvm` pinned to `v25.2.1` (from `.nvmrc`)
- Codex CLI via npm: `@openai/codex`
- Linked dotfiles: `.vimrc`
- Local-editable copies from templates: `.gitignore_global`, `.gitconfig`, `~/.config/jj/config.toml`
- Codex config/prompt/rules templates
- OpenCode config template
- Repo-managed custom skills synced from `agents/skills`
- Third-party skills installed via `npx skills add ...`

## Usage

```bash
./install.sh
```

### Optional Flags

```bash
./install.sh --only tools
./install.sh --only links
./install.sh --only agents
./install.sh --only skills
./install.sh --only skills --pinned
```

- `--only`: run a single phase (`tools|links|agents|skills`)
- `--pinned`: for skills phase, attempts lock-based restore from `agents/skills-lock.json` first

## Skills Modes

- Default mode installs third-party skills from sources using explicit `npx skills add` commands.
- Pinned mode uses `agents/skills-lock.json` with `skills experimental_install` and `skills experimental_sync`.
- If pinned restore fails, installer falls back to explicit source installs.

## Local Overrides (Untracked)

- Codex: `~/.codex/config.local.toml`
- OpenCode: `~/.config/opencode/opencode.local.json`

These are merged into generated target configs and should remain local-only.

## Git/JJ Personal Identity

- `~/.gitignore_global`, `~/.gitconfig`, and `~/.config/jj/config.toml` are installed as local files (not symlinks), so machine-local/personal values stay local.
- Installer behavior:
  - existing local files are preserved
  - existing symlinks are converted to local files once
- If `~/.gitconfig` still has placeholders, set identity with:

```bash
git config --global user.name "Your Real Name"
git config --global user.email "you@example.com"
```
