# Cppcheck Analysis

Deep static analysis with synthetic compile database.

## Summary

| Metric | Value |
|--------|-------|
| Total findings | 0 |
| Active checkers | 181/966 |

## Analysis

Cppcheck found no issues in nccl-tests source files. The tool ran with 181 active checkers.

**Note**: The limited checker count (181/966) is because many checkers require features not present in the synthetic compile database (e.g., full CUDA support, template instantiation context). The active checkers cover core C/C++ analysis.

## Reproduction

```bash
nix build .#analysis-cppcheck && cat result/report.txt
```
