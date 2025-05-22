{
  description = "A Nix flake providing Remmina with SMB support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Keep original Remmina configuration
        remminaVanilla = pkgs.remmina;

        # Minimal SMB support packages
        smbSupportPackages = with pkgs; [
          gnome.gvfs # Includes SMB support
          samba      # SMB client/server
          cifs-utils # Mounting tools
        ];

        # Your existing extra packages
        baseExtraPackages = with pkgs; [
          vim
          htop
          curl
          figlet
        ];

        # Combined packages
        extraPackages = baseExtraPackages ++ smbSupportPackages;
      in {
        packages = {
          remmina = remminaVanilla;
          extras = pkgs.stdenv.mkDerivation {
            name = "extras";
            buildInputs = extraPackages;
            unpackPhase = ''true'';
            installPhase = ''mkdir -p $out && true'';
          };
        };

        defaultPackage = remminaVanilla;

        devShells.default = pkgs.mkShell {
          buildInputs = [ remminaVanilla ] ++ extraPackages;
          
          # Required for GVFS/SMB
          env = {
            GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
          };
          
          shellHook = ''
            figlet TOOLBOX
          '';
        };
      }
    );
}
