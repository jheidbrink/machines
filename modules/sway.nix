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

  programs = (import programs/programs.nix) { inherit pkgs lib; };

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

  px = pkgs.writers.writeDashBin "px" ''
    pwd | ${pkgs.wl-clipboard}/bin/wl-copy
  '';

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
    pkgs.wev
    pkgs.xorg.xkbcomp
    px
    pkgs.gsimplecal  # Used in shortcut
    pkgs.udiskie
    # programs.wlr-which-key   # currently doesn't build
  ];


  environment.etc = {
    "sway/config".source = ../files/sway_config;
    "sway/colorschemes/base16-default-dark".source = ../files/sway_base16_default_dark.colorscheme;
    "xdg/waybar/config".source = ../files/waybar_config;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # for automounting USB devices. I guess the service runs as privileged user and manages
  # udiskie invocations from users
  services.udisks2.enable = true;

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

  # TODO: Look at https://github.com/bqv/rc/blob/nixos/profiles/graphical/xkb/default.nix for interesting keyboard layout options
  # The us-gerextra layout is referenced in sway config
  services.xserver.extraLayouts = {
    # us-gerextra copied from https://github.com/bendlas/nixos-config/blob/7820c4fe53e8bc4db4be0f5a8bd858a66ce24248/desktop.nix#L85-L109
    us-gerextra = {
      description = ''
        English layout with german umlauts on AltGr
      '';
      languages = [ "eng" "ger" ];
      keycodesFile = pkgs.writeText "us-gerextra-keycodes" ''
        xkb_keycodes "us-gerextra" { include "evdev+aliases(qwerty)" };
      '';
      geometryFile = pkgs.writeText "us-gerextra-geometry" ''
        xkb_geometry "us-gerextra" { include "pc(pc104)" };
      '';
      typesFile = pkgs.writeText "us-gerextra-types" ''
        xkb_types "us-gerextra" { include "complete" };
      '';
      symbolsFile = pkgs.writeText "us-gerextra-symbols" ''
        xkb_symbols "us-gerextra" {
          key <AD03> { [ e, E, EuroSign ] };
          key <AD07> { [ u, U, udiaeresis, Udiaeresis ] };
          key <AD09> { [ o, O, odiaeresis, Odiaeresis ] };
          key <AC01> { [ a, A, adiaeresis, Adiaeresis ] };
          key <AC02> { [ s, S, ssharp, U1E9E ] };
          augment "pc+us+inet(evdev)+ctrl(nocaps)+level3(ralt_switch)"
        };
      '';
    };
  };

}
