{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.vanta;

  vanta = pkgs.stdenv.mkDerivation {
    pname = "vanta";
    version = "2.15.0";

    src = pkgs.fetchurl {
      url = "https://agent-downloads.vanta.com/targets/versions/2.15.0/vanta-amd64.deb";
      sha256 = "02ba826388dee61aaf3e97f4bec61896620bc616754e7d107c0efcc79abd43a0";
    };

    nativeBuildInputs = with pkgs; [
      dpkg
      autoPatchelfHook
    ];

    buildInputs = with pkgs; [
      glibc
    ];

    unpackPhase = "dpkg-deb -x $src .";

    installPhase = ''
      mkdir -p $out/bin
      cp var/vanta/metalauncher $out/bin/
      cp var/vanta/launcher $out/bin/
      cp var/vanta/vanta-cli $out/bin/
      cp var/vanta/osqueryd $out/bin/
      cp var/vanta/osquery-vanta.ext $out/bin/
      cp var/vanta/cert.pem $out/bin/
    '';
  };

  configJson = builtins.toJSON {
    AGENT_KEY = cfg.agentKey;
    OWNER_EMAIL = cfg.ownerEmail;
    NEEDS_OWNER = true;
  };

  writeConfScript = pkgs.writeShellScript "vanta-write-conf" ''
    AGENT_KEY="$(cat ${cfg.agentKeyFile})"
    ${pkgs.jq}/bin/jq -n \
      --arg key "$AGENT_KEY" \
      --arg email "${cfg.ownerEmail}" \
      '{AGENT_KEY: $key, OWNER_EMAIL: $email, NEEDS_OWNER: true}' \
      > /etc/vanta.conf
    chmod 0600 /etc/vanta.conf
  '';

  setupScript = pkgs.writeShellScript "vanta-setup" ''
    mkdir -p /var/vanta
    for f in metalauncher launcher vanta-cli osqueryd osquery-vanta.ext cert.pem; do
      rm -f "/var/vanta/$f"
      cp "${vanta}/bin/$f" "/var/vanta/$f"
    done
    chmod 0755 /var/vanta/metalauncher /var/vanta/launcher /var/vanta/vanta-cli /var/vanta/osqueryd /var/vanta/osquery-vanta.ext
    chmod 0644 /var/vanta/cert.pem
    chown root:root /var/vanta/*
  '';
in
{
  options.services.vanta = {
    enable = mkEnableOption "Vanta compliance agent";

    agentKey = mkOption {
      type = types.str;
      default = "";
      description = ''
        Vanta agent key for authentication.
        Warning: stored in the world-readable Nix store.
        Prefer agentKeyFile for production use.
      '';
    };

    agentKeyFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to a file containing the Vanta agent key.
        Keeps the secret out of the Nix store.
      '';
    };

    ownerEmail = mkOption {
      type = types.str;
      description = "Email address of the device owner in Vanta.";
    };

    region = mkOption {
      type = types.str;
      default = "us";
      description = "Vanta region (us, eu, or aus).";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.agentKey != "" || cfg.agentKeyFile != null;
        message = "services.vanta: Either agentKey or agentKeyFile must be set.";
      }
      {
        assertion = !(cfg.agentKey != "" && cfg.agentKeyFile != null);
        message = "services.vanta: Set only one of agentKey or agentKeyFile, not both.";
      }
    ];

    environment.etc."vanta.conf" = mkIf (cfg.agentKey != "") {
      text = configJson;
      mode = "0600";
    };

    systemd.services.vanta-agent = {
      description = "Vanta monitoring software";
      after = [ "network.target" "syslog.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStartPre = [
          "+${setupScript}"
        ] ++ optional (cfg.agentKeyFile != null) "+${writeConfScript}";
        ExecStart = "/var/vanta/metalauncher";
        Restart = "on-failure";
        RestartSec = 10;
        KillMode = "control-group";
        KillSignal = "SIGTERM";
        TimeoutStartSec = 0;
        ReadWritePaths = [ "/var/vanta" ];
      };
    };
  };
}
