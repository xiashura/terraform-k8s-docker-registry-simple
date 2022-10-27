
with (import <nixpkgs> {});
let
  init-clusters = pkgs.writeShellScriptBin "init-clusters" ''
    kind create cluster --config=./kind.yml 
    kind get kubeconfig --name docker-registry-simple > config.yml 
    kubectl create ns tigera-operator
    helm repo add projectcalico https://projectcalico.docs.tigera.io/charts 
    helm install calico projectcalico/tigera-operator --version v3.24.3 --namespace tigera-operator
  '';

  destroy-clusters = pkgs.writeShellScriptBin "destroy-clusters" ''
    kind delete clusters docker-registry-simple
  '';

  init-certs-docker-registry = pkgs.writeShellScriptBin "init-certs-docker-registry" ''
    openssl req \
      -newkey rsa:4096 -nodes -sha256 -keyout certs/registry.key \
      -addext "subjectAltName = DNS:localhost" \
      -x509 -days 365 -out certs/registry.crt
  '';

  start-nfs-server-docker = pkgs.writeShellScriptBin "start-nfs-server-docker" ''
  docker run                                            \
    -v $PWD/nfs_server/data:/data  \
    -v $PWD/nfs_server/exports.txt:/etc/exports:ro        \
    --cap-add SYS_ADMIN                                 \
    -p 2049:2049                                        \
    --network kind                                   \
    --name nfs-server                                   \
    -d                                   \
    erichough/nfs-server
  docker container inspect -f '{{ .NetworkSettings.Networks.kind.IPAddress }}' nfs-server
  '';


in 
stdenv.mkDerivation {

  KUBECONFIG = "./config.yml";
  
  name = "terraform-k8s-docker-registry-simple";
  buildInputs = [
    kubectl
    terraform
    kubernetes-helm-wrapped
    kind
    k2tf
    init-clusters
    start-nfs-server-docker
    openssl
    destroy-clusters
    init-certs-docker-registry
  ];
}