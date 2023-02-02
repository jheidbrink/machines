# Sway config from https://discourse.nixos.org/t/some-loose-ends-for-sway-on-nixos-which-we-should-fix/17728/2
{ config, pkgs, lib, ... }:

{
  environment.systemPackages = [
    pkgs.nomacs  # Image viewer, I've used it for cropping. See also shotwell or gthumb. gthumb is nicer for cycling through all images in a directory
  ];
}
