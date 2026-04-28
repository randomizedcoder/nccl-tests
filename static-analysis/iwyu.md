# Include-What-You-Use (IWYU) Analysis

Header dependency analysis to identify missing and unnecessary `#include` directives.

## Summary

| Metric | Value |
|--------|-------|
| Total findings | 0 |

## Analysis

IWYU could not analyze the nccl-tests source files due to missing CUDA headers in the Nix sandbox:

```
error: cannot find CUDA installation; provide its path via '--cuda-path'
fatal error: 'cstdint' file not found (in timer.h)
```

All source files either:
- Are `.cu` files requiring CUDA headers (not available)
- Include headers that transitively depend on CUDA types

**Note**: This tool would be effective in a build environment with CUDA toolkit installed. The Nix sandbox deliberately excludes CUDA for reproducibility.

## Reproduction

```bash
nix build .#analysis-iwyu && cat result/report.txt
```
