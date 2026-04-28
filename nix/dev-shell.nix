# Development shell with all static analysis tools on PATH.
#
# Enter with: nix develop
#
{ pkgs }:

pkgs.mkShell {
  name = "nccl-tests-analysis";

  packages = with pkgs; [
    # C/C++ analysis
    clang-tools       # clang-tidy, clang-format, clang --analyze
    cppcheck
    flawfinder
    cpplint
    include-what-you-use
    coccinelle

    # Semgrep
    semgrep

    # Build tools
    gcc
    gnumake

    # Utilities
    python3
    jq                # JSON processing
    parallel          # Parallel execution
  ];

  shellHook = ''
    echo ""
    echo "=== nccl-tests Static Analysis Shell ==="
    echo ""
    echo "Available analysis commands:"
    echo "  nix build .#analysis-quick       Quick checks (~2-5 min)"
    echo "  nix build .#analysis-standard    Standard checks (~10-20 min)"
    echo "  nix build .#analysis-deep        Full analysis (~30-60 min)"
    echo ""
    echo "Individual tools:"
    echo "  nix build .#analysis-flawfinder"
    echo "  nix build .#analysis-cpplint"
    echo "  nix build .#analysis-cppcheck"
    echo "  nix build .#analysis-clang-tidy"
    echo "  nix build .#analysis-semgrep-cpp"
    echo "  ... (see flake.nix for all targets)"
    echo ""

    # Disable semgrep telemetry
    export SEMGREP_ENABLE_VERSION_CHECK=0
    export SEMGREP_SEND_METRICS=off
  '';
}
