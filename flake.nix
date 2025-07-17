{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    symdig.url = "github:valyntyler/symdig";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            self.packages.${system}.default
            just
            nushell
          ];
        };
        packages = rec {
          default = fdesktop;
          fdesktop = pkgs.stdenv.mkDerivation rec {
            name = "fdesktop";
            src = ./src;
            buildInputs = with pkgs; [
              inputs.symdig.packages.${system}.default
              makeWrapper
              nushell
            ];
            installPhase = ''
              mkdir -p $out/bin
              cp ./main.nu $out/bin/${name}
              chmod +x $out/bin/${name}
              wrapProgram $out/bin/${name} \
                --prefix PATH : ${pkgs.lib.makeBinPath [
                inputs.symdig.packages.${system}.default
                pkgs.nushell
              ]}
            '';
          };
        };
      }
    );
}
