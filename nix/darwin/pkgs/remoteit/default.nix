{ lib, stdenv, fetchurl, undmg }:

stdenv.mkDerivation rec {
  pname = "remoteit";
  version = "3.19.7"; # Update this to the latest version

https://downloads.remote.it/desktop/v3.34.4/Remote.It-Installer-arm64.dmg

  src = fetchurl {
    url = "https://downloads.remote.it/desktop/v3.34.4/Remote.It-Installer-arm64.dmg";
    sha256 = ""; # You'll need to add the actual sha256 after downloading the file
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r "remote.it.app" $out/Applications/
  '';

  meta = with lib; {
    description = "Remote.it Desktop Application";
    homepage = "https://remote.it";
    license = licenses.unfree;
    platforms = platforms.darwin;
    maintainers = [];
  };
}