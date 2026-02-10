{
  pkgs,
  ...
}:

rec {
  reframe = pkgs.callPackage ./reframe/package.nix { };
  default = reframe;
}
