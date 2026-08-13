# RTK Baseline Comparison (2026-08-13)

Initial comparison of command output sizes with and without rtk.

## Results

| Command | Raw Output | rtk Output | Savings |
|---------|-----------|------------|---------|
| `git status` | 747 bytes | 401 bytes | 46.3% |
| `flutter analyze` | 96 bytes | 96 bytes | 0% |

## Analysis

- **git status**: rtk compresses output by ~46% — removes verbose branch tracking info, formats untracked files compactly.
- **flutter analyze**: No compression (output was already minimal — "No issues found!"). rtk only compresses when there's redundant content to filter.

## Token Estimation

Rough token estimate (1 token ≈ 4 characters):
- `git status` raw: ~187 tokens → rtk: ~100 tokens (saves ~87 tokens per invocation)
- `flutter analyze` raw: ~24 tokens → rtk: ~24 tokens (no savings)

## Notes

- This is a single-point snapshot. C17 will analyze accumulated data over time.
- rtk's savings are most significant on verbose outputs (test results, build logs, long file lists).
- The OpenCode plugin (`~/.config/opencode/plugins/rtk.ts`) transparently rewrites commands — no workflow change needed.

## Methodology

```bash
# Raw
git status 2>&1 | wc -c

# rtk
rtk git status 2>&1 | wc -c
```

Date: 2026-08-13
rtk version: 0.42.4
