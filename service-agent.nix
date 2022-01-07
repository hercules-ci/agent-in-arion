{ pkgs, config, lib, ... }:

{
  imports = [ ./service-nix-daemon.nix ];

  options = {
    params.hostSecretsDirectory = lib.mkOption {
      type = lib.types.str;
      description = "Where to find secrets on the host filesystem.";
    };
  };

  config = {
    service.restart = "always";
    nixos.useSystemd = true;
    # Make Podman recognize systemd for special treatment
    image.contents = [
      (pkgs.runCommand "root" {} ''
        mkdir -p $out/usr/sbin
        ln -s ${config.nixos.build.toplevel}/init $out/usr/sbin/init
      '')
    ];
    image.command = lib.mkForce [ "/usr/sbin/init" ];

    nixos.configuration = { pkgs, lib, config, ... }: {
      imports = [
        ./optimize.nix
      ];

      systemd.services.install-secrets = {
        enable = true;
        before = [ "hercules-ci-agent.service" ];
        wantedBy = [ "hercules-ci-agent.service" ];
        # TODO: deploy to the default paths (finalConfig)
        script = ''
          install --directory \
                  --owner hercules-ci-agent \
                  --group nogroup \
                  --mode 0700 \
                  /var/lib/hercules-ci-agent/secrets \
                  ;
          install --mode 0400 \
                  --owner hercules-ci-agent \
                  /secrets/agent-token.key \
                  /var/lib/hercules-ci-agent/secrets/cluster-join-token.key \
                  ;
          install --mode 0400 \
                  --owner hercules-ci-agent \
                  /secrets/binary-caches.json.key \
                  /var/lib/hercules-ci-agent/secrets/binary-caches.json \
                  ;
          install --mode 0400 \
                  --owner hercules-ci-agent \
                  /secrets/secrets.json.key \
                  /var/lib/hercules-ci-agent/secrets/secrets.json \
                  ;

          # AWS for S3 cache credentials (nix-daemon, agent)
          install --mode 0400 \
                  --owner root \
                  -D \
                  /secrets/aws-credentials \
                  /root/.aws/credentials \
                  ;
          install --mode 0400 \
                  --owner hercules-ci-agent \
                  -D \
                  /secrets/aws-credentials \
                  /var/lib/hercules-ci-agent/.aws/credentials \
                  ;
          chown hercules-ci-agent /var/lib/hercules-ci-agent/.aws
        '';
        serviceConfig.Type = "oneshot";
      };

      services.hercules-ci-agent.enable = true;
      # services.hercules-ci-agent.settings.concurrentTasks = 3;

    };
    service.volumes = lib.mkForce [
      "${config.params.hostSecretsDirectory}:/secrets"
      # {
      #   type = "tmpfs";
      #   target = "/run";
      #   tmpfs.size = 256 * 1024 * 1024; # bytes
      # }
    ];
  };

}