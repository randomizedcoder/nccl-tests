# cpplint Analysis

Google C++ style checking for source and header files.

## Summary

| Metric | Value |
|--------|-------|
| Total findings | 105 |

### By Category

| Category | Count | Description |
|----------|-------|-------------|
| readability/namespace | 25 | Anonymous namespace not terminated with comment |
| runtime/int | 17 | Use of non-portable integer types (`long`) |
| build/include_order | 13 | Include ordering issues |
| runtime/arrays | 12 | Variable-length array (VLA) usage |
| readability/braces | 12 | Brace style issues |
| build/include_what_you_use | 10 | Missing direct includes |
| runtime/printf | 8 | Unsafe printf-family usage |
| readability/casting | 7 | C-style casts instead of C++ casts |
| runtime/threadsafe_fn | 1 | Thread-unsafe function usage |

## Top Priority Findings

### 1. Unsafe printf-family usage (8 findings)

These are the most security-relevant findings:

```
src/util.cu:426   Never use sprintf. Use snprintf instead. [5]
src/util.cu:461   Never use sprintf. Use snprintf instead. [5]
src/util.cu:462   Never use sprintf. Use snprintf instead. [5]
src/util.cu:463   Never use sprintf. Use snprintf instead. [5]
src/util.cu:464   Never use sprintf. Use snprintf instead. [5]
src/util.cu:465   Never use sprintf. Use snprintf instead. [5]
src/util.cu:466   Never use sprintf. Use snprintf instead. [5]
src/util.cu:576   Almost always, snprintf is better than strcpy [4]
```

**Fix**: Replace `sprintf()` with `snprintf()`, and `strcpy()` with bounded copies.

### 2. Thread-unsafe function usage (1 finding)

```
src/util.cu:280   Consider using localtime_r(...) instead of localtime(...) [2]
```

**Fix**: Replace with `localtime_r()` for thread safety.

### 3. Variable-length arrays (12 findings)

VLAs in `src/common.cu` at lines 570, 571, 1252, 1320, 1321, 1374, 1376, 1377, 1409, 1481, 1482, 1483.

**Fix**: Use `std::vector` or fixed-size arrays with compile-time constants.

### 4. Missing includes (10 findings)

Files using symbols without directly including the providing header:

```
src/all_reduce.cu:80    Add #include <cstdio> for fprintf
src/alltoall.cu:167     Add #include <algorithm> for min
src/alltoall.cu:320     Add #include <cstdio> for printf
src/common.cu:1552      Add #include <algorithm> for max
src/common.h:212        Add #include <string> for string
src/gather.cu:69        Add #include <cstdio> for printf
src/hypercube.cu:111    Add #include <cstdio> for printf
src/scatter.cu:65       Add #include <cstdio> for printf
src/util.cu:570         Add #include <cstdio> for snprintf
src/util.cu:573         Add #include <algorithm> for min
```

## Reproduction

```bash
nix build .#analysis-cpplint && cat result/report.txt
```
