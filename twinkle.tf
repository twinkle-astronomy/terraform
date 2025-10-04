resource "kubernetes_deployment" "twinkle" {
  metadata {
    name      = "twinkle"
    namespace = kubernetes_namespace.astro.metadata.0.name
  }
  wait_for_rollout = false
  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "twinkle"
      }
    }
    template {
      metadata {
        labels = {
          name = "twinkle"
        }
      }
      spec {
        container {
          name              = "twinkle"
          image             = "ghcr.io/twinkle-astronomy/twinkle:v0.0.12"
          image_pull_policy = "IfNotPresent"
          command = ["/app/server"]
          
          port {
            container_port = 4000
            protocol       = "TCP"
          }
          volume_mount {
            name = "indi-control"
            mount_path = "/indi"
          }
          volume_mount {
            name = "storage"
            mount_path = "/storage"
          }
        }

        volume {
            name = "indi-control"
            host_path {
              path = "/indi"
            }
        }

        volume {
          name = "storage"
          host_path {
            path = "/home/cconstantine/AstroDMx_DATA/twinkle/"
            type = "DirectoryOrCreate"
          }
        }
      }
    }
  }
  
}


resource "kubernetes_service" "twinkle" {
  metadata {
    name      = "twinkle"
    namespace = kubernetes_namespace.astro.metadata.0.name
  }
  spec {
    selector = {
      name = "twinkle"
    }
    port {
      port = 4000
      target_port = 4000
      node_port = 30000
    }
    type = "NodePort"
  }
}



