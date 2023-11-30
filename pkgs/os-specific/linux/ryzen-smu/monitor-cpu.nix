{ lib, stdenv, fetchFromGitLab }:

stdenv.mkDerivation (finalAttrs: {
  pname = "monitor_cpu";
  version = "0.1.5";

  src = fetchFromGitLab {
    owner = "mann1x";
    repo = "ryzen_smu";
    rev = "adaf53c77dc68b99643ab7af729eb9c592cf5e01";
    hash = "sha256-OQyPqNL8Cd7XQfY8YiOVYqOG7RIu5l+wJoK2FDBg5eg=";
  };

  buildPhase = ''
    cd userspace
    make
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    mv ./monitor_cpu $out/bin

    runHook postInstall
  '';

  meta = with lib; {
    description = "Access Ryzen SMU information exposed by the ryzen_smu driver";
    homepage = "https://github.com/mann1x/ryzen_monitor_ng";
    license = licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
    maintainers = [ lib.maintainers.phdyellow ];
  };
})
