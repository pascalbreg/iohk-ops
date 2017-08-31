{ accessKeyId, deployerIP, systemStart, environment, ... }:

with (import ./../lib.nix);
let
  nodeArgs = (import ./cardano-nodes-config.nix { inherit accessKeyId deployerIP systemStart  environment; }).nodeArgs;
  nodeConf = import ./../modules/cardano-node-development.nix;
in {
  resources = rec {
    elasticIPs = mkNodeIPs nodeArgs accessKeyId;
  };
} // (mkNodesUsing (params: nodeConf) nodeArgs)