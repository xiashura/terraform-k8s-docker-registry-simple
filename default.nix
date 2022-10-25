
with (import <nixpkgs> {});
let
  init-clusters = pkgs.writeShellScriptBin "init-clusters" ''
    kind create clusters --config=./kind.yml \\
    helm repo add projectcalico https://projectcalico.docs.tigera.io/charts \\
    helm install calico projectcalico/tigera-operator --version v3.24.3 --namespace tigera-operator
  '';

  start-nfs-server-docker = pkgs.writeShellScriptBin "start-nfs-server-docker" ''
    export PWD=$PWD/nfs-server
    bash ./nfs-server/nfs-server.sh
    docker container inspect -f '{{ .NetworkSettings.Networks.kind.IPAddress }}'
  '';


in 
stdenv.mkDerivation {

  KUBECONFIG = "config.yml";
  
  name = "terraform-k8s-docker-registry-simple";
  buildInputs = [
    kubectl
    terraform
    kubernetes-helm-wrapped
    kind
    k2tf
    init-clusters
    start-nfs-server-docker
  ];
}