{ pkgs, lib }:

let

vim-colors-github = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "vim-colors-github";
    version = "0.1";
    src = pkgs.fetchFromGitHub {
      owner = "endel";
      repo = "vim-github-colorscheme";
      rev = "0a660059cae852c7f90951dea7474cfb1485558e";
      sha256 = "sha256-eoGj2iTO+yO9qQF7HN272Fo35PRneJ/cPQT+4YfU7Yc=";
    };
  };

  vim-colors-ericbn-solarized = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "vim-colors-ericbn-solarized";
    version = "0.1";
    src = pkgs.fetchFromGitHub {
      owner = "ericbn";
      repo = "vim-solarized";
      rev = "2e267f6501c0fe1c0662cf1dd140620398944795";
      sha256 = "sha256-57Wg/2JVcP31PT7FMpHki7bnLsuWH8v/xj0wPbUdXus=";
    };
  };

in

{

  vim-colors-github = vim-colors-github;

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
          vim-colors-ericbn-solarized
          vim-colors-github
        ];
      };
      customRC = builtins.readFile ../dotfiles/init.vim;
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
}
