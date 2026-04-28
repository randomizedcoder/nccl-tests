# Generate compile_commands.json for nccl-tests.
#
# Strategy: generate synthetic compile_commands.json since nccl-tests
# uses a Makefile build system (no cmake) and requires CUDA + NCCL headers.
#
{ pkgs, lib, src }:

let
  syntheticDbScript = pkgs.writeText "synthetic-compile-db.py" ''
    """Generate synthetic compile_commands.json from source file discovery."""
    import json
    import os
    import sys

    source_dir = sys.argv[1]
    output_file = sys.argv[2]

    extensions = {
        '.c': 'c',
        '.cc': 'c++',
        '.cpp': 'c++',
        '.cxx': 'c++',
        '.cu': 'cuda',
    }

    # Directories to skip
    skip_dirs = {'build', '.git'}

    # nccl-tests include paths
    include_flags = ' '.join([
        f'-I{source_dir}/src',
        f'-I{source_dir}/verifiable',
    ])

    # nccl-tests defines
    defines = ' '.join([
        '-DNCCL_MAJOR=2',
        '-DNCCL_MINOR=30',
    ])

    entries = []
    for root, dirs, files in os.walk(source_dir):
        # Prune excluded directories
        dirs[:] = [d for d in dirs if d not in skip_dirs]

        for f in files:
            _, ext = os.path.splitext(f)
            if ext not in extensions:
                continue

            filepath = os.path.join(root, f)
            lang = extensions[ext]

            if lang == 'c':
                std_flag = '-std=c11'
                lang_flag = '-x c'
            elif lang == 'cuda':
                std_flag = '-std=c++17'
                lang_flag = '-x cuda'
            else:
                std_flag = '-std=c++17'
                lang_flag = '-x c++'

            entries.append({
                'directory': source_dir,
                'file': filepath,
                'command': f'clang++ {lang_flag} {std_flag} {include_flags} {defines} -c {filepath}',
            })

    with open(output_file, 'w') as fh:
        json.dump(entries, fh, indent=2)

    print(f"Generated synthetic compile_commands.json with {len(entries)} entries")
  '';

  hasCuda = pkgs ? cudaPackages && pkgs.cudaPackages ? cuda_nvcc;
  cudaDeps = lib.optionals hasCuda (with pkgs.cudaPackages; [
    cuda_nvcc
    cuda_cudart
    cuda_cccl
  ]);

  compileDb = pkgs.runCommand "compile-db-nccl-tests" {
    nativeBuildInputs = with pkgs; [ python3 gnumake gcc ] ++ cudaDeps;
  } ''
    mkdir -p $out

    echo "=== Generating compile_commands.json for nccl-tests ==="

    ${pkgs.python3}/bin/python3 ${syntheticDbScript} \
      ${src} $out/compile_commands.json
    echo "synthetic" > $out/method.txt
  '';

in
compileDb
