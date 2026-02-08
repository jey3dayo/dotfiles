# git-wt quick reference

- List worktrees: `git wt`
- Switch/create worktree: `git wt <branch|worktree>`
- Delete worktree and branch (safe): `git wt -d <branch|worktree>`
- Delete worktree and branch (force): `git wt -D <branch|worktree>`
- Default branch deletion is protected; override with `--allow-delete-default` only if necessary.
- Avoid auto-cd: `git wt --nocd <branch|worktree>`
- Set worktree base dir: `git wt --basedir "<path>" <branch|worktree>` or `git config wt.basedir "<path>"`
- Copy files into new worktree (useful for `.env.keys`): `--copyignored`, `--copyuntracked`, `--copymodified`
