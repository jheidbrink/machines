{ config, pkgs, lib, ... }:

with lib;

let

  netname = "retiolum";
  cfg = config.networking.retiolum;

  retiolum = pkgs.fetchgit {
    url = "https://github.com/krebs/retiolum.git";
    rev = "2a26f7d66c9601a33a4baef1ec783b5f3b94498b";
    sha256 = "sha256-gYLqhhGkJMDHwMY76BVsxtvtSag056mu9tE8zBLdcJ0=";
  };

in {
  options = {
    networking.retiolum.ipv4 = mkOption {
      type = with types; nullOr str;
      description = ''
        own ipv4 address
      '';
      default = null;
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
        AutoConnect = yes
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
        Address=${cfg.ipv6}/16
      '' + optionalString (cfg.ipv4 != null) ''
        Address=${cfg.ipv4}/12
      '';
    };
  };
}
