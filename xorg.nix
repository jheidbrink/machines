{ lib, pkgs, config, options, ... }:

{
  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.i3.extraPackages = [ pkgs.dmenu pkgs.i3status pkgs.i3lock pkgs.i3blocks ];

  environment.systemPackages = [
    xorg.xkill
    xorg.xmodmap
    xorg.xdpyinfo
  ];
}