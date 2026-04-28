# GCC -fanalyzer Analysis

Interprocedural path-sensitive analysis using GCC's `-fanalyzer` pass. Detects null dereferences, use-after-free, double-free, buffer overflows, and infinite loops across function boundaries.

## Summary

| Metric | Value |
|--------|-------|
| Total findings | 0 |
| Files analyzed | C/C++ files only (`.c`, `.cc`, `.cpp`; `.cu` excluded) |

## Analysis

No findings. The non-CUDA source files (`src/timer.cc`) are too small and simple to trigger interprocedural issues. The bulk of nccl-tests code is in `.cu` files which require nvcc and are excluded from this analysis.

## Reproduction

```bash
nix build .#analysis-gcc-analyzer && cat result/report.txt
```
