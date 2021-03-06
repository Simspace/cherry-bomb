{
  description = "An over-engineered Hello World in bash";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";

  outputs = { self, nixpkgs }:
    let

      # to work with older version of flakes
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

    in

    {

      # A Nixpkgs overlay.
      overlay = final: prev: {

        cherry-bomb = with final; stdenv.mkDerivation rec {

          buildInputs = [ final.makeWrapper ];
          phases = [ "installPhase" ];
          installPhase =
            ''
              mkdir -p $out/bin
              cp ${./cherry-bomb.sh} $out/bin/cherry-bomb
              wrapProgram $out/bin/cherry-bomb \
                --set PATH "${final.lib.makeBinPath [ final.hub final.git final.mktemp ]}"
            '';
          name = "cherry-bomb-${version}";
        };

      };

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) cherry-bomb;
        });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage = forAllSystems (system: self.packages.${system}.cherry-bomb);

      defaultApp = forAllSystems (system: {
        type = "app";
        program = "${self.packages.${system}.cherry-bomb}/bin/cherry-bomb";
      });
    };
}
