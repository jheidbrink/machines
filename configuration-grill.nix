# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let

  variables = import ./variables.nix;

  #home-manager-tarball = builtins.fetchTarball {
  #  url = "https://github.com/nix-community/home-manager/archive/89a8ba0b5b43b3350ff2e3ef37b66736b2ef8706.tar.gz";  # 2022-12-28 release-22.11 branch
  #  sha256 = "sha256:0p5n9dflr37rd5fl5wag8dyzxrx270lv1vm3991798ba0vq5p9n5";
  #};

  #standard-user-hm-config = import ./standard-user-hm-config.nix { inherit pkgs; };

in

{
  imports = [
      ./machines/grill/hardware-configuration.nix
      ./modules/shared_config.nix
      ./modules/retiolum.nix
      #./modules/graphical.nix
      ./modules/sway.nix
      ./modules/cuda.nix
      #./modules/cuda_danielbarter.nix
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

  networking.retiolum.ipv4 = "10.243.217.217";
  networking.retiolum.ipv6 = "42:0:6a0a:c4b1:2d6c:1f3f:a3c6:9d96";
  services.tinc.networks.retiolum = {
    rsaPrivateKeyFile = "/var/secrets/retiolum/rsa_key.priv";
    ed25519PrivateKeyFile = "/var/secrets/retiolum/ed25519_key.priv";
  };

  users.users.jan.openssh.authorizedKeys.keys = [
    (builtins.readFile ./pubkeys/id_rsa_jan_at_petrosilia.pub)
    (builtins.readFile ./pubkeys/id_rsa_jan_at_toastbrot.pub)
    (builtins.readFile ./pubkeys/id_rsa_heidbrij_at_petrosilia.pub)
  ];

  users.users.jan.extraGroups = [ "docker" ];

  # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
  # If no user is logged in, the machine will power down after 20 minutes.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  #home-manager.users.jan = standard_user_hm_config;  // { home.stateVersion = "23.05"; };  # I believe the stateVersion is the version of home-manager that was first installed on that system. Home-manager is not installed on Grill yet, will start with NixOS 23.05

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  virtualisation.docker.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}

