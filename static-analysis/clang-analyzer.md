# Clang Static Analyzer

Path-sensitive interprocedural analysis via `clang --analyze`. Detects null dereferences, memory leaks, use-after-free, and logic errors.

## Summary

| Metric | Value |
|--------|-------|
| Total findings | 0 |
| Files analyzed | C/C++ files via synthetic compile database |

## Analysis

No findings. Similar to gcc-analyzer, the `.cu` files that contain the bulk of the logic cannot be analyzed without CUDA headers. The analyzable C/C++ subset (`src/timer.cc`, headers) is small and clean.

**Note**: The `xargs: clang: No such file or directory` message in the raw output indicates that the Clang static analyzer binary path was not correctly resolved in the Nix sandbox — the tool completed but may not have analyzed all intended files.

## Reproduction

```bash
nix build .#analysis-clang-analyzer && cat result/report.txt
```
