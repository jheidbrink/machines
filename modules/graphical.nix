# Sway config from https://discourse.nixos.org/t/some-loose-ends-for-sway-on-nixos-which-we-should-fix/17728/2
{ config, pkgs, lib, ... }:

{
  # Enable the X11 windowing system. It seems this is also needed for wayland
  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;

  environment.systemPackages = [
    pkgs.nomacs  # Image viewer, I've used it for cropping. See also shotwell or gthumb. gthumb is nicer for cycling through all images in a directory
    pkgs.networkmanagerapplet
  ];

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

  # from https://github.com/starcraft66/os-config/blob/c9b78eef47e2f42f8c37dec024c0631bc7104096/hosts/helia/configuration.nix#L155-L161
  # and https://github.com/millipedes/NixOS_dot_files/blob/1a3607310fc5649323c9b2b756d18530cc77549f/configuration.nix#L171-L176
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    nerdfonts
    noto-fonts
    emacs-all-the-icons-fonts
    font-awesome
    fira-code                     # Most Stuff (kitty, GTK, etc.)
    powerline-fonts               # Neovim etc.
  ];
}
