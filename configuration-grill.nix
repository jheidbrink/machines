# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let

  variables = import ./variables.nix;

  hm = import ./home-manager-stuff.nix { inherit pkgs; };

in

{
  imports = [
      ./machines/grill/hardware-configuration.nix
      ./modules/shared_config.nix
      ./modules/graphical.nix
      ./modules/sway.nix
    ];

  boot.initrd.luks.devices.crypted.device = "/dev/disk/by-uuid/76c62054-71a1-486d-ae85-fe852830b1f0";

  # Debug failures in bootloader stage 1 with a shell - https://discourse.nixos.org/t/unable-to-boot-from-a-usb-device-with-a-luks-partition/26516/2:
  boot.kernelParams = [ "boot.shell_on_fail" ];
  boot.loader.systemd-boot.consoleMode = "auto";

  networking.hostName = "grill";

  networking.interfaces.enp14s0.ipv4.addresses = [
    {
      address = variables.cuisine_ipv4_addresses.grill;
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = "192.168.195.1";
  networking.nameservers =  [ "192.168.195.1" ];

  users.users.jan.openssh.authorizedKeys.keys = [
    (builtins.readFile ./pubkeys/id_rsa_jan_at_petrosilia.pub)
    (builtins.readFile ./pubkeys/id_rsa_jan_at_toastbrot.pub)
    (builtins.readFile ./pubkeys/id_rsa_heidbrij_at_petrosilia.pub)
  ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}

