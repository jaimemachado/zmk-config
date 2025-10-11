let
  pkgs = import <nixpkgs> {};
  gnuArm = if pkgs ? gcc-arm-embedded then pkgs.gcc-arm-embedded else pkgs.arm-none-eabi-gcc;
  pythonEnv = pkgs.python3.withPackages (ps: [
    ps.west
    ps.pip
    ps.pyelftools
    ps.pyyaml
    ps.packaging
  ]);
in pkgs.mkShell {
  ZEPHYR_TOOLCHAIN_VARIANT = "gnuarmemb";
  GNUARMEMB_TOOLCHAIN_PATH = toString gnuArm; # Path for Zephyr to locate toolchain

  buildInputs = with pkgs; [
    pythonEnv
    cmake
    ninja
    gperf
    dtc
    git
    gcc
    diffutils
    file
    unzip
    which
    gnuArm
    dfu-util
    openocd
    go
  ];

  shellHook = ''
    echo "[ZMK] Toolchain variant: $ZEPHYR_TOOLCHAIN_VARIANT -> $GNUARMEMB_TOOLCHAIN_PATH"
    if ! command -v west >/dev/null; then
      echo "[WARN] west not found in PATH";
    fi
  # Ensure Go bin (for zmk-viewer) is on PATH if it exists
  export PATH="$HOME/go/bin:$PATH"
    if [ ! -d .west ]; then
      echo "[ZMK] Run: west init -l config && west update";
    fi
    echo "[ZMK] Example: west build -b nice_nano_v2 -- -DSHIELD=sofle_left"
  '';
}
