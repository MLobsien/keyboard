{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = inputs: let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {inherit system;};

    qmk = pkgs.fetchFromGitHub {
      owner = "qmk";
      repo = "qmk_firmware";
      rev = "4fbb3956025627250e7a0d2439266006ebf3efc4";
      sha256 = "sha256-ezJh4UdSBQ1LskuzfA40oaKErYBdGVq9v13gKjqDWVw=";
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      nativeBuildInputs = [pkgs.zig];
    };

    # packages.${system}.default = pkgs.stdenv.mkDerivation {
    #   name = "fprint";
    #   src = ./.;
    #
    #   nativeBuildInputs = [pkgs.zig];
    #
    #   buildPhase = ''
    #     export ZIG_LOCAL_CACHE_DIR=$TMPDIR/zig-cache
    #     export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-global-cache
    #
    #     zig build
    #   '';
    #
    #   installPhase = ''
    #     mkdir -p $out/lib
    #     cp zig-out/lib/libfprint.a $out/lib/
    #   '';
    # };
  };
}
