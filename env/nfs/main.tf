

resource "kubernetes_namespace" "simple-nfs" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "nfs-subdir-external-provisioner" {

  depends_on = [
    kubernetes_namespace.simple-nfs
  ]

  name       = "nfs-subdir-external-provisioner"
  repository = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner"
  chart      = "nfs-subdir-external-provisioner"
  version    = "4.0.17"

  namespace = var.namespace

  set {
    name  = "nfs.server"
    value = var.host-nfs
  }

  set {
    name  = "nfs.path"
    value = var.path-nfs
  }

  set {
    name  = "nfs.mountOptions[0]"
    value = "nfsvers=3"
  }

  set {
    name  = "storageClass.name"
    value = var.storage-class-name-nfs
  }


}

module "docker-regisry" {
  source = "../../modules/docker-registry"

  namespace          = var.namespace
  secret-path-cert   = "../../certs/registry.crt"
  secret-path-key    = "../../certs/registry.key"
  storage-class-name = var.storage-class-name-nfs
}



