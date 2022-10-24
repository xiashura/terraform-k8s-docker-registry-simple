

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




resource "kubernetes_persistent_volume_claim" "test-claim" {
  depends_on = [
    helm_release.nfs-subdir-external-provisioner
  ]
  metadata {
    name      = "test-claim"
    namespace = var.namespace
  }
  spec {
    storage_class_name = var.storage-class-name-nfs
    access_modes = [
      "ReadWriteMany"
    ]
    resources {
      requests = {
        storage = "100Mi"
      }
    }
  }
}


resource "kubernetes_pod" "test-pod" {
  depends_on = [
    kubernetes_persistent_volume_claim.test-claim
  ]

  metadata {
    name      = "test-pod"
    namespace = var.namespace
  }

  spec {
    volume {
      name = "nfs-pvc"

      persistent_volume_claim {
        claim_name = "test-claim"
      }
    }

    container {
      name    = "test-pod"
      image   = "busybox:stable"
      command = ["/bin/sh"]
      args    = ["-c", "touch /mnt/SUCCESS && exit 0 || exit 1"]

      volume_mount {
        name       = "nfs-pvc"
        mount_path = "/mnt"
      }
    }

    restart_policy = "Never"
  }
}
