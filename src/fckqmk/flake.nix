{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    qmk = {
      url = "git+https://github.com/qmk/qmk_firmware?submodules=1";
      flake = false;
    };

    fprint = {
      url = "path:./fprint/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    qmk,
    fprint,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};

    inherit (fprint.packages.${system}) default;
  in {
    packages.${system}.default = pkgs.stdenv.mkDerivation {
      name = "fckqmk";

      nativeBuildInputs = with pkgs; [
        python3
        gcc-arm-embedded-15
        pkgs.qmk
      ];

      buildInputs = [default];

      src = pkgs.runCommand "qmk_firmware" {} ''
        mkdir $out
        cp --no-preserve=mode -r ${qmk}/* $out
        cp --no-preserve=mode -r ${../.}/fckqmk $out/keyboards/

        echo "include ${default}/include/fprint.mk" >> $out/keyboards/fckqmk/rules.mk
      '';

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
