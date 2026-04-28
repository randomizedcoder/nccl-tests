# Coccinelle Analysis

Semantic patch-based analysis using vendored patterns for common C/C++ bugs.

## Summary

| Metric | Value |
|--------|-------|
| Total findings | 0 |

### Rules Applied

| Rule | Findings | Description |
|------|----------|-------------|
| double-free | 0 | Double-free of allocated memory |
| null-deref | 0 | Null pointer dereference after failed allocation |
| resource-leak | 0 | Missing free/close on allocated resources |
| use-after-free | 0 | Use of memory after deallocation |

## Analysis

No findings — nccl-tests does not exhibit the memory-safety anti-patterns targeted by these rules. The codebase primarily uses CUDA memory management (`cudaMalloc`/`cudaFree`) which these C-focused patterns do not cover.

## Reproduction

```bash
nix build .#analysis-coccinelle && cat result/report.txt
```
