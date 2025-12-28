{
  pkgs,
  ...
}:

{
  reframe = pkgs.callPackage ./reframe/package.nix { };
}
