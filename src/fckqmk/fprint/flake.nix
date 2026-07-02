{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};

    nativeBuildInputs = [pkgs.zig];
  in {
    devShells.${system}.default = pkgs.mkShell {
      inherit nativeBuildInputs;
    };

    packages.${system}.default = pkgs.stdenvNoCC.mkDerivation {
      name = "fprint";
      src = ./.;

      inherit nativeBuildInputs;

      buildPhase = ''
        export ZIG_LOCAL_CACHE_DIR=$TMPDIR/zig-cache
        export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-global-cache

        zig build-obj src/root.zig -target thumb-freestanding-eabi -mcpu=cortex_m0plus
      '';

      installPhase = ''
        mkdir -p $out/bin $out/include
        cp root.o $out/bin/fprint.o

        cat > $out/include/fprint.mk << EOF
        UART_DRIVER_REQUIRED = yes
        SRC += $out/bin/fprint.o
        EOF
      '';
    };
  };
}
