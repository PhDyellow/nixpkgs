{ lib
, stdenv
, fetchFromGitLab
, fetchurl
, kernel
}:

let
  smu_version = "0.1.5";

  ## Upstream has not been merging PRs.
  ## Nixpkgs maintainers are providing a
  ## repo with PRs merged until upstream is
  ## updated.
  smu_src = fetchFromGitHub {
    owner = "Cryolitia";
    repo = "ryzen_smu";
    rev = "ce1aa918efa33ca79998f0f7d467c04d4b07016c";
    hash = "00808dhsn2pscjjw1yr4d2hk3pn4bnv8d122cnm1b2zsnacr5m5k";
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

    description = "A Linux kernel driver that exposes access to the SMU (System Management Unit) for certain AMD Ryzen Processors";

    homepage = "https://gitlab.com/leogx9r/ryzen_smu";

    license = licenses.gpl2Plus;

    maintainers = with maintainers; [ Cryolitia phdyellow ];

    platforms = [ "x86_64-linux" ];

    mainProgram = "monitor_cpu";
  };
})
