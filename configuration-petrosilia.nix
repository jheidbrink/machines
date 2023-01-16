# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/89a8ba0b5b43b3350ff2e3ef37b66736b2ef8706.tar.gz";  # 2022-12-28 release-22.11 branch
    sha256 = "sha256:0p5n9dflr37rd5fl5wag8dyzxrx270lv1vm3991798ba0vq5p9n5";
  };
  standard_user_hm_config = {
    home.stateVersion = "22.05";
    xdg.mimeApps = {
      # look at https://github.com/Mic92/dotfiles/blob/master/nixpkgs-config/modules/default-apps.nix
      # and https://github.com/lovesegfault/nix-config/blob/master/users/bemeurer/graphical/firefox.nix
      enable = true;
      #associations.added = {
      #  "application/pdf" = ["mupdf.desktop"];
      #  "application/zip" = ["lxqt-archiver.desktop"];
      #};
      defaultApplications = {
        "application/pdf" = ["mupdf.desktop"];
        "application/zip" = ["lxqt-archiver.desktop"];
        "application/x-extension-htm" = "firefox.desktop";
        "application/x-extension-html" = "firefox.desktop";
        "application/x-extension-shtml" = "firefox.desktop";
        "application/x-extension-xht" = "firefox.desktop";
        "application/x-extension-xhtml" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
        "text/html" = "firefox.desktop";
        "x-scheme-handler/chrome" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
      };
    };
    services.dunst.enable = true;
    programs.zsh = {
      enable = false;
      plugins = [
        {
          name = "zsh-histdb";
          src = pkgs.fetchFromGitHub {
            owner = "larkery";
            repo = "zsh-histdb";
            rev = "30797f0c50c31c8d8de32386970c5d480e5ab35d";
            sha256 = "1f7xz4ykbdhmjwzcc3yakxwjb0bkn2zlm8lmk6mbdy9kr4bha0ix";
          };
        }
        {
          name = "zsh-histdb-fzf";
          src = pkgs.fetchFromGitHub {
            owner = "jheidbrink";
            repo = "zsh-histdb-fzf";
            rev = "d61040cbc11179614f2cfc1239906d62b0f7b734";
            sha256 = "0rvxyi30cwc9hsf8gb1x9s35di8vb63yfxzpr0r9va721yyn7402";
          };
          file = "fzf-histdb.zsh";
        }
        # fzf-tab
      ];
      history.share = false;
      enableAutosuggestions = true;
      initExtra = ''
        # zsh-histdb {{{
        export PATH=$PATH:${pkgs.sqlite}/bin
        autoload -Uz add-zsh-hook
        # zsh-histdb }}}

        bindkey '^R' histdb-fzf-widget

        # zsh-histdb-with-zsh-autosuggestions {{{
        _zsh_autosuggest_strategy_histdb_top_here() {
            local query="select commands.argv from
        history left join commands on history.command_id = commands.rowid
        left join places on history.place_id = places.rowid
        where places.dir LIKE '$(sql_escape $PWD)%'
        and commands.argv LIKE '$(sql_escape $1)%'
        group by commands.argv order by count(*) desc limit 1"
            suggestion=$(_histdb_query "$query")
        }
        ZSH_AUTOSUGGEST_STRATEGY=histdb_top_here
        # zsh-histdb-with-zsh-autosuggestions }}}
      '';
    };
  };
in
{
  imports = [
    ./shared_config.nix
    ./machines/petrosilia/hardware-configuration.nix
    (import "${home-manager}/nixos")
    ./retiolum.nix
    ./sway.nix
  ];
  boot.initrd.luks.devices.crypted.device = "/dev/disk/by-uuid/45cd0923-da26-433c-a7ad-5564e90ce9cb";

  networking.hostName = "petrosilia"; # Define your hostname.

  hardware.bluetooth.enable = true;
  hardware.bluetooth.hsphfpd.enable = true;  # https://discourse.nixos.org/t/is-pipewire-ready-for-using/11578/6
  services.blueman.enable = true;

  # from https://github.com/starcraft66/os-config/blob/c9b78eef47e2f42f8c37dec024c0631bc7104096/hosts/helia/configuration.nix#L155-L161
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    nerdfonts
    noto-fonts
    emacs-all-the-icons-fonts
    font-awesome
  ];
  # Also take a look at https://github.com/millipedes/NixOS_dot_files/blob/1a3607310fc5649323c9b2b756d18530cc77549f/configuration.nix#L171-L176

  services.pipewire  = { # https://nixos.wiki/wiki/PipeWire#Enabling_PipeWire
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  environment.etc = { # https://nixos.wiki/wiki/PipeWire#Bluetooth_Configuration
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';
    "kanshi.conf".text = ''
      {
        output eDP-1 enable mode 1920x1080@59.999001Hz position 0,1307 scale 1.2
      }

      {
        output eDP-1 enable mode 1920x1080@59.999001Hz position 0,1307 scale 1.2
        output "Dell Inc. DELL U2719D 2XSLSS2" enable mode 2560x1440@59.951000Hz position 0,0 scale 1.1
      }
    '';
  };

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

  home-manager.users.jan = standard_user_hm_config;
  home-manager.users.heidbrij = standard_user_hm_config;

  networking.retiolum.ipv4 = "10.243.143.11";
  networking.retiolum.ipv6 = "42:0:3c46:2dfc:6991:79ff:a57a:9984";
  services.tinc.networks.retiolum = {
    rsaPrivateKeyFile = "/var/secrets/retiolum/rsa_key.priv";
    ed25519PrivateKeyFile = "/var/secrets/retiolum/ed25519_key.priv";
  };

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
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
