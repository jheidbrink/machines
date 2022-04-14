# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/844037f9-47ca-46d6-903e-8d5eb15ab360";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/DE09-3FFF";
      fsType = "vfat";
    };

  swapDevices = [ ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # from https://github.com/NixOS/nixos-hardware/blob/c326257692902fe57d3d0f513ebf9c405ccd02ad/lenovo/thinkpad/p14s/amd/gen2/default.nix {{{
  # For suspending to RAM, set Config -> Power -> Sleep State to "Linux" in EFI.
  # amdgpu.backlight=0 makes the backlight work
  # acpi_backlight=none allows the backlight save/load systemd service to work.
  boot.kernelParams = ["amdgpu.backlight=0" "acpi_backlight=none"];
  # For support of newer AMD GPUs, backlight and internal microphone
  boot.kernelPackages = lib.mkIf (lib.versionOlder pkgs.linux.version "5.13") pkgs.linuxPackages_latest;
  # from https://github.com/NixOS/nixos-hardware/blob/c326257692902fe57d3d0f513ebf9c405ccd02ad/lenovo/thinkpad/p14s/amd/gen2/default.nix }}}
}