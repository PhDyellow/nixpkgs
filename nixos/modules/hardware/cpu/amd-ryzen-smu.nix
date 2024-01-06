{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hardware.cpu.amd.ryzen_smu;
in
{
  options.hardware.cpu.amd.ryzen_smu = {
    enable = mkEnableOption (lib.mdDoc ''
        A linux kernel driver that exposes access to the SMU (System Management Unit) for certain AMD Ryzen Processors.

        WARNING: Damage cause by use of your AMD processor outside of official AMD specifications or outside of factory settings are not covered under any AMD product warranty and may not be covered by your board or system manufacturer's warranty.
      '');

    package = mkPackageOption pkgs.boot.kernelPackages "ryzen_smu" {
      pkgsText = "pkgs.boot.kernelPackages";
    };

  };

  config = mkIf cfg.enable {
    boot.kernelModules = [ "${cfg.package.name}" ];
    boot.extraModulePackages = [ cfg.package ];
    environment.systemPackages = [ cfg.package ];
  };

  meta.maintainers = with maintainers; [ Cryolitia phdyellow ];

}
