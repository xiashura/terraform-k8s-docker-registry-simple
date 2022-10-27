
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.7.0"
    }
  }
}

provider "kubernetes" {

  config_path    = "../../config.yml"
  config_context = "kind-docker-registry-simple"
}


provider "helm" {
  kubernetes {
    config_path = "../../config.yml"
  }
}

