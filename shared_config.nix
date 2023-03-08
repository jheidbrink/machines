{ config, pkgs, lib, ... }:
let
  programs = (import programs/programs.nix) { inherit pkgs lib; };

in
{
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 30;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "ntfs" ];  # I don't really care about this at boot time, but the NixOS Wiki uses this line for NTFS support in general

  boot.kernelModules = [ "acpi_call" ];  # from https://github.com/NixOS/nixos-hardware/blob/c326257692902fe57d3d0f513ebf9c405ccd02ad/common/pc/laptop/acpi_call.nix, from https://github.com/NixOS/nixos-hardware/blob/c326257692902fe57d3d0f513ebf9c405ccd02ad/lenovo/thinkpad/p14s/amd/gen2/default.nix
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];  # from https://github.com/NixOS/nixos-hardware/blob/c326257692902fe57d3d0f513ebf9c405ccd02ad/common/pc/laptop/acpi_call.nix

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # from https://discourse.nixos.org/t/nvd-simple-nix-nixos-version-diff-tool/12397/34
  system.activationScripts.report-changes = ''
    PATH=$PATH:${lib.makeBinPath [  pkgs.nix ]}
    echo "+++++CHANGES++++++"
    nix --extra-experimental-features nix-command store diff-closures $(ls -dv /nix/var/nix/profiles/system-*-link/|tail -2)
  '';

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # not sure what wireless.enable does, but seems orthogonal or even conflicting with networkmanager, and I want networkmanager

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  # comment out the following because I had very long wait times at startup, so maybe this is the problem? Might be done by networkmanager anyway
  #networking.interfaces.enp0s31f6.useDHCP = true;
  #networking.interfaces.wlp4s0.useDHCP = true;

  networking.extraHosts =
    ''
      127.0.0.2 bazel.cache
    '';

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  services.upower.enable = true;
  services.tlp.enable = true; # TLP power management daemon
  services.thermald.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;

  # Enable pipewire. Copied this block from https://nixos.wiki/wiki/PipeWire#Enabling_PipeWire
  security.rtkit.enable = true; # rtkit is optional but recommended

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  # Prevent tap-clicking: (from https://www.reddit.com/r/NixOS/comments/dwvtvz/disable_touchpad_clicking/f7ocis6/)
  services.xserver.libinput.touchpad.clickMethod = "clickfinger";
  services.xserver.libinput.touchpad.tapping = false;
  services.xserver.libinput.touchpad.disableWhileTyping = true;

  # needed for store VSCode auth token
  services.gnome.gnome-keyring.enable = true;

  services.redshift.enable = true;  # this is a user service that still needs to be enabled by the respective users
  services.redshift.temperature.day = 4800;

  # location info is used by redshift
  location.latitude = 52.5;
  location.longitude = 13.4;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jan = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "video" "docker" "lxd" ]; # wheel enables ‘sudo’ for the user. video allows to control brightess via `light`
  };

  users.users.heidbrij = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "video" "docker" "lxd" ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nixos-generators
    nixos-shell
    wget
    firefox
    tree
    jq
    curl
    python310Packages.argcomplete  # sourced from shell
    python310Packages.virtualenvwrapper  # loaded by my zshrc
    python310Packages.ipython
    python310Packages.pip-tools
    python310Packages.poetry
    python310Packages.pylint
    programs.alacritty-light  # associated with windows+t shortcut in i3
    gitAndTools.diff-so-fancy  # git is configured to use it
    stow  # needed by my dotfiles managing script
    thunderbird
    fzf  # needed at least for zsh history search
    pass
    yubikey-manager
    zoom-us
    ncdu
    kbfs  # Keybase filesystem, this also brings the git-remote-keybase binary
    keybase-gui
    vscode
    vagrant
    sqlite
    gsimplecal  # also mapped to i3 keyboard shortcut
    pv
    htop
    ansible
    #google-chrome
    arp-scan
    chromium
    pwgen
    gcc
    go
    graphviz
    gnome.eog
    file
    unzip
    gimp
    pcmanfm
    pavucontrol
    mpv
    programs.bat  # wrapper around bat with ANSI colortheme
    gnumake
    mupdf
    comma
    gdb
    lldb
    breakpad
    libreoffice
    openssl
    flameshot
    wavemon
    gnome.seahorse
    act
    nodejs
    rclone
    ldns  # drill
    programs.vim.myvim
    python39Packages.mypy
    programs.syncrepos
    black
    ripgrep
    fzf
    awscli2
    pciutils
    parted
    shellcheck  # should be used by Vim if Ale is installed
    nix-prefetch-git  # helpful for rev and sha in pkgs.fetchFromGitHub
    dfc
    moreutils
    terraform
    dropbox
    wine
    yt-dlp  # Fork of youtube-dlc which I think is an inactive fork of youtube-dl. I'm using it because the youtube-dl release is so old that it doesn't work for Youtube.
    nix-index
    gcc
    openvpn
    aws-vault
    makefile2graph
    packer
    mosh
    frp
    tmux
    tdesktop
    signal-desktop
    socat
    jiq
    dropbear
    unixtools.xxd
    libnotify
    speechd # for spd-say as notification in shell scripts
    haskellPackages.git-annex
    qemu
    gparted
    binutils  # ar, ld, readelf, strings, ...
    powertop
    stuntman  # STUN server and client - I only need the client
    traceroute
    zip
    easyeffects
    redshift
    gh
    ltrace
    cachix
    _1password-gui
    programs.bininfo
    dhcp
    tcpdump
    wireshark
    programs.git-merge-keep-theirs
    sequoia
    nmap
    sshpass
    libfaketime
    dive
    libcgroup
    xdot
    nushell
    programs.nns
    programs.qemu_nographic
    html-tidy
    programs.nixs
    pstree
    programs.fd  # supposedly faster and more user-friendly find replacement
    programs.print256colors
    programs.print_ansi_colors
    programs.alacritty-solarized
  ];

  programs.java.enable = true;

  # Allow the user run a program to poweroff the system. (Copied and adapted from https://discourse.nixos.org/t/how-to-configure-nixos-to-allow-a-program-to-trigger-shutdown/11582)
  security.polkit = {
    extraConfig = ''
      polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.systemd1.manage-units" ||
              action.id == "org.freedesktop.systemd1.manage-unit-files") {
              if (action.lookup("unit") == "suspend.target") {
                  if (subject.isInGroup("wheel")) {
                      return polkit.Result.YES;
                  }
              }
          }
      });
    '';
  };

  systemd.user.services.syncrepos = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "gpg-agent.service" ];
    description = "Synchronize Users Git repositories";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.dash}/bin/dash -c 'export SSH_AUTH_SOCK=$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket); exec ${programs.syncrepos}/bin/syncrepos'";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.zsh.enable = true;
  programs.fish.enable = true;
  programs.git.enable = true;
  programs.iotop.enable = true;
  programs.iftop.enable = true;
  programs.sysdig.enable = true;
  #programs.chromium.enable = true;
  programs.wireshark.enable = true;
  programs.light.enable = true;
  programs.nm-applet.enable = true;
  programs.neovim = {
    enable = true;
    configure = {
      customRC = (builtins.readFile ./dotfiles/init.vim);
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          fzf-vim
          undotree
          ultisnips
          vim-snippets
          ale
          vim-better-whitespace
          vim-fugitive
          vim-nix
          vim-go
          deoplete-nvim
          deoplete-clang
          deoplete-jedi
          tagbar
          vim-colors-solarized
          vim-surround
          vim-css-color
        ];
      };
    };
  };

  services.openssh.enable = true;
  services.openssh.forwardX11 = true;
  services.pcscd.enable = true;  # for Yubikey
  services.keybase.enable = true;  # it seems this doesn't give keybase-gui yet
  services.earlyoom.enable = true;  # Kills processses before the OOMKiller and hopefully before the system becomes unbearably slow

  # Minimal configuration for NFS support with Vagrant. (from NixOS Wiki)
  services.nfs.server.enable = true;
  networking.firewall.extraCommands = ''
    ip46tables -I INPUT 1 -i vboxnet+ -p tcp -m tcp --dport 2049 -j ACCEPT
  '';
  networking.firewall.allowedTCPPorts = [ 5678 ];

  #virtualisation.docker.enable = true;
  #virtualisation.docker.extraOptions = "--insecure-registry 192.168.60.1:5678";   #  Virtualbox network for magma VM

  virtualisation.lxd.enable = true;

  #services.dockerRegistry.enable = true;
  #services.dockerRegistry.listenAddress = "192.168.60.1";  # Virtualbox network for magma VM
  #services.dockerRegistry.port = 5678;

  virtualisation.virtualbox.host.enable = true;  # Note that I had to reboot before I could actually use Virtualbox. Or maybe     virtualisation.virtualbox.host.addNetworkInterface would have helped?
  users.extraGroups.vboxusers.members = [ "jan" "heidbrij" ];
  environment.etc."vbox/networks.conf".text = ''
    * 3001::/64
    * 192.168.0.0/16
  '';

  environment.sessionVariables = {
    GREP_OPTIONS = "--color=always";
  };

}

