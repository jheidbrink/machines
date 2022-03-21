{ pkgs ? import <nixpkgs> {} }:
pkgs.docker-compose_2.override rec {
  buildGoModule = args: pkgs.buildGoModule (args // {
    installPhase = ''
      install -D $GOPATH/bin/cmd $out/libexec/docker/cli-plugins/docker-compose
      mkdir -p $out/bin
      ln -s ../libexec/docker/cli-plugins/docker-compose $out/bin
    '';
  });
}

