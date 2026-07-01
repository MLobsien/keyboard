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

        zig build
      '';

      installPhase = ''
        mkdir -p $out/lib
        cp zig-out/lib/libfprint.a $out/lib
        cp -r include/ $out

        cat > $out/include/fprint.mk << EOF
        UART_DRIVER_REQUIRED = yes
        CFLAGS += -I$out/include
        LDFLAGS += -L$out/lib -lfprint
        SRC += $out/include/qmk.c
        EOF
      '';
    };
  };
}
