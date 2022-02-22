# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }:
let
  unstable = import (
    pkgs.fetchFromGitHub {
      owner = "nixos";
      repo = "nixpkgs";
      rev = "19574af0af3ffaf7c9e359744ed32556f34536bd";  # 2022-02-16 nixpkgs-unstable branch
      sha256 =  "0v3c4r8v40jimicdxqvxnzmdypnafm2baam7z131zk6ljhb8jpg9";
    }
  ) { config = config.nixpkgs.config; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # instead of the stianlagstad.no way, I take the following two lines https://nixos.org/manual/nixos/stable/index.html#sec-luks-file-systems
  boot.initrd.luks.devices.crypted.device = "/dev/disk/by-uuid/88086ce8-7295-420c-916f-ac87f6080b94";

  boot.supportedFilesystems = [ "ntfs" ];  # I don't really care about this at boot time, but the NixOS Wiki uses this line for NTFS support in general

  boot.blacklistedKernelModules = [ "nouveau" ];

  networking.hostName = "schneebesen"; # Define your hostname.
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

  users.users.magma = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "video" "docker" ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
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
    #vscode-with-extensions.override {  # TODO: get this to work
    #  vscodeExtensions = [ vscode-extensions.ms-vscode-remote.remote-ssh ];
    #}
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
    unstable.comma
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
  ];

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
  programs.neovim.enable = true;
  programs.chromium.enable = true;
  programs.wireshark.enable = true;
  programs.light.enable = true;
  programs.nm-applet.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.forwardX11 = true;

  # for Yubikey:
  services.pcscd.enable = true;

  services.keybase.enable = true;  # it seems this doesn't give keybase-gui yet

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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

  virtualisation.virtualbox.host.enable = true;  # Note that I had to reboot before I could actually use Virtualbox. Or maybe     virtualisation.virtualbox.host.addNetworkInterface would have helped?
  users.extraGroups.vboxusers.members = [ "jan" "heidbrij" ];

  virtualisation.docker.enable = true;


  environment.etc."vbox/networks.conf" = {
  mode = "0644";
  text = ''
    * 192.168.0.0/16
  '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

