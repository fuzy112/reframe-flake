{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  gtk4,
  libdrm,
  libepoxy,
  libvncserver,
  libxkbcommon,
  systemd,
  meson,
  pkg-config,
  ninja,
  gcc,
  withNeatvnc ? true,
  neatvnc,
  aml,
  cmake,
  pixman,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "reframe";
  version = "1.14.1";
  name = "${finalAttrs.pname}-${finalAttrs.version}";
  src = fetchFromGitHub {
    owner = "AlynxZhou";
    repo = "reframe";
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-8u2LuOa+0QyUvVw5TPUFazDdo95LVCSoMltNthIls1g=";
  };

  nativeBuildInputs = [
    meson
    ninja
    gcc
    pkg-config
  ];

  buildInputs = [
    glib
    gtk4
    libdrm
    libepoxy
    libvncserver
    libxkbcommon
    systemd
  ]
  ++ lib.optionals withNeatvnc [
    neatvnc
    aml
    cmake
    pixman
  ];

  mesonFlags = lib.optionals withNeatvnc [
    "-Dneatvnc=true"
  ];

  postInstall = ''
    mkdir -p $out/share/${finalAttrs.name}
    mkdir -p $out/share/${finalAttrs.name}/docs
    cd $src
    cp README.md LICENSE $out/share/${finalAttrs.name}
    cp -r docs/*.html docs/css docs/images $out/share/${finalAttrs.name}/docs
  '';

  patches = [
    ./fix-paths.patch
  ];
})
