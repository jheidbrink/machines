{ pkgs, lib }:

let

vim-colors-github = pkgs.vimUtils.buildVimPlugin {
    pname = "vim-colors-github";
    version = "0.1";
    src = pkgs.fetchFromGitHub {
      owner = "endel";
      repo = "vim-github-colorscheme";
      rev = "0a660059cae852c7f90951dea7474cfb1485558e";
      sha256 = "sha256-eoGj2iTO+yO9qQF7HN272Fo35PRneJ/cPQT+4YfU7Yc=";
    };
  };

  vim-colors-ericbn-solarized = pkgs.vimUtils.buildVimPlugin {
    pname = "vim-colors-ericbn-solarized";
    version = "0.1";
    src = pkgs.fetchFromGitHub {
      owner = "ericbn";
      repo = "vim-solarized";
      rev = "2e267f6501c0fe1c0662cf1dd140620398944795";
      sha256 = "sha256-57Wg/2JVcP31PT7FMpHki7bnLsuWH8v/xj0wPbUdXus=";
    };
  };

  vim-colors-dim = pkgs.vimUtils.buildVimPlugin {
    pname = "vim-colors-dim";
    version = "0.1";
    src = pkgs.fetchFromGitHub {
      owner = "jeffkreeftmeijer";
      repo = "vim-dim";
      rev = "8320a40f12cf89295afc4f13eb10159f29c43777";
      sha256 = "sha256-sDt3gvf+/8OQ0e0W6+IinONQZ9HiUKTbr+RZ2CfJ3FY=";
    };
  };

  vim-colors-noctu = pkgs.vimUtils.buildVimPlugin {
    pname = "vim-colors-noctu";
    version = "0.1";
    src = pkgs.fetchFromGitHub {
      owner = "noahfrederick";
      repo = "vim-noctu";
      rev = "de2ff9855bccd72cd9ff3082bc89e4a4f36ea4fe";
      sha256 = "sha256-fiMYfRlm/KiMQybL97RcWy3Y+0qim6kl3ZkBvCuv4ZM=";
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
          vim-colors-dim
          vim-colors-noctu
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
