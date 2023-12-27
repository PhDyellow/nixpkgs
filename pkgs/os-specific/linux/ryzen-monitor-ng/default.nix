{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "ryzen_monitor_ng";
  version = "2.0.5";

  # Upstream has not updated ryzen_smu header version
  # This fork corrects ryzen_smu header version and
  # adds support for Matisse AMD CPUs.
  src = fetchFromGitHub {
    owner = "kvic-z";
    repo = "ryzen_monitor_ng";
    rev = "2bb122d7a75eebb8a18ceb5533824b48884cd3d5";
    sha256 = "sha256-pS480faA2ILJrAEBdWu4hksj3WhdAB8A9710ern1mJg=";
  };

  buildPhase = ''
    runHook preBuild
    make clean
    rm src/ryzen_monitor
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    mv ./src/ryzen_monitor $out/bin

    runHook postInstall
  '';

  meta = with lib; {
    description = "Access Ryzen SMU information exposed by the ryzen_smu driver";
    homepage = "https://github.com/mann1x/ryzen_monitor_ng";
    license = licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = [ lib.maintainers.phdyellow ];
  };
}
