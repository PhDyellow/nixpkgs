{ lib
, stdenv
, fetchFromGitLab
, fetchurl
, kernel
}:

let
  smu_version = "0.1.5";

  # This fork supports ryzen_monitor_ng, which provides a better interface
  # than the provided monitor_cpu.
  # Changes have not been merged upstream.
  smu_src = fetchFromGitLab {
    owner = "mann1x";
    repo = "ryzen_smu";
    rev = "adaf53c77dc68b99643ab7af729eb9c592cf5e01";
    hash = "sha256-OQyPqNL8Cd7XQfY8YiOVYqOG7RIu5l+wJoK2FDBg5eg=";
  };

  smu_patches = [
    # Add Rembrandt support
    # https://gitlab.com/leogx9r/ryzen_smu/-/issues/20
    (fetchurl {
      url = "https://gitlab.com/moson-mo/ryzen_smu/-/commit/cdfe728b3299400b7cd17d31bdfe5bedab6b1cc9.patch";
      hash = "sha256-XD+Xz3/1MwoXUocqQK13Uiy5oOa1VRN1qRLmFmq4CEQ=";
    })

    # Add Phoenix support
    # https://gitlab.com/leogx9r/ryzen_smu/-/issues/24
    (fetchurl {
      url = "https://gitlab.com/moson-mo/ryzen_smu/-/commit/58feed93d8e55f27b0e6b7f66e0be165cf52fc23.patch";
      hash = "sha256-y9f/COdP0CDs7Yt6w+J47c+1oJXOYkNvOPe7SaUX2Xw=";
    })
  ];

  monitor-cpu = stdenv.mkDerivation (finalAttrs: {
    pname = "monitor_cpu";
    version = smu_version;

    src = smu_src;

    patches = smu_patches;


    makeFlags = [
      "-C userspace"
    ];

    installPhase = ''
    runHook preInstall

    install userspace/monitor_cpu -Dm755 -t $out/bin

    runHook postInstall
  '';
  });

in
stdenv.mkDerivation (finalAttrs: {
  pname = "ryzen_smu-${kernel.version}";
  version = smu_version;

  src = smu_src;

  patches = smu_patches;

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "TARGET=${kernel.modDirVersion}"
    "KERNEL_BUILD=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    runHook preInstall

    install ryzen_smu.ko -Dm444 -t $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/ryzen_smu
    install ${monitor-cpu}/bin/monitor_cpu -Dm755 -t $out/bin

    runHook postInstall
  '';

  meta = with lib; {
    #broken = stdenv.isAarch64;
    description = "A Linux kernel driver that exposes access to the SMU (System Management Unit) for certain AMD Ryzen Processors";
    homepage = "https://gitlab.com/leogx9r/ryzen_smu";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ Cryolitia phdyellow ];
    platforms = platforms.linux;
    mainProgram = "monitor_cpu";
  };
})
