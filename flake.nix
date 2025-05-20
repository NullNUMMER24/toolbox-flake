{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true; # If you need proprietary packages
      };
    in {
      packages = {
        # List your packages here
        firefox = pkgs.firefox;
        vscode = pkgs.vscode;
        default = pkgs.hello; # Default package
      };
    });
}