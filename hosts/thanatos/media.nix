{
  config,
  lib,
  pkgs,
  ...
}:
let
  mediaRoot = "/srv/media";
  mediaMountServices =
    lib.genAttrs
      [
        "bazarr"
        "lidarr"
        "plex"
        "qbittorrent"
        "radarr"
        "readarr"
        "sabnzbd"
        "sonarr"
      ]
      (_: {
        unitConfig.RequiresMountsFor = [ mediaRoot ];
        bindsTo = [ "srv-media.mount" ];
        unitConfig.ConditionPathIsMountPoint = mediaRoot;
      });
  mediaDomain = "media.home.arpa";
  tailscaleIp = "100.105.99.125";
  tailscaleIpv6 = "fd7a:115c:a1e0::b201:637f";
  torrentPort = 63355;
  byparrProxy = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/guyg2232/byparr-proxy/32d2565f3986f0d4f7e0673f32e3b32cf1d347dd/byparr-proxy.py";
    hash = "sha256-fr+NZfRg1c1g1bTG7yoQuFdb91AVGndJgJCnuCjWCoM=";
  };
  byparrDefinitionSource = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/guyg2232/byparr-proxy/32d2565f3986f0d4f7e0673f32e3b32cf1d347dd/definitions/1337x-byparr.yml";
    hash = "sha256-RROFSWyITZLh5/+ZcGIdOo9QiiycIVlGKVh2EmJhTc0=";
  };
  byparrDefinition = pkgs.runCommand "1337x-byparr.yml" { } ''
    substitute ${byparrDefinitionSource} $out \
      --replace-fail "http://byparr-proxy:8888/" "http://127.0.0.1:8888/"
  '';
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
  fileSystems.${mediaRoot} = {
    device = "/dev/disk/by-uuid/86276c83-6652-4dff-9cad-4f2a319a6841";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  services.fstrim.enable = true;

  users.groups.media = { };

  users.users = {
    ro.extraGroups = [ "media" ];
    plex.extraGroups = [
      "render"
      "video"
    ];
  };

  systemd.tmpfiles.rules = map (dir: "d ${dir} 2775 root media - -") mediaDirs;

  virtualisation.oci-containers.containers.byparr = {
    image = "ghcr.io/thephaseless/byparr:3.0.4";
    ports = [ "127.0.0.1:8192:8191" ];
    environment = {
      BROWSER_LOCALE = "en-US";
      HOST = "0.0.0.0";
      PORT = "8191";
    };
    extraOptions = [ "--shm-size=1g" ];
  };

  services.plex = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  services.seerr.enable = true;
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
      "http://127.0.0.1:8082" = {
        extraConfig = ''
          handle /api/v2/auth/login {
            reverse_proxy localhost:8080 {
              header_up Host localhost:8080
              header_up Origin http://localhost:8080
              header_up Referer http://localhost:8080/
              @success status 204
              handle_response @success {
                copy_response_headers {
                  exclude Content-Length
                }
                respond "Ok." 200
              }
            }
          }
          handle {
            reverse_proxy localhost:8080 {
              header_up Host localhost:8080
              header_up Origin http://localhost:8080
              header_up Referer http://localhost:8080/
            }
          }
        '';
      };
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
        extraConfig = "reverse_proxy localhost:8080";
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

  systemd.services = lib.recursiveUpdate mediaMountServices {
    bazarr.serviceConfig.UMask = "0002";
    byparr-proxy = {
      description = "1337x Byparr passthrough";
      wantedBy = [ "multi-user.target" ];
      after = [ "podman-byparr.service" ];
      requires = [ "podman-byparr.service" ];
      environment = {
        BYPARR = "http://127.0.0.1:8192/v1";
        CACHE_TTL_S = "3600";
        PORT = "8888";
        STUB_CAT_PATHS = "true";
        TIMEOUT_MS = "120000";
        UPSTREAM = "https://1337x.to";
      };
      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.python3}/bin/python3 ${byparrProxy}";
        Restart = "on-failure";
      };
    };
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
    prowlarr = {
      preStart = ''
        ${pkgs.coreutils}/bin/install -Dm0644 ${byparrDefinition} "$STATE_DIRECTORY/Definitions/Custom/1337x-byparr.yml"
      '';
      after = [ "byparr-proxy.service" ];
      wants = [ "byparr-proxy.service" ];
      restartTriggers = [ byparrDefinition ];
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
