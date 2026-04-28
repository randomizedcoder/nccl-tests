# Semgrep C/C++/CUDA Analysis

Pattern-based static analysis using vendored rules for C/C++ and CUDA-specific patterns.

## Summary

| Metric | Value |
|--------|-------|
| Total findings | 11 |
| C/C++ generic rules | 47 rules |
| CUDA-specific rules | 11 rules |

### By Rule

| Rule | Count | Severity | Description |
|------|-------|----------|-------------|
| reinterpret-cast | 8 | INFO | `reinterpret_cast` usage in `multimem_ops.h` |
| fopen-raw-file-pointer | 1 | INFO | Raw `FILE*` without RAII |
| raw-free-in-cpp | 1 | INFO | `free()` in C++ code |
| c-style-pointer-cast | 1 | INFO | C-style cast instead of C++ cast |

## Findings Detail

### 1. reinterpret_cast usage (8 findings)

All in `src/multimem_ops.h` (lines 28, 38, 48, 58, 75, 83, 91, 99):

```cpp
const uintptr_t multimem_addr = reinterpret_cast<uintptr_t>(addr);
```

**Risk**: Low — these are address-to-integer conversions for multi-memory operations, a standard CUDA pattern.

### 2. Raw FILE pointer (1 finding)

```
src/common.h:232   FILE *file = fopen(HOSTID_FILE, "r");
```

**Fix**: Consider `std::fstream` or RAII wrapper for automatic cleanup.

### 3. Raw free() in C++ (1 finding)

```
src/common.h:237   free(p);
```

**Fix**: Consider `std::unique_ptr` or `std::string` to manage memory automatically.

### 4. C-style pointer cast (1 finding)

```
src/common.h:340   ncclDevComm* devComm = (ncclDevComm*)comm;
```

**Fix**: Use `static_cast<ncclDevComm*>(comm)` for type safety.

## Reproduction

```bash
nix build .#analysis-semgrep-cpp && cat result/report.txt
```
