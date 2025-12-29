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
      packages = forAllSystems (pkgs: import ./packages { inherit pkgs; });
      overlays.reframe = self: super: import ./packages { pkgs = self; };
      overlays.default = self.overlays.reframe;
      nixosModules.reframe = ./modules/services/monitoring/reframe.nix;
      nixosModules.default = self.nixosModules.reframe;
    };
}
