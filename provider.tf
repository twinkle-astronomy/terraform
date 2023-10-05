terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
  backend "kubernetes" {
    secret_suffix = "state"
    # config_path   = ".kubeconfig"
  }

}

provider "kubernetes" {
#   config_path   = ".kubeconfig"
  config_context = "default"
}
