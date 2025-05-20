{
  description = "A Nix flake providing a vanilla Remmina build and example of adding additional packages.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Use the upstream Remmina without any plugins
        remminaVanilla = pkgs.remmina;

        # Example list of extra packages you might install
        extraPackages = with pkgs; [
          vim
          htop
          curl
        ];
      in {
        packages = {
          # Expose Remmina and extras as separate attributes
          remmina = remminaVanilla;
          extras = pkgs.stdenv.mkDerivation {
            name = "extras";
            buildInputs = extraPackages;
            # no build step; this derivation just groups tools
            unpackPhase = ''true'';
            installPhase = ''mkdir -p $out && true'';
          };
        };

        # Default package: Remmina
        defaultPackage = remminaVanilla;

        # Development shell including Remmina and any extras
        devShells.default = pkgs.mkShell {
          buildInputs = [ remminaVanilla ] ++ extraPackages;
          shellHook = ''
            echo "Remmina shell ready – version: $(remmina --version)"
            echo "Extras installed: vim, htop, curl"
          '';
        };
      }
    );
}
