{ lib, pkgs, config, options, ... }:

{
  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.i3.extraPackages = [ pkgs.dmenu pkgs.i3status pkgs.i3lock pkgs.i3blocks ];

  # Configure keymap in X11
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e, caps:escape";

  environment.systemPackages = [
    pkgs.xorg.xkill
    pkgs.xorg.xmodmap
    pkgs.xorg.xdpyinfo
    pkgs.xcalib
    pkgs.xclip  # needed also for neovim clipboard support
  ];
}
