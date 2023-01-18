# Sway config from https://discourse.nixos.org/t/some-loose-ends-for-sway-on-nixos-which-we-should-fix/17728/2
{ config, pkgs, lib, ... }:

let
  # bash script to let dbus know about important env variables and
  # propogate them to relevent services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
  dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
  systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
  systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      '';
  };

  # currently, there is some friction between sway and gtk:
  # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
  # the suggested way to set gtk settings is with gsettings
  # for gsettings to work, we need to tell it where the schemas are
  # using the XDG_DATA_DIR environment variable
  # run at the end of sway config
  configure-gtk = pkgs.writeTextFile {
      name = "configure-gtk";
      destination = "/bin/configure-gtk";
      executable = true;
      text = let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsettings-schemas/${schema.name}";
      in ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        gsettings set $gnome_schema gtk-theme $1
        '';
  };


in
{
  environment.systemPackages = [
    dbus-sway-environment
    configure-gtk
    pkgs.wayland
    pkgs.chromium
    pkgs.glib                      # gsettings
    pkgs.dracula-theme             # gtk theme
    pkgs.gnome3.adwaita-icon-theme # default gnome cursors
    pkgs.swaylock
    pkgs.swayidle
    pkgs.grim                      # screenshot functionality
    pkgs.slurp                     # screenshot functionality
    pkgs.wl-clipboard
    pkgs.bemenu
    pkgs.iwgtk
    pkgs.kanshi
    pkgs.waybar
    pkgs.j4-dmenu-desktop
    pkgs.wdisplays
    pkgs.wlr-randr
    pkgs.waypipe
  ];


  environment.etc = {
    "sway/config".source = ./files/sway_config;
    "sway/colorschemes/base16-default-dark".source = ./files/sway_base16_default_dark.colorscheme;
    "xdg/waybar/config".source = ./files/waybar_config;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };


  # xdg-desktop-portal works by exposing a series of D-Bus interfaces
  # known as portals under a well-known name
  # (org.freedesktop.portal.Desktop) and object path
  # (/org/freedesktop/portal/desktop).
  # The portal interfaces include APIs for file access, opening URIs,
  # printing and others.
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # enable sway window manager
  programs.sway = {
    enable = true;
    # extraSessionCommands are taken from Github User xunam: https://github.com/NixOS/nixpkgs/issues/57602#issuecomment-753851568
    extraSessionCommands = ''
        source /etc/profile
        test -f $HOME/.profile && source $HOME/.profile
        export MOZ_ENABLE_WAYLAND=1
        systemctl --user import-environment
      '';
  };

}
