# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./machines/schneebesen/hardware-configuration.nix
      <home-manager/nixos>  # we have to configure a home-manager channel for root user
      ./shared_config.nix
      ./xorg.nix
    ];

  # instead of the stianlagstad.no way, I take the following two lines https://nixos.org/manual/nixos/stable/index.html#sec-luks-file-systems
  boot.initrd.luks.devices.crypted.device = "/dev/disk/by-uuid/88086ce8-7295-420c-916f-ac87f6080b94";

  boot.blacklistedKernelModules = [ "nouveau" ];

  networking.hostName = "schneebesen"; # Define your hostname.

  home-manager.users.jan = { pkgs, ...}: {
    home.packages = [ pkgs.httpie ];
    programs.neovim = {
      enable = true;
      withPython3 = true;
      extraPackages = [ ];
      plugins = with pkgs.vimPlugins; [
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
      extraConfig = builtins.readFile ./dotfiles/init.vim;
    };
    programs.alacritty.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}

