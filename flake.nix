{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        formatter = pkgs.nixfmt-tree;
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            godot
            python3Packages.pip
            gdtoolkit_4
          ];
          shellHook = ''
            export SHELL=/run/current-system/sw/bin/bash
          '';
        };
      }
    );
}
