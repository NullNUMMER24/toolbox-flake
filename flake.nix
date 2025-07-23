{
  description = "Remmina with SMB support and RDP troubleshooting tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        
        # Original Remmina package
        remminaVanilla = pkgs.remmina;
        
        # Essential SMB/RDP support packages
        supportPackages = with pkgs; [
          # SMB Support
          gvfs
          samba
          cifs-utils
          
          # RDP/Kerberos troubleshooting
          krb5
          freerdp
          wireshark
          dnsutils
        ];

        # Your existing extra packages
        extraPackages = with pkgs; [
          vim
          htop
          curl
        ];
      in {
        packages = {
          remmina = remminaVanilla;
          extras = pkgs.symlinkJoin {
            name = "extras";
            paths = extraPackages ++ supportPackages;
          };
        };

        defaultPackage = remminaVanilla;

        devShells.default = pkgs.mkShell {
          packages = [ remminaVanilla ] ++ extraPackages ++ supportPackages;
          
          # Environment setup
          env = {
            GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
            KRB5_CONFIG = pkgs.writeText "krb5.conf" ''
              [libdefaults]
                default_realm = KBSVC.LOCAL
                dns_lookup_kdc = true
              
              [domain_realm]
                .kbsvc.local = KBSVC.LOCAL
                kbsvc.local = KBSVC.LOCAL
            '';
          };
          
          shellHook = ''
            echo "Remmina ready with:"
            echo " - SMB support via GVFS"
            echo " - RDP troubleshooting tools"
            echo ""
            echo "For Kerberos issues, first verify DNS:"
            echo "  nslookup kbsvc.local"
            echo "  nslookup _kerberos._tcp.kbsvc.local"
            echo ""
            echo "To test SMB:"
            echo "  smbclient -L //server -U user"
          '';
        };
      }
    );
}
