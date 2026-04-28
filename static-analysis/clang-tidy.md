# clang-tidy Analysis

Comprehensive C/C++ linting with synthetic compile database.

## Summary

| Metric | Value |
|--------|-------|
| Total findings | 3,717 |

### By Check (Top 30)

| Check | Count | Description |
|-------|-------|-------------|
| readability-identifier-naming | 677 | Naming convention violations |
| cppcoreguidelines-avoid-non-const-global-variables | 336 | Mutable global variables |
| modernize-avoid-c-arrays | 261 | C-style array declarations |
| cppcoreguidelines-pro-bounds-array-to-pointer-decay | 221 | Array-to-pointer decay |
| bugprone-dynamic-static-initializers | 217 | Dynamic initialization of static variables |
| cppcoreguidelines-init-variables | 162 | Uninitialized variables |
| cppcoreguidelines-avoid-do-while | 154 | `do-while` loop usage |
| cppcoreguidelines-pro-type-vararg | 144 | Variadic function usage (printf etc.) |
| misc-use-internal-linkage | 133 | Functions/variables should have internal linkage |
| misc-unused-parameters | 130 | Unused function parameters |
| misc-const-correctness | 126 | Variables that could be const |
| cppcoreguidelines-macro-usage | 112 | Macro instead of constexpr/inline |
| readability-avoid-const-params-in-decls | 96 | Const params in declarations |
| misc-include-cleaner | 78 | Missing or unnecessary includes |
| bugprone-reserved-identifier | 67 | Reserved identifier usage |
| readability-braces-around-statements | 66 | Missing braces |
| modernize-use-nullptr | 66 | `NULL`/`0` instead of `nullptr` |
| readability-implicit-bool-conversion | 61 | Implicit bool conversions |
| readability-math-missing-parentheses | 50 | Missing parentheses in math |
| cert-err33-c | 47 | Unchecked return values |
| clang-diagnostic-error | 45 | Parse errors (missing CUDA headers) |
| bugprone-narrowing-conversions | 45 | Narrowing conversions |
| cppcoreguidelines-pro-type-cstyle-cast | 44 | C-style casts |
| cppcoreguidelines-pro-type-union-access | 43 | Union member access |
| misc-use-anonymous-namespace | 39 | Should use anonymous namespace |
| cppcoreguidelines-pro-bounds-constant-array-index | 36 | Non-constant array index |
| cppcoreguidelines-pro-type-member-init | 32 | Uninitialized member variables |
| readability-isolate-declaration | 30 | Multiple declarations per line |
| cppcoreguidelines-no-malloc | 26 | Raw malloc/free in C++ |
| modernize-use-using | 25 | `typedef` instead of `using` |

## Top Priority Findings

### 1. Bugprone: Dynamic static initializers (217 findings)

Static variables with dynamic initialization can cause order-of-initialization issues across translation units.

**Locations**: Throughout `src/common.cu`, `src/util.cu`, `verifiable/verifiable.cu`.
**Fix**: Use function-local statics or constexpr where possible.

### 2. Bugprone: Narrowing conversions (45 findings)

Implicit narrowing conversions that may lose data:
- `long` to `int` in loop counters and size computations
- `size_t` to `int` in various locations

**Fix**: Add explicit casts or use matching types.

### 3. Bugprone: Reserved identifiers (67 findings)

Identifiers starting with underscore or using reserved patterns (double underscore).

**Fix**: Rename to avoid reserved identifier patterns.

### 4. cert-err33-c: Unchecked return values (47 findings)

Return values from system/library calls not checked (e.g., `printf`, `fprintf`, `fclose`).

**Fix**: Check return values or explicitly cast to `void` for intentionally-ignored results.

### 5. Uninitialized member variables (32 findings)

`cppcoreguidelines-pro-type-member-init` — struct/class members without default initialization.

**Fix**: Add default member initializers.

## Analysis Notes

- The 45 `clang-diagnostic-error` findings are expected — these are `.cu` files that reference CUDA headers not available in the Nix sandbox. The actual CUDA code is excluded from analysis.
- The 677 `readability-identifier-naming` findings are style-only (naming convention mismatches against CamelCase/camelBack rules).
- The bulk of findings (2,000+) are style/modernization suggestions, not bugs.
- The ~400 bugprone/cert/concurrency findings are the most actionable subset.

## Reproduction

```bash
nix build .#analysis-clang-tidy && cat result/report.txt
```
