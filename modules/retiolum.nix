{ config, pkgs, lib, ... }:

with lib;

let

  netname = "retiolum";
  cfg = config.networking.retiolum;

  retiolum = pkgs.fetchgit {
    url = "https://github.com/krebs/retiolum.git";
    rev = "da984ffd1ed84c5718eb21bca0696957a6dacbcb";
    sha256 = "sha256-x0hMjchfbJVjQbdC6a0e52ggB6xPuO05an0tgqDOYD4=";
  };

in {
  options = {
    networking.retiolum.ipv4 = mkOption {
      type = types.str;
      description = ''
        own ipv4 address
      '';
    };
    networking.retiolum.ipv6 = mkOption {
      type = types.str;
      description = ''
        own ipv6 address
      '';
    };
    networking.retiolum.nodename = mkOption {
      type = types.str;
      default = config.networking.hostName;
      description = ''
        tinc network name
      '';
    };
  };

  config = {

    services.tinc.networks.${netname} = {
      name = cfg.nodename;
      extraConfig = ''
        LocalDiscovery = yes
        AutoConnect = no
        ConnectTo = prism
      '';
    };
    systemd.services."tinc.${netname}" = {
      preStart = ''
        cp -R ${retiolum}/hosts /etc/tinc/retiolum/ || true
      '';
    };

    networking.extraHosts = builtins.readFile (toString "${retiolum}/etc.hosts");

    environment.systemPackages = [ config.services.tinc.networks.${netname}.package ];

    networking.firewall.allowedTCPPorts = [ 655 ];
    networking.firewall.allowedUDPPorts = [ 655 ];
    #services.netdata.portcheck.checks.tinc.port = 655;

    systemd.network.enable = true;
    systemd.network.networks = {
      "${netname}".extraConfig = ''
        [Match]
        Name = tinc.${netname}
        [Network]
        Address=${cfg.ipv4}/12
        Address=${cfg.ipv6}/16
      '';
    };
  };
}
