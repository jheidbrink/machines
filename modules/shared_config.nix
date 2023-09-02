{ config, pkgs, lib, ... }:
let

  variables = import ../variables.nix;

  programs = (import ../programs/programs.nix) { inherit pkgs lib; };

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

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  # comment out the following because I had very long wait times at startup, so maybe this is the problem? Might be done by networkmanager anyway
  #networking.interfaces.enp0s31f6.useDHCP = true;
  #networking.interfaces.wlp4s0.useDHCP = true;

  # TODO: What happens if I define this elsewhere as well? Failure? String concatenation? What about lists and sets?
  # TODO: Write a function that generates hosts and read the data from a map
  networking.extraHosts =
    ''
      ${variables.cuisine_ipv4_addresses.grill} grill.cuisine grill
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jan = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "video" "docker" ]; # wheel enables ‘sudo’ for the user. video allows to control brightess via `light`
    openssh.authorizedKeys.keys = [
      (builtins.readFile ../pubkeys/id_rsa_jan_at_toastbrot.pub)
    ];
  };

  users.users.heidbrij = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "video" "docker" ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nixos-generators
    nixos-shell
    wget
    firefox
    gopass # for gopassbridge firefox plugin
    gopass-jsonapi # for gopassbridge firefox plugin
    tree
    jq
    curl
    (python3.withPackages (ps: [ ps.pyyaml ps.ipython ]))  # putting ipython and yaml in the same environment so that I can `import yaml' from an ipython session
    python3Packages.argcomplete  # sourced from shell
    python3Packages.virtualenvwrapper  # loaded by my zshrc
    python3Packages.pip-tools
    python3Packages.pylint
    python3Packages.mypy
    python3Packages.pip
    poetry
    programs.alacritty-light  # associated with windows+t shortcut in i3
    gitAndTools.diff-so-fancy  # git is configured to use it
    stow  # needed by my dotfiles managing script
    thunderbird
    fzf  # needed at least for zsh history search
    pass
    yubikey-manager
    yubikey-manager-qt
    zoom-us
    dua # disk usage analyzer inspired by ncdu. ncdu2 crashes on my machine
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
    nodePackages.typescript
    rclone
    ldns  # drill
    programs.vim.myvim
    programs.syncrepos
    black
    ripgrep
    awscli2
    ssm-session-manager-plugin
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
    tdesktop  # Telegram
    signal-desktop
    socat
    jiq
    dropbear
    unixtools.xxd
    libnotify
    speechd # for spd-say as notification in shell scripts
    haskellPackages.git-annex
    qemu
    quickemu
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
    dracut  # for lsinitrd
    weechat
    nil  # Nix language server
    sox  # The swiss army knife of audio manipulation
    git
    git-filter-repo
    git-lfs
    bfg-repo-cleaner
    ethtool
    lsof
    qrencode
    imagemagick
  ];

  programs.java.enable = true;

  # Make NixOS a bit more compatible to non-NixOS binaries
  programs.nix-ld.enable = true;

  # Make NixOS a bit more compatible to non-NixOS shebangs
  services.envfs.enable = true;

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
      customRC = (builtins.readFile ../dotfiles/init.vim);
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
          vim-repeat  # also from tpope, makes . correctly repeat the last vim-surround
          vim-css-color
          nvim-lspconfig
        ];
      };
    };
  };

  services.openssh = {
    enable = true;
    forwardX11 = true;
    # require public key authentication for better security
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    permitRootLogin = "no";
  };
  services.pcscd.enable = true;  # for Yubikey
  services.keybase.enable = true;  # it seems this doesn't give keybase-gui yet
  services.earlyoom.enable = true;  # Kills processses before the OOMKiller and hopefully before the system becomes unbearably slow

  environment.sessionVariables = {
    GREP_OPTIONS = "--color=always";
  };

}

