resource "kubernetes_secret" "docker-registry-certs" {

  metadata {
    name      = "docker-registry-certs"
    namespace = var.namespace
  }
  data = {
    "tls.crt" = "${file(var.secret-path-cert)}"
    "tls.key" = "${file(var.secret-path-key)}"
  }

  type = "kubernetes.io/tls"
}



resource "kubernetes_persistent_volume_claim" "docker-registry-claim" {

  metadata {
    name      = var.docker-registry-claim-name
    namespace = var.namespace
  }
  spec {
    storage_class_name = var.storage-class-name
    access_modes = [
      "ReadWriteMany"
    ]
    resources {
      requests = {
        storage = "500Mi"
      }
    }
  }
}

resource "kubernetes_deployment" "registry" {

  depends_on = [
    kubernetes_persistent_volume_claim.docker-registry-claim,
    kubernetes_secret.docker-registry-certs
  ]

  metadata {
    name = "registry"

    namespace = var.namespace


    labels = {
      run = "registry"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        run = "registry"
      }
    }

    template {
      metadata {
        labels = {
          run = "registry"
        }
      }

      spec {
        volume {
          name = "registry-certs"

          secret {
            secret_name = "docker-registry-certs"
          }
        }

        volume {
          name = "registry-data"

          persistent_volume_claim {
            claim_name = var.docker-registry-claim-name
          }
        }

        container {
          name  = "registry"
          image = "registry:2"

          port {
            container_port = 5000
          }

          env {
            name  = "REGISTRY_HTTP_TLS_CERTIFICATE"
            value = "/certs/tls.crt"
          }

          env {
            name  = "REGISTRY_HTTP_TLS_KEY"
            value = "/certs/tls.key"
          }

          volume_mount {
            name       = "registry-certs"
            read_only  = true
            mount_path = "/certs"
          }

          volume_mount {
            name       = "registry-data"
            mount_path = "/var/lib/registry"
            sub_path   = "registry"
          }
        }

      }
    }
  }
}


resource "kubernetes_service" "registry_service" {
  metadata {
    name      = "registry-service"
    namespace = var.namespace
  }

  spec {
    port {
      name        = "registry-tcp"
      protocol    = "TCP"
      port        = 5000
      target_port = "5000"
    }

    selector = {
      run = "registry"
    }

    type = "ClusterIP"
  }
}
