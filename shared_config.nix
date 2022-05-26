{ config, pkgs, ... }:
let
  unstable = import (
    pkgs.fetchFromGitHub {
      owner = "nixos";
      repo = "nixpkgs";
      rev = "b6966d911da89e5a7301aaef8b4f0a44c77e103c";  # 2022-04-06 nixos-unstable branch
      sha256 = "04z7wr2hr1l7l9qaf87bn2i3p6gn6b0k7wnmk3yi9klhz6scnp5v";
    }
  ) { config = config.nixpkgs.config; };
  release2205 = import (
    builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/787b1647a91a1d14b749d8c904ebf629afe5548d.tar.gz";  # 2022-05-25 release-22.05 branch
      sha256 = "119vrkdad181vdj52shqccynm8943yig5ksi5rp6m20iiakm3bnz";
    }
  ) { config = config.nixpkgs.config; };
  syncrepos_unwrapped = pkgs.writers.writePython3Bin "syncrepos.py" { flakeIgnore = [ "E265" "E501" ]; } (builtins.readFile ./bin/syncrepos.py);
  syncrepos = pkgs.writers.writeDashBin "syncrepos" ''
    export PATH=$PATH:${pkgs.git}/bin:${pkgs.kbfs}/bin
    exec ${pkgs.python3}/bin/python3 ${syncrepos_unwrapped}/bin/syncrepos.py
  '';
  myvim = pkgs.vim_configurable.customize {
    name = "vim";
    vimrcConfig = {
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
        ];
      };
      customRC = builtins.readFile ./dotfiles/init.vim;
    };
  };
  example-fzf-vim = pkgs.vim_configurable.customize {
    name = "example-fzf-vim";
    vimrcConfig = {
      packages.myVimPackage = {
        start = with pkgs.vimPlugins;[ fzf-vim vim-fugitive ];
      };
      customRC = ''
        nnoremap <silent> <leader>f :Files<CR>
        nnoremap <silent> <leader>b :Buffers<CR>
        nnoremap <silent> <leader>c :Commands<CR>
        nnoremap <silent> <leader>g :Commits<CR>
        nnoremap <leader>/ :Rg<Space>
      '';
    };
  };
  git-merge-keep-theirs = pkgs.writeDashBin "git-merge-keep-theirs" ''
    mv -f $3 $2
    '';
