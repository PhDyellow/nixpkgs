{ lib, stdenv, fetchFromGitLab, kernel, linuxHeaders }:

stdenv.mkDerivation (finalAttrs: {
  pname = "ryzen_smu-${kernel.version}";
  version = "0.1.5";

  src = fetchFromGitLab {
    owner = "mann1x";
    repo = "ryzen_smu";
    rev = "adaf53c77dc68b99643ab7af729eb9c592cf5e01";
    hash = "sha256-OQyPqNL8Cd7XQfY8YiOVYqOG7RIu5l+wJoK2FDBg5eg=";
  };

  buildInputs = [
    linuxHeaders
  ];

  makeFlags = [
    "KERNEL_MODULES=${kernel.dev}/lib/modules/${kernel.modDirVersion}"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/modules/${kernel.modDirVersion}"

    for module in ryzen_smu.ko; do
        mv $module $out/lib/modules/${kernel.modDirVersion}
    done

    runHook postInstall
  '';

  meta = {
    broken = stdenv.isAarch64;
    description = "A Linux kernel driver that exposes access to the SMU (System Management Unit) for certain AMD Ryzen Processors";
    homepage = "https://gitlab.com/leogx9r/ryzen_smu";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.phdyellow ];
    platforms = lib.platforms.linux;
  };
})
