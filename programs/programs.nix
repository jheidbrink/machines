{ pkgs, lib }:
rec {
  vim = (import ./vim.nix) { inherit pkgs  lib; };
  qemu_nographic_sh = pkgs.writeShellScriptBin "qemu_nographic.sh" (builtins.readFile ./qemu_nographic.sh);
  qemu_nographic = pkgs.writers.writeDashBin "qemu_nographic"  ''
    export PATH=${lib.makeBinPath [ pkgs.bash pkgs.qemu ]};
    ${qemu_nographic_sh}/bin/qemu_nographic.sh "$@"
  '';
  nns = pkgs.writers.writeDashBin "nns" ''
    network_namespace=$1
    shift
    sudo -E ${pkgs.iproute2}/bin/ip netns exec "$network_namespace" sudo -E -u "$USER" "$@"
  '';
  bininfo = pkgs.writeShellScriptBin "bininfo" (builtins.readFile ./bininfo);
  ansible-playbook-grapher_repo_v1_1_2-dev = pkgs.fetchFromGitHub {
    owner = "haidaraM";
    repo = "ansible-playbook-grapher";
    rev = "1d804bbb01eab5c07d42f6eb4917e1d643e3c4b3";
    sha256 = "spAI/eF+U5VMTj7ac7s01xZ5wEfyHAQ6jFyCvcEU6mE=";
  };
  selenized = pkgs.fetchFromGitHub {
    owner = "jan-warchol";
    repo = "selenized";
    rev = "df1c7f1f94f22e2c717f8224158f6f4097c5ecbe";
    sha256 = "3dZ2LMv0esbzJvfrtWWbO9SFotXj3UeizjMxO6vs73M=";
  };
  alacritty-config-selenized = pkgs.writeText "alacritty-selenized.yml" ''
    font:
      size: 10

    import:
      - ${selenized}/terminals/alacritty/selenized-light.yml
  '';
  alacritty-light = pkgs.writers.writeDashBin "alacritty" ''
    ${pkgs.alacritty}/bin/alacritty --config-file ${alacritty-config-selenized}
  '';
  ansible-playbook-grapher = pkgs.python310Packages.buildPythonApplication {
    pname = "ansible-playbook-grapher";
    version = "1.1.2-dev";
    buildInputs = [ pkgs.graphviz ];
    propagatedBuildInputs = with pkgs.python310Packages; [ ansible-core colour lxml ];
    doCheck = false;
    doInstallCheck = false;
    src = ansible-playbook-grapher_repo_v1_1_2-dev;
  };
  syncrepos_unwrapped = pkgs.writers.writePython3Bin "syncrepos.py" { flakeIgnore = [ "E265" "E501" ]; } (builtins.readFile ./syncrepos.py);
  syncrepos = pkgs.writers.writeDashBin "syncrepos" ''
    export PATH=$PATH:${pkgs.git}/bin:${pkgs.kbfs}/bin
    exec ${pkgs.python310}/bin/python3 ${syncrepos_unwrapped}/bin/syncrepos.py
  '';
  git-merge-keep-theirs = pkgs.writers.writeDashBin "git-merge-keep-theirs" ''
    mv -f $3 $2
    '';
  bazel = pkgs.writers.writeDashBin "bazel" ''
    ${pkgs.bazelisk}/bin/bazelisk
  '';
  nixs = pkgs.writeShellScriptBin "nixs" ''
    export NIX_SHELL_INFO=$1
    nix-shell -p $1 --run zsh
  '';
}