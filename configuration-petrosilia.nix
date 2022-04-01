# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports = [
    ./shared_config.nix
    ./machines/petrosilia/hardware-configuration.nix
    <home-manager/nixos>
  ];
  boot.initrd.luks.devices.crypted.device = "/dev/disk/by-uuid/45cd0923-da26-433c-a7ad-5564e90ce9cb";

  networking.hostName = "petrosilia"; # Define your hostname.

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  home-manager.users.jan = {
    programs.zsh = {
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
