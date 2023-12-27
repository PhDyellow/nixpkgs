{ lib
, stdenv
, fetchFromGitLab
, fetchurl
, kernel
}:

let
  smu_version = "0.1.5";
  smu_src = fetchFromGitLab {
    owner = "mann1x";
    repo = "ryzen_smu";
    rev = "adaf53c77dc68b99643ab7af729eb9c592cf5e01";
    hash = "sha256-OQyPqNL8Cd7XQfY8YiOVYqOG7RIu5l+wJoK2FDBg5eg=";
  };

  monitor-cpu = stdenv.mkDerivation (finalAttrs: {
    pname = "monitor_cpu";
    version = smu_version;

    src = smu_src;

    makeFlags = [
      "-C userspace"
    ];

    installPhase = ''
    runHook preInstall

    install userspace/monitor_cpu -Dm755 -t $out/bin

    runHook postInstall
  '';

in
stdenv.mkDerivation (finalAttrs: {
  pname = "ryzen_smu-${kernel.version}";
  version = smu_version;

  src = smu_src;

  hardeningDisable = [ "pic" ];

  nativeBuildImputs = kernel.moduleBuildDependencies;

  buildInputs = [
    linuxHeaders
  ];

  makeFlags = [
    "TARGET=${kernel.modDirVersion}"
    "KERNEL_BUILD=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    runHook preInstall

    install ryzen_smu.ko -Dm444 -t $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/ryzen_smu
    install ${monitor_cpu}/bin/monitor_cpu -Dm755 -t $out/bin

    runHook postInstall
  '';

  meta = with lib; {
    broken = stdenv.isAarch64;
    description = "A Linux kernel driver that exposes access to the SMU (System Management Unit) for certain AMD Ryzen Processors";
    homepage = "https://gitlab.com/leogx9r/ryzen_smu";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ Cryolitia phdyellow ];
    platforms = platforms.linux;
    mainProgram = "monitor_cpu";

  };
})