in
{
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 30;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "ntfs" ];  # I don't really care about this at boot time, but the NixOS Wiki uses this line for NTFS support in general

  boot.kernelModules = [ "acpi_call" ];  # from https://github.com/NixOS/nixos-hardware/blob/c326257692902fe57d3d0f513ebf9c405ccd02ad/common/pc/laptop/acpi_call.nix, from https://github.com/NixOS/nixos-hardware/blob/c326257692902fe57d3d0f513ebf9c405ccd02ad/lenovo/thinkpad/p14s/amd/gen2/default.nix
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];  # from https://github.com/NixOS/nixos-hardware/blob/c326257692902fe57d3d0f513ebf9c405ccd02ad/common/pc/laptop/acpi_call.nix

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;

  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.i3.extraPackages = [ pkgs.dmenu pkgs.i3status pkgs.i3lock pkgs.i3blocks ];

  # Configure keymap in X11
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e, caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  # Prevent tap-clicking: (from https://www.reddit.com/r/NixOS/comments/dwvtvz/disable_touchpad_clicking/f7ocis6/)
  services.xserver.libinput.touchpad.clickMethod = "clickfinger";
  services.xserver.libinput.touchpad.tapping = false;
  services.xserver.libinput.touchpad.disableWhileTyping = true;

  # needed for store VSCode auth token
  services.gnome.gnome-keyring.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jan = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "video" "docker" ]; # wheel enables ‘sudo’ for the user. video allows to control brightess via `light`
  };

  users.users.heidbrij = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "video" "docker" ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    firefox
    tree
    jq
    curl
    python3Packages.argcomplete  # sourced from shell
    python3Packages.virtualenvwrapper  # loaded by my zshrc
    python3Packages.ipython
    python3Packages.pip-tools
    python3Packages.poetry
    python3Packages.pylint
    alacritty  # associated with windows+t shortcut in i3
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
    xclip  # needed also for neovim clipboard support
    vscode
    vagrant
    sqlite
    gsimplecal  # also mapped to i3 keyboard shortcut
    pv
    htop
    xorg.xkill
    ansible
    google-chrome
    arp-scan
    chromium
    bazel_4
    xorg.xmodmap
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
    bat
    gnumake
    mupdf
    docker-compose
    release2205.comma
    gdb
    lldb
    breakpad
    libreoffice
    openssl
    flameshot
    redshift
    wavemon
    gnome.seahorse
    act
    nodejs
    rclone
    ldns  # drill
    myvim
    python39Packages.mypy
    syncrepos
    black
    ripgrep
    fzf
    awscli2
    pciutils
    parted
    Fabric  # for magma
    shellcheck  # should be used by Vim if Ale is installed
    nix-prefetch-git  # helpful for rev and sha in pkgs.fetchFromGitHub
    dfc
    moreutils
    terraform
    jetbrains.idea-community
    dropbox
    wine
    youtube-dl
    nix-index
    gcc
    openvpn
    aws-vault
    makefile2graph
    packer
    mosh
    frp
    tmux
  ];

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
      ExecStart = "${pkgs.dash}/bin/dash -c 'export SSH_AUTH_SOCK=$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket); exec ${syncrepos}/bin/syncrepos'";
    };
  };

  # kill-all-containers copied from https://github.com/containerd/containerd/issues/5502#issuecomment-1019937241  TODO: can this be removed in 22.05?
  systemd.services.kill-all-docker-containers = {
    description = "Kill all docker containers to prevent shutdown lag";
    enable = true;
    unitConfig = {
      DefaultDependencies = false;
      RequiresMountsFor = "/";
    };
    before = [ "shutdown.target" "reboot.target" "halt.target" "final.target" ];
    wantedBy = [ "shutdown.target" "reboot.target" "halt.target" "final.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeScript "docker-kill-all" ''
        #! ${pkgs.runtimeShell} -e
        ${pkgs.docker}/bin/docker ps --format '{{.ID}}' | xargs ${pkgs.docker}/bin/docker kill
      '';
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
  programs.git.enable = true;
  programs.iotop.enable = true;
  programs.iftop.enable = true;
  programs.sysdig.enable = true;
  programs.chromium.enable = true;
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
        ];
      };
    };
  };

  services.openssh.enable = true;
  services.openssh.forwardX11 = true;
  services.pcscd.enable = true;  # for Yubikey
  services.keybase.enable = true;  # it seems this doesn't give keybase-gui yet
  services.gitolite = {
    enable = true;
    adminPubkey = (builtins.readFile ./pubkeys/id_rsa_jan_at_toastbrot.pub);
  };

  # While restoring my home folder, the machine would go to sleep, so let's try https://discourse.nixos.org/t/stop-pc-from-sleep/5757/2
  # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
  # If no user is logged in, the machine will power down after 20 minutes.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Minimal configuration for NFS support with Vagrant. (from NixOS Wiki)
  services.nfs.server.enable = true;
  networking.firewall.extraCommands = ''
    ip46tables -I INPUT 1 -i vboxnet+ -p tcp -m tcp --dport 2049 -j ACCEPT
  '';

  virtualisation.docker.enable = true;

  virtualisation.virtualbox.host.enable = true;  # Note that I had to reboot before I could actually use Virtualbox. Or maybe     virtualisation.virtualbox.host.addNetworkInterface would have helped?
  users.extraGroups.vboxusers.members = [ "jan" "heidbrij" ];
  environment.etc."vbox/networks.conf" = {
  mode = "0644";
  text = ''
    * 192.168.0.0/16
  '';
  };

}

