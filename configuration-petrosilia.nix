# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let

  programs = (import ./programs/programs.nix) { inherit pkgs lib; };
  standard-user-hm-config = import ./standard-user-hm-config.nix { inherit pkgs; };

in

{
  imports = [
      ./machines/petrosilia/hardware-configuration.nix
      <home-manager/nixos>
      ./modules/shared_config.nix
      ./modules/laptop.nix
      ./modules/graphical.nix
      ./modules/sway.nix
      ./modules/stardict.nix
      ./modules/petrosilia-private.nix
      #./modules/k3s-server.nix
  ];

  boot.initrd.luks.devices.crypted.device = "/dev/disk/by-uuid/45cd0923-da26-433c-a7ad-5564e90ce9cb";

  networking.hostName = "petrosilia";

  networking.usePredictableInterfaceNames = false;  # use the ambiguous wlan0 instead of the stable wlp3s0

  users.users.jan.openssh.authorizedKeys.keys = [
    (builtins.readFile ./pubkeys/id_rsa_jan_at_petrosilia.pub)
    (builtins.readFile ./pubkeys/id_rsa_heidbrij_at_petrosilia.pub)
  ];

  users.users.heidbrij.openssh.authorizedKeys.keys = [
    (builtins.readFile ./pubkeys/id_rsa_jan_at_petrosilia.pub)
    (builtins.readFile ./pubkeys/id_rsa_heidbrij_at_petrosilia.pub)
  ];

  services.fwupd.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;  # zero-click remote code execution vulnerabilities were discovered in the Linux Bluetooth stack in the past
  services.blueman.enable = true;

  # Enable pipewire. Copied this block from (among others) https://nixos.wiki/wiki/PipeWire#Enabling_PipeWire and https://discourse.nixos.org/t/is-pipewire-ready-for-using/11578/16
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true; # rtkit is optional but recommended
  services.pipewire  = { # https://nixos.wiki/wiki/PipeWire#Enabling_PipeWire
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.etc."kanshi.conf".text = ''
    {
      output eDP-1 enable mode 1920x1080@59.999001Hz position 0,1307 scale 1.1   # 14″ internal screen
    }

    {
      output eDP-1 enable mode 1920x1080@59.999001Hz position 0,1307 scale 1.1
      output "Dell Inc. DELL U2719D 2XSLSS2" enable mode 2560x1440@59.951000Hz position 0,0 scale 1.1  # 27″ screen at home
    }

    {
      output eDP-1 enable mode 1920x1080@59.999001Hz position 999,2687 scale 1.2
      output "Dell Inc. DELL U2719D 2XSLSS2" enable mode 2560x1440@59.951000Hz position 210,1380 scale 1.1  # 27″ screen at home
      output "Dell Inc. DELL U2414H 9TG464A56K4L" enable mode 1920x1080@60Hz position 2600,2270 scale 1.1  # 24" screen at home
    }

    {
      output eDP-1 enable mode 1920x1080@59.999001Hz position 0,0 scale 1.2
      output "Dell Inc. DELL U2715H GH85D89F11KS" enable mode 2560x1440@59.951000Hz position 1920,0 scale 1.1  # in my room
    }

    {
      output eDP-1 enable mode 1920x1080@59.999001Hz position 0,1440 scale 1.1
      output "Dell Inc. DELL U2722D H4Z87H3" enable mode 2560x1440@59.951000Hz position 0,0 scale 1.1  # office
    }
    {
      output eDP-1 enable mode 1920x1080@59.999001Hz position 0,1440 scale 1.1
      output "Dell Inc. DELL U2722D D5Z87H3" enable mode 2560x1440@59.951000Hz position 0,0 scale 1.0  # office
    }
  '';

  i18n.extraLocaleSettings = {
    LC_COLLATE = "C.UTF-8";
    LC_ADDRESS = "de_DE.UTF8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip pkgs.epson-escpr pkgs.gutenprint ];
  };
  services.system-config-printer.enable = true;

  home-manager.users.jan = standard-user-hm-config  // { home.stateVersion = "22.05"; };  # I believe the stateVersion is the version of home-manager that was first installed on that system
  home-manager.users.heidbrij = standard-user-hm-config  // { home.stateVersion = "22.05"; };  # I believe the stateVersion is the version of home-manager that was first installed on that system

  environment.systemPackages = [
    pkgs.meld
    pkgs.jetbrains.idea-ultimate
    pkgs.pulseaudio  # this gives me pactl but doesn't run pulseaudio
    pkgs.lxqt.lxqt-archiver
    pkgs.pantheon.evince
    pkgs.bazel-remote
    pkgs.rustup
    pkgs.bazel_5
    pkgs.aptly
    pkgs.bluetuith
    pkgs.kubectl
    pkgs.direnv
    programs.aws_ssm_ssh
    pkgs.kustomize
    pkgs.jsonnet
    pkgs.kubecfg
    pkgs.k9s
    pkgs.kubectx
    pkgs.steampipe
    pkgs.microsoft-edge
    programs.ende
    programs.ende-full
    pkgs.sdcv
    pkgs.chatgpt-cli
  ];

  services.hardware.bolt.enable = true;

  # Minimal configuration for NFS support with Vagrant. (from NixOS Wiki)
  services.nfs.server.enable = true;
  networking.firewall.extraCommands = ''
    ip46tables -I INPUT 1 -i vboxnet+ -p tcp -m tcp --dport 2049 -j ACCEPT
  '';
  networking.firewall.allowedTCPPorts = [ 5678 ];

  virtualisation.virtualbox.host.enable = true;  # Note that I had to reboot before I could actually use Virtualbox. Or maybe     virtualisation.virtualbox.host.addNetworkInterface would have helped?
  users.extraGroups.vboxusers.members = [ "jan" "heidbrij" ];
  environment.etc."vbox/networks.conf".text = ''
    * 3001::/64
    * 192.168.0.0/16
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
