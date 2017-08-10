with (import ./../lib.nix);

{ config, pkgs, resources, ... }: {
  imports = [
    ./common.nix
  ];

  # DEVOPS-64: disable log bursting
  services.journald.rateLimitBurst = 0;

  services.cardano-node = {
    saveCoreDumps = true;
  };

  deployment.ec2.elasticIPv4 = resources.elasticIPs.${toString config.services.cardano-node.nodeName + "-ip"};
}