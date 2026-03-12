{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs =
    { self, nixpkgs }@input:

    let
      allSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f (nixpkgs.legacyPackages.${system}));
    in
    {
      packages = forAllSystems (
        pkgs:
        let
          extendedPkgs = pkgs.extend self.overlays.default;
        in
        {
          inherit (extendedPkgs) reframe;
          default = extendedPkgs.reframe;
        }
      );
      overlays.reframe = self: super: import ./packages self super;
      overlays.default = self.overlays.reframe;
      nixosModules.reframe = ./modules/services/monitoring/reframe.nix;
      nixosModules.default = self.nixosModules.reframe;
      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
}
