---
name: git-town-merge-stack
description: Merge stacked GitHub pull requests to main/master in order using Git Town as the default local workflow and GitHub CLI for remote merges. Use when a repository uses stacked branches, PRs must be merged in parent-to-child sequence, and you need safe recovery for rebase-only repos, merge conflicts, or downstream PRs that auto-close during stack merges.
---

# Git Town Stack Merge

Execute remote stack merges safely and predictably.

## Inputs

Collect before starting:
- Ordered branch stack from parent to leaf
- Target base branch (`main` or `master`)
- Preferred merge mode (`rebase` or `squash`) based on repo settings

## Workflow

1. Map branch names to PRs and confirm order.

```bash
gh pr list --state all --head <branch> --json number,url,baseRefName,headRefName,state
```

2. Verify each PR is open and in expected base/head relationship.

```bash
gh pr view <pr> --json number,state,isDraft,baseRefName,headRefName,mergeable,mergeStateStatus,url
```

3. Sync/update the current stack locally before merging.

```bash
git town sync --stack
```

4. Inspect branch hierarchy locally to confirm parent-to-child sequencing.

```bash
git town branch
```

5. Read repository merge policy and select merge method that is allowed.

```bash
gh repo view <owner/repo> \
  --json rebaseMergeAllowed,squashMergeAllowed,mergeCommitAllowed
```

6. Merge remotely in strict order (parent to leaf) with `gh pr merge`.
- Use `--rebase` only when branch history is rebase-compatible.
- Use `--squash` when rebase is blocked or policy allows squash.
- Avoid `--delete-branch` on intermediate stack PRs.

```bash
gh pr merge <pr> --squash
# or
gh pr merge <pr> --rebase
```

7. After each merge, run `git town sync --stack` and re-check downstream PR base/mergeability before continuing.

```bash
git town sync --stack
gh pr view <next-pr> --json state,baseRefName,headRefName,mergeable,mergeStateStatus,url
```

## Recovery Playbooks

### Rebase-only error: `This branch can't be rebased`

1. Check whether squash is enabled.
2. If squash is enabled, merge with `--squash`.
3. If squash is not enabled, linearize branch history (remove merge commits), force-push, and retry `--rebase`.

## Downstream PR closed during stack merge

Common trigger: merging parent PR with `--delete-branch` while child PR still targets that branch.

1. Confirm child branch still exists on remote.
2. Create replacement PR from child head to `main/master`.
3. Continue stack using replacement PR number.

```bash
gh pr create --base main --head <child-branch> --title "<title>" --body "Replacement for #<old-pr>."
```

## Downstream PR becomes conflicting

1. Switch to the child branch via Git Town and run `git town sync --stack` to apply stack/base updates.
2. If sync reports conflicts, resolve them, commit, then run `git town sync --stack` again.
3. Re-check PR mergeability and merge.

```bash
git town switch
# select <child-branch> in the interactive list
git town sync --stack
# resolve conflicts
git add <files>
git commit --no-edit
git town sync --stack
```

## Completion Checks

1. Verify final state of all original/replacement PRs.

```bash
gh pr view <pr> --json number,state,mergedAt,url
```

2. Run repository-required validation gates after final merge.
- Follow local AGENTS.md or repo policy exactly.
- Example:

```bash
npm test
```

3. Clean up obsolete local branches with Git Town.

```bash
git town branch
git town delete <obsolete-branch>
```

## Output Format

Report:
- Final PR sequence actually merged (including replacement PRs)
- Any PRs closed/replaced and why
- Validation gate results
