# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }:

let

  hm = import ./home-manager-stuff.nix { inherit pkgs; };

in

{
  imports =
    [ # Include the results of the hardware scan.
      ./machines/schneebesen/hardware-configuration.nix
    (import "${hm.home-manager}/nixos")
      ./modules/shared_config.nix
      ./modules/laptop.nix
      ./modules/graphical.nix
      ./modules/xorg.nix
    ];

  # instead of the stianlagstad.no way, I take the following two lines https://nixos.org/manual/nixos/stable/index.html#sec-luks-file-systems
  boot.initrd.luks.devices.crypted.device = "/dev/disk/by-uuid/88086ce8-7295-420c-916f-ac87f6080b94";

  boot.blacklistedKernelModules = [ "nouveau" ];

  networking.hostName = "schneebesen"; # Define your hostname.

  home-manager.users.jan = hm.standard_user_hm_config;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}

