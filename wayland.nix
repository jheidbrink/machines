# Copied and adapted from https://github.com/Ericson2314/nixos-configuration/blob/01034b14dd76c309c840fd5bf54b713e8df67dd2/user/graphical/wayland.nix
{ lib, pkgs, config, options, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    config = {
      terminal = "alacritty";
      menu     = "bemenu-run";

      up       = "i";
      down     = "k";
      left     = "j";
      right    = "l";

      output = {
        "eDP-1" = {
          scale = "1";
        };
      };

      floating.criteria = [
        {
          "title" = "Firefox — Sharing Indicator";
        }
      ];

      window.commands = [
        {
          criteria = {
            "title" = "Firefox — Sharing Indicator";
          };
          command = "nofocus";
        }
      ];

      keybindings = {
        "Mod4+Shift+Return" = "exec alacritty";
        "Mod4+Shift+c" = "kill";
        "Mod4+p" = "exec bemenu";
        "Mod4+q" = "reload";
        "Mod4+a" = "exec autorandr -c";
        "Mod4+s" = "exec systemctl suspend";
        "Mod4+d" = "exec physlock";
        "Mod4+f" = "exec emacsclient --create-frame";
        "Mod4+Shift+q" =
          "exec swaynag -t warning -m 'Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";
        "Mod4+0" = "workspace number 10";
        "Mod4+Shift+0" =
            "move container to workspace number 10";
      };
    };
    systemdIntegration = true;
  };

  home.packages = let
    forceWayland = t: e: f: pkgs.stdenv.mkDerivation {
       pname = t.pname or t.name + "-force-wayland";
       inherit (t) version;
       unpackPhase = "true";
       doBuild = false;
       nativeBuildInputs = [ pkgs.buildPackages.makeWrapper ];
       installPhase = ''
         mkdir -p $out/bin
         ln -s "${lib.getBin t}/bin/${e}" "$out/bin"
       '';
       postFixup = ''
         for e in $out/bin/*; do
           wrapProgram $e ${f}
         done
       '';
    };
  in with pkgs; [
    #swaylock
    #iswayidle
    wl-clipboard
    mako # notification daemon
    alacritty # Alacritty is the default terminal in the config
    wofi
    bemenu
    (forceWayland thunderbird "thunderbird" "--set-default MOZ_ENABLE_WAYLAND 1")
    (forceWayland chromium "chromium" "--add-flags '--enable-features=UseOzonePlatform --ozone-platform=wayland'")
    (forceWayland signal-desktop "signal-desktop" "--add-flags '--enable-features=UseOzonePlatform --ozone-platform=wayland'")
    (forceWayland element-desktop "element-desktop" "--add-flags '--enable-features=UseOzonePlatform --ozone-platform=wayland'")
  ];

  programs.firefox.package = pkgs.firefox-wayland;
}
