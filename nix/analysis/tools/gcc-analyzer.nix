# gcc-analyzer — GCC -fanalyzer interprocedural static analysis.
#
# Performs deep path-sensitive analysis at compile time.
# Detects null dereferences, use-after-free, double-free,
# buffer overflows, and infinite loops across function boundaries.
# Uses per-file -fsyntax-only. Skips .cu files (need nvcc).
#
{ pkgs, lib, src, analysisLib }:

let
  excludes = analysisLib.mkExcludeArgs analysisLib.defaultExcludes;

  runner = pkgs.writeShellApplication {
    name = "run-gcc-analyzer";
    runtimeInputs = with pkgs; [ gcc coreutils findutils gnugrep ];
    text = ''
      source_dir="$1"
      output_dir="$2"

      echo "=== GCC -fanalyzer Analysis ==="

      find "$source_dir" \
        -type f \( -name '*.c' -o -name '*.cc' -o -name '*.cpp' \) \
        ${excludes} \
        > "$output_dir/file-list.txt" 2>/dev/null || true

      file_count=$(wc -l < "$output_dir/file-list.txt" || echo "0")
      echo "Analyzing $file_count files with -fanalyzer..."

      touch "$output_dir/report.txt"

      while IFS= read -r file; do
        case "$file" in
          *.c)  lang_flag="-x c -std=c11" ;;
          *)    lang_flag="-x c++ -std=c++17" ;;
        esac

        # shellcheck disable=SC2086
        g++ -fsyntax-only -fanalyzer -fdiagnostics-plain-output \
          $lang_flag \
          -I"$source_dir/src" \
          -I"$source_dir/verifiable" \
          "$file" 2>&1 | \
          grep -E '\[-Wanalyzer-' >> "$output_dir/report.txt" || true
      done < "$output_dir/file-list.txt"

      findings=$(grep -c '\[-Wanalyzer-' "$output_dir/report.txt" 2>/dev/null || echo "0")
      echo "$findings" > "$output_dir/count.txt"

      echo "gcc-analyzer: $findings findings"
    '';
  };
in
analysisLib.mkBuildReport "gcc-analyzer" runner
