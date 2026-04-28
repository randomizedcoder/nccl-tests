# NCCL-Tests Static Analysis Results

Static analysis of nccl-tests using Nix-based tooling. Each tool runs in an isolated Nix build sandbox against the full source tree.

## Overview

| Tool | Language | Findings | Top Severity | Report |
|------|----------|----------|--------------|--------|
| [clang-tidy](clang-tidy.md) | C/C++ | 3,717 | High | Comprehensive linting with compile DB |
| [cpplint](cpplint.md) | C/C++ | 105 | Level 5 | Google style checker |
| [flawfinder](flawfinder.md) | C/C++ | 70 | Level 4 (high) | Security-focused scanner |
| [semgrep-cpp](semgrep-cpp.md) | C/C++ | 11 | Info | Pattern-based (47 C++ + 11 CUDA rules) |
| [gcc-warnings](gcc-warnings.md) | C/C++ | 4 | Warning | Extended compiler warnings |
| [cppcheck](cppcheck.md) | C/C++ | 0 | - | Deep analysis with compile DB |
| [coccinelle](coccinelle.md) | C/C++ | 0 | - | Semantic patch patterns |
| [gcc-analyzer](gcc-analyzer.md) | C/C++ | 0 | - | GCC interprocedural analysis |
| [clang-analyzer](clang-analyzer.md) | C/C++ | 0 | - | Clang path-sensitive analysis |
| [iwyu](iwyu.md) | C/C++ | 0 | - | Include dependency analysis |
| **Total** | | **3,907** | | |

## Top Priority Issues

These are the findings most likely to represent real bugs or security concerns, distilled across all tools.

### High: Security Concerns

| Issue | Tools | Count | Location |
|-------|-------|-------|----------|
| `sprintf` without bounds checking | cpplint, flawfinder | 7 | `src/util.cu` |
| `strcpy` without bounds checking | cpplint, flawfinder | 1 | `src/util.cu:576` |
| `localtime` thread-unsafe | cpplint | 1 | `src/util.cu:280` |
| Unvalidated `getenv()` input | flawfinder | 5 | `src/common.cu`, `src/util.cu` |
| `atoi` without range check | flawfinder | 2 | `src/common.cu:1330`, `src/util.cu:555` |

### Medium: Code Quality

| Issue | Tools | Count | Location |
|-------|-------|-------|----------|
| Variable-length arrays (VLAs) | cpplint | 12 | `src/common.cu` |
| Dynamic static initializers | clang-tidy | 217 | Throughout |
| Narrowing conversions | clang-tidy | 45 | Throughout |
| Unchecked return values | clang-tidy | 47 | Throughout |
| Sign/narrowing conversion in timer | gcc-warnings | 4 | `src/timer.cc` |
| Uninitialized member variables | clang-tidy | 32 | Throughout |

### Low: Style/Modernization

| Issue | Tools | Count | Location |
|-------|-------|-------|----------|
| Identifier naming conventions | clang-tidy | 677 | Throughout |
| Non-const global variables | clang-tidy | 336 | Throughout |
| C-style arrays | clang-tidy | 261 | Throughout |
| Missing anonymous namespace comments | cpplint | 25 | `verifiable/verifiable.cu` |
| Include ordering | cpplint | 13 | Throughout |

## Recommended Fix Priority

1. **Buffer safety** — Replace `sprintf` with `snprintf` in `src/util.cu` (7 instances). These are the highest-confidence actionable findings across all tools.

2. **Thread safety** — Replace `localtime` with `localtime_r` in `src/util.cu:280`. Important if tests run in multi-threaded contexts.

3. **Input validation** — Validate `getenv()` return values before passing to `atoi()`. Check for NULL and validate numeric ranges.

4. **VLA elimination** — Replace variable-length arrays in `src/common.cu` with `std::vector` or fixed-size arrays. VLAs are optional in C++ and can cause stack overflow.

5. **Type safety** — Add explicit casts for narrowing conversions in `src/timer.cc` and throughout.

## Tool Configuration

All tools run via Nix flake outputs:

```bash
# Individual tools
nix build .#analysis-flawfinder && cat result/report.txt
nix build .#analysis-cpplint    && cat result/report.txt
nix build .#analysis-clang-tidy && cat result/report.txt

# Composite tiers
nix build .#analysis-quick      # ~2-5 min:  flawfinder, cpplint
nix build .#analysis-standard   # ~10-20 min: quick + cppcheck, clang-tidy, semgrep-cpp, coccinelle
nix build .#analysis-deep       # All 10 tools

# Dev shell with all tools on PATH
nix develop
```

## Notes

- **clang-tidy's 3,717 findings** are overwhelmingly style/modernization. The ~400 bugprone/cert findings are the actionable subset.
- **5 tools returned 0 findings** — expected because most nccl-tests code is in `.cu` files requiring CUDA headers not available in the Nix sandbox. The tools that did find issues (cpplint, flawfinder, clang-tidy) work with partial parsing or text-level analysis.
- The compile database is synthetically generated (no cmake/nvcc). Tools that require full type resolution may miss findings in CUDA code.
- All analysis runs in the Nix sandbox with no network access and reproducible results.
