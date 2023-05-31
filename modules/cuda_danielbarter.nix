# from https://discourse.nixos.org/t/nixos-using-integrated-gpu-for-display-and-external-gpu-for-compute-a-guide/12345
# this is from April 2021
{ config, pkgs, lib, ... }:
{
  nixpkgs.config.allowUnfree = true;
  boot.extraModulePackages = [ pkgs.linuxPackages.nvidia_x11 ];
  boot.blacklistedKernelModules = [ "nouveau" "nvidia_drm" "nvidia_modeset" "nvidia" ];
  environment.systemPackages = [ pkgs.linuxPackages.nvidia_x11 ];  # this was called packages
}
