{ pkgs }:
{
  # see https://discourse.nixos.org/t/home-manager-not-upgrading/36444/3
  manual.html.enable = false;
  manual.manpages.enable = false;
  xdg.mimeApps = {
    # look at https://github.com/Mic92/dotfiles/blob/master/nixpkgs-config/modules/default-apps.nix
    # and https://github.com/lovesegfault/nix-config/blob/master/users/bemeurer/graphical/firefox.nix
    enable = true;
    #associations.added = {
    #  "application/pdf" = ["mupdf.desktop"];
    #  "application/zip" = ["lxqt-archiver.desktop"];
    #};
    defaultApplications = {
      "application/pdf" = ["mupdf.desktop"];
      "application/zip" = ["lxqt-archiver.desktop"];
      "application/x-extension-htm" = "firefox.desktop";
      "application/x-extension-html" = "firefox.desktop";
      "application/x-extension-shtml" = "firefox.desktop";
      "application/x-extension-xht" = "firefox.desktop";
      "application/x-extension-xhtml" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
      "text/html" = "firefox.desktop";
      "x-scheme-handler/chrome" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
    };
  };
  services.dunst.enable = true;
  programs.zsh = {
    enable = false;  # I manage zsh with regular dotfiles
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
}
