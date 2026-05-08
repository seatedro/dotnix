{
  config,
  lib,
  pkgs,
  ...
}:
let
  mediaRoot = "/srv/media";
  mediaDomain = "media.home.arpa";
  tailscaleIp = "100.105.99.125";
  tailscaleIpv6 = "fd7a:115c:a1e0::b201:637f";
  torrentPort = 63355;
  plexPreferences = pkgs.writeText "plex-preferences.py" ''
    import sys
    import xml.etree.ElementTree as ET

    path = sys.argv[1]
    tree = ET.parse(path)
    root = tree.getroot()


    def add_csv(name, items):
        values = [value.strip() for value in root.get(name, "").split(",") if value.strip()]
        for item in items:
            if item not in values:
                values.append(item)
        root.set(name, ",".join(values))


    add_csv("allowedNetworks", ["100.64.0.0/10"])
    add_csv("customConnections", ["http://${tailscaleIp}:32400", "http://plex.${mediaDomain}"])

    tree.write(path, encoding="utf-8", xml_declaration=False)
  '';
  managementTcpPorts = [
    53
    80
    32400
    5055
    6767
    7878
    8080
    8081
    8181
    8191
    8686
    8787
    8989
    9696
  ];
  mediaDirs = [
    mediaRoot
    "${mediaRoot}/downloads"
    "${mediaRoot}/downloads/complete"
    "${mediaRoot}/downloads/complete/books"
    "${mediaRoot}/downloads/complete/movies"
    "${mediaRoot}/downloads/complete/music"
    "${mediaRoot}/downloads/complete/tv"
    "${mediaRoot}/downloads/incomplete"
    "${mediaRoot}/downloads/usenet"
    "${mediaRoot}/downloads/usenet/complete"
    "${mediaRoot}/downloads/usenet/incomplete"
    "${mediaRoot}/library"
    "${mediaRoot}/library/books"
    "${mediaRoot}/library/movies"
    "${mediaRoot}/library/music"
    "${mediaRoot}/library/tv"
  ];
in
{
  users.groups.media = { };

  users.users = {
    ro.extraGroups = [ "media" ];
    plex.extraGroups = [
      "render"
      "video"
    ];
  };

  systemd.tmpfiles.rules = map (dir: "d ${dir} 2775 root media - -") mediaDirs;

  services.plex = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  services.overseerr.enable = true;
  services.tautulli = {
    enable = true;
    group = "media";
  };

  services.prowlarr.enable = true;
  services.flaresolverr.enable = true;

  services.radarr = {
    enable = true;
    group = "media";
  };

  services.sonarr = {
    enable = true;
    group = "media";
  };

  services.bazarr = {
    enable = true;
    group = "media";
  };

  services.lidarr = {
    enable = true;
    group = "media";
  };

  services.readarr = {
    enable = true;
    group = "media";
  };

  services.qbittorrent = {
    enable = true;
    group = "media";
    webuiPort = 8080;
    torrentingPort = torrentPort;
    extraArgs = [ "--confirm-legal-notice" ];
  };

  services.sabnzbd = {
    enable = true;
    group = "media";
    configFile = null;
    allowConfigWrite = true;
    settings.misc = {
      complete_dir = "${mediaRoot}/downloads/usenet/complete";
      download_dir = "${mediaRoot}/downloads/usenet/incomplete";
      host = "127.0.0.1";
      host_whitelist = "sabnzbd.${mediaDomain},localhost,127.0.0.1,${tailscaleIp}";
      inet_exposure = "api+web (auth needed)";
      port = 8081;
    };
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      address = [
        "/${mediaDomain}/${tailscaleIp}"
        "/${mediaDomain}/${tailscaleIpv6}"
      ];
      bind-dynamic = true;
      interface = "tailscale0";
      no-hosts = true;
      server = [ "100.100.100.100" ];
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "http://bazarr.${mediaDomain}" = {
        extraConfig = "reverse_proxy localhost:6767";
      };
      "http://lidarr.${mediaDomain}" = {
        extraConfig = "reverse_proxy localhost:8686";
      };
      "http://flaresolverr.${mediaDomain}" = {
        extraConfig = "reverse_proxy localhost:8191";
      };
      "http://overseerr.${mediaDomain}" = {
        extraConfig = "reverse_proxy localhost:5055";
      };
      "http://plex.${mediaDomain}" = {
        extraConfig = "reverse_proxy localhost:32400";
      };
      "http://prowlarr.${mediaDomain}" = {
        extraConfig = "reverse_proxy localhost:9696";
      };
      "http://qbittorrent.${mediaDomain}" = {
        extraConfig = ''
          reverse_proxy localhost:8080 {
            header_up Host {upstream_hostport}
          }
        '';
      };
      "http://radarr.${mediaDomain}" = {
        extraConfig = "reverse_proxy localhost:7878";
      };
      "http://sabnzbd.${mediaDomain}" = {
        extraConfig = "reverse_proxy localhost:8081";
      };
      "http://readarr.${mediaDomain}" = {
        extraConfig = "reverse_proxy localhost:8787";
      };
      "http://sonarr.${mediaDomain}" = {
        extraConfig = "reverse_proxy localhost:8989";
      };
      "http://tautulli.${mediaDomain}" = {
        extraConfig = "reverse_proxy localhost:8181";
      };
    };
  };

  systemd.services = {
    bazarr.serviceConfig.UMask = "0002";
    lidarr.serviceConfig.UMask = "0002";
    plex = {
      preStart = ''
        preferences=${lib.escapeShellArg "${config.services.plex.dataDir}/Plex Media Server/Preferences.xml"}
        if [ -f "$preferences" ]; then
          ${pkgs.python3}/bin/python3 ${plexPreferences} "$preferences"
        fi
      '';
      serviceConfig.UMask = "0002";
    };
    qbittorrent.serviceConfig.UMask = "0002";
    radarr.serviceConfig.UMask = lib.mkForce "0002";
    sabnzbd.serviceConfig.UMask = "0002";
    readarr.serviceConfig.UMask = "0002";
    sonarr.serviceConfig.UMask = lib.mkForce "0002";
  };

  networking.firewall = {
    checkReversePath = "loose";
    allowedTCPPorts = [ torrentPort ];
    allowedUDPPorts = [ torrentPort ];
    interfaces."tailscale0" = {
      allowedTCPPorts = managementTcpPorts;
      allowedUDPPorts = [ 53 ];
    };
  };
}
