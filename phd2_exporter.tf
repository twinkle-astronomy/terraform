

locals {
    config = templatefile("${path.module}/config/config.yaml", {phd2_host: "host.k3d.internal"})
}

resource "kubernetes_config_map" "config_yaml" {
  metadata {
    name      = "config-yaml-${sha1(local.config)}"
    namespace = kubernetes_namespace.astro.metadata.0.name
  }

  data = {
    "config.yaml" = "${local.config}"
  }
}

resource "kubernetes_deployment" "phd2_exporter" {
  metadata {
    name      = "phd2-exporter"
    namespace = kubernetes_namespace.astro.metadata.0.name
  }
  wait_for_rollout = false
  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "phd2-exporter"
      }
    }
    template {
      metadata {
        labels = {
          name = "phd2-exporter"
        }
      }
      spec {

        volume {
          name = "config-yaml"
          config_map {
            name = kubernetes_config_map.config_yaml.metadata.0.name
          }
        }

        container {
          name  = "phd2-exporter"
          image = "ghcr.io/twinkle-astronomy/phd2_exporter:v0.3.0"
          image_pull_policy = "Always"
          command = ["phd2_exporter",
            "/etc/phd2_exporter/config.yaml",
          ]
          env {
            name = "LOG"
            value = "debug"
          }

          volume_mount {
            name       = "config-yaml"
            mount_path = "/etc/phd2_exporter"
          }

          port {
            container_port = 9187
            protocol = "TCP"
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "phd2_exporter" {
  metadata {
    name      = "phd2-exporter"
    namespace = kubernetes_namespace.astro.metadata.0.name
    annotations = {
      prometheus_io_scrape = true
    }
  }
  spec {
    selector = {
      name = "phd2-exporter"
    }
    port {
      port = 9187
      protocol = "TCP"
    }
  }
}


# resource "kubernetes_ingress_v1" "phd2_exporter_ingress" {
#   metadata {
#     name      = "phd2-exporter-ingress"
#     namespace = kubernetes_namespace.astro.metadata.0.name
#     annotations = {
#       # "ingress.kubernetes.io/rewrite-target" = "/metrics",
#     #   "traefik.frontend.rule.type" = "PathPrefix"
#     }
#   }

#   spec {
#     rule {
#       http {
#         path {
#           path = "/"
#           path_type = "Exact"
#           backend {
#             service {
#               name = kubernetes_service.phd2_exporter.metadata.0.name
#               port {
#                 number = 9187
#               }
#             }
#           }
#         }
#       }
#     }
#   }
# }


