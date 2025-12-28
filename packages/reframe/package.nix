{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  libdrm,
  libepoxy,
  libvncserver,
  libxkbcommon,
  systemd,
  meson,
  pkg-config,
  ninja,
  gcc
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "reframe";
  version = "1.6.0";
  src = fetchFromGitHub {
    owner = "AlynxZhou";
    repo = "reframe";
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-5xuc2mz9qihsrFiENb08JsaMfyJcPdcTl2Q9H9BL6o8=";
  };

  nativeBuildInputs = [
    meson
    ninja
    gcc
    pkg-config
  ];

  buildInputs = [
    glib
    libdrm
    libepoxy
    libvncserver
    libxkbcommon
    systemd
  ];

  patches = [
    ./fix-paths.patch
  ];
})
