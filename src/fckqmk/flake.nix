{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    qmk = {
      url = "git+https://github.com/qmk/qmk_firmware?submodules=1";
      flake = false;
    };

    fprint = {
      url = "path:./fprint/";
      inputs = {
        qmk.follows = "qmk";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = {
    nixpkgs,
    fprint,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    packages.${system}.default = pkgs.stdenv.mkDerivation {
      name = "fckqmk";

      nativeBuildInputs = with pkgs; [
        qmk
        python3
        gcc-arm-embedded-15
        fprint.packages.${system}.default
      ];

      src = fprint.packages.${system}.qmk_firmware;

      preConfigure = ''
        substituteInPlace ./util/uf2conv.py --replace '/usr/bin/env python3' '${pkgs.python3}/bin/python3'
        substituteInPlace ./builddefs/common_rules.mk --replace '>/dev/null 2>&1' ""
        chmod +x ./util/uf2conv.py
      '';

      buildPhase = ''
        qmk compile --keyboard fckqmk --keymap default
      '';

      installPhase = ''
        mkdir -p $out/bin

        cp -r .build/fckqmk_default.* $out/bin
      '';
    };
  };
}
