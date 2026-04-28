# Flawfinder Analysis

CWE-oriented security scanning for C/C++/CUDA source files.

## Summary

| Metric | Value |
|--------|-------|
| Total findings | 70 |
| Level 4 (High) | 2 |
| Level 3 (Medium) | 6 |
| Level 2 (Low) | 39 |
| Level 1 (Info) | 23 |
| Lines analyzed | 6,635 |

### By Category

| Category | Count | Description |
|----------|-------|-------------|
| buffer | 54 | Buffer overflow risks (sprintf, char arrays, memcpy, strcpy) |
| format | 2 | Format string vulnerabilities |
| integer | 2 | Integer overflow (atoi without range check) |
| misc | 3 | Miscellaneous (fopen without symlink protection) |

## Top Priority Findings

### 1. Format string risks (Level 4, 2 findings)

```
src/util.cu:25          printf macro — format string exploitable if attacker-influenced (CWE-134)
verifiable/verifiable.cu:1376  std::printf with variable format string
```

**Fix**: Ensure format strings are always compile-time literals.

### 2. Unvalidated environment variables (Level 3, 5 findings)

```
src/common.cu:1261   getenv("NCCL_TESTS_SPLIT_MASK") (CWE-807)
src/common.cu:1263   getenv("NCCL_TESTS_SPLIT") (CWE-807)
src/common.cu:1329   getenv("NCCL_TESTS_DEVICE") (CWE-807)
src/common.cu:1595   getenv("NCCL_TESTS_MIN_BW") (CWE-807)
src/util.cu:554      getenv("NCCL_TESTS_DEVICE") (CWE-807)
```

**Risk**: Environment variables are untrustable input. Content and length are unbounded.
**Fix**: Validate and bound-check environment variable values before use.

### 3. sprintf without bounds checking (Level 2, 7 findings)

All in `src/util.cu` (lines 426, 461-466) — `sprintf()` with no buffer size limit.

**Fix**: Replace with `snprintf()` specifying buffer size.

### 4. strcpy without bounds checking (Level 2, 1 finding)

```
src/util.cu:576   strcpy(line+MAX_LINE-5, "...\n") (CWE-120)
```

**Fix**: Replace with `snprintf()` or `strncpy()` with explicit size.

### 5. Statically-sized char arrays (Level 2, 16 findings)

Fixed-size `char` buffers throughout `src/common.cu`, `src/common.h`, `src/util.cu` — potential overflow if input exceeds expected size.

### 6. getopt_long buffer overflow (Level 3, 1 finding)

```
src/common.cu:1000   getopt_long() — some implementations have internal buffer overflow risks (CWE-120)
```

## Reproduction

```bash
nix build .#analysis-flawfinder && cat result/report.txt
```
