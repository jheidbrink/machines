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

  # decryption key on usb stick (https://nixos.wiki/wiki/Full_Disk_Encryption#Option_2:_Copy_Key_as_file_onto_a_vfat_usb_stick)
  # Kernel modules needed for mounting USB VFAT devices in initrd stage
  boot.initrd.kernelModules = [ "uas" "usbcore" "usb_storage" "vfat" "nls_cp437" "nls_iso8859_1" ];

  # Mount USB key before trying to decrypt root filesystem
  boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
    mkdir -m 0755 -p /key
    sleep 2 # To make sure the usb key has been loaded
    mount -n -t vfat -o ro `findfs UUID=0012-C721` /key || mount -n -t vfat -o ro `findfs UUID=76E8-CACF` /key
  '';

  boot.initrd.luks.devices.crypted = {
    keyFile = "/key/keyfile";
    preLVM = false;  # If this is true the decryption is attempted before the postDeviceCommands can run
  };

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
  virtualisation.docker.enableNvidia = true;
  hardware.opengl.driSupport32Bit = true; # required for docker.enableNvidia

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}

