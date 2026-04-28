# GCC Extended Warnings Analysis

Compiler warnings from GCC with aggressive `-W` flags on C/C++ source files (excludes `.cu` files which require nvcc).

## Summary

| Metric | Value |
|--------|-------|
| Total findings | 4 |
| Files analyzed | C/C++ files only (`.c`, `.cc`, `.cpp`) |

### Findings

All 4 findings are in `src/timer.cc`:

| Line | Warning | Description |
|------|---------|-------------|
| 10 | `-Wsign-conversion` | Conversion to `uint64_t` from signed `long int` may change sign |
| 20 | `-Wconversion` | Conversion from `uint64_t` to `double` may change value |
| 25 | `-Wconversion` | Conversion from `uint64_t` to `double` may change value |

**Note**: The `-Werror=implicit-function-declaration` flag generates an informational message (not a finding) for C++ files.

## Analysis

These are narrowing/sign-conversion warnings in the timer utility:

- **Line 10**: `std::chrono::duration::rep` (signed `long`) assigned to `uint64_t` (unsigned). Safe in practice since durations are non-negative, but explicit cast would silence the warning.
- **Lines 20, 25**: `uint64_t` to `double` conversion. Loss of precision for values > 2^53, unlikely for nanosecond timer values in practice.

**Fix**: Add explicit casts: `static_cast<uint64_t>(...)` and `static_cast<double>(...)`.

## Reproduction

```bash
nix build .#analysis-gcc-warnings && cat result/report.txt
```
