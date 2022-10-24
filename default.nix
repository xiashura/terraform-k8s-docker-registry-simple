
with (import <nixpkgs> {});

stdenv.mkDerivation {

  KUBECONFIG = "config.yml";
  
  name = "terraform-k8s-docker-registry-simple";
  buildInputs = [
    kubectl
    terraform
    kubernetes-helm-wrapped
    cilium-cli
    kind
  ];
}