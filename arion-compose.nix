{
  services.agent = { ... }: {
    imports = [ ./service-agent.nix ];
    # A directory containing secrets (non-standard option declared in service-agent.nix)
    # See also the secrets copying script in service-agent.nix
    params.hostSecretsDirectory = "/var/lib/keys/agent-in-arion-secrets";
    nixos.configuration = {...}: {
      imports = [
        # If you want to pick your own version instead of Nixpkgs:
        #   (inputs.hercules-ci-agent.nixosModules.agent-profile)
        # or
        #   (inputs.hercules-ci-agent.nixosModules.agent-service)
      ];
      # Hercules CI Enterprise:
      # services.hercules-ci-agent.settings.apiBaseUrl = "https://...";
    };
    # Root file system (incl nix store) size, if supported by your storage backend
    out.service.storage_opt.size = "512G";
  };
}

