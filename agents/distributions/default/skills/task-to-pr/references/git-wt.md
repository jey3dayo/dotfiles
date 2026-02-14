# git-wt quick reference

Quick reference for basic git-wt operations. For comprehensive documentation, see the [git-worktree skill](../../git-worktree/SKILL.md).

## Basic Commands

- List worktrees: `git wt list`
- Create worktree: `git wt create <branch>`
- Switch worktree: `git wt switch <branch>`
- Remove worktree: `git wt remove <branch>`
- Remove worktree (force): `git wt remove -f <branch>`

## Common Options

- Custom path: `git wt create <branch> --path <path>`
- Copy files: `git wt create <branch> --copy <file>`
- From existing branch: `git wt create -b <existing-branch>`
- From specific commit: `git wt create <branch> --start-point <ref>`

## Configuration

- Set base directory: `git config wt.basedir ".worktrees"`
- Auto-setup remote: `git config wt.autoSetupRemote true`
- Copy files automatically: `git config wt.copyFiles ".env,.env.local"`

## Zsh Integration

- Interactive create: `gwtc`
- Interactive switch: `gwts`
- Interactive remove: `gwtr`
- List: `gwtl`

## Learn More

For detailed documentation, workflows, and troubleshooting:

- [git-worktree skill](../../git-worktree/SKILL.md) - Main documentation
- [Command Reference](../../git-worktree/references/git-wt-commands.md) - All commands
- [Workflows](../../git-worktree/references/workflows.md) - Practical patterns
- [Troubleshooting](../../git-worktree/references/troubleshooting.md) - Problem solving
