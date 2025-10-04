


resource "kubernetes_stateful_set" "indi_server" {
  metadata {
    name      = "indi-server"
    namespace = kubernetes_namespace.astro.metadata.0.name
  }
  wait_for_rollout = false
  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "indi-server"
      }
    }
    service_name = kubernetes_service.indi_server.metadata.0.name

    template {
      metadata {
        labels = {
          name = "indi-server"
        }
      }
      spec {
        host_network = true
        container {
          name  = "indi-server"
          image = "ghcr.io/twinkle-astronomy/indi_server:v2.1.4-202506011144"
          security_context {
            privileged = true
          }

          image_pull_policy = "IfNotPresent"
          # image_pull_policy = "Always"
          command = ["indiserver",
            "-v",
            "-f", "/indi/control.fifo",
            "-m", "1024",
            "-r", "0",
            "-d", "1024",
            "indi_eqmod_telescope",
            "indi_asi_ccd",
            "indi_asi_wheel",
            "indi_asi_focuser",
            #"indi_deepskydad_fp",  #indi_deepskydad_af1_focus  indi_deepskydad_af2_focus  indi_deepskydad_af3_focus  indi_deepskydad_fp         indi_deepskydad_fr1        
          ]
          volume_mount {
            name = "indi-control"
            mount_path = "/indi"
          }
          volume_mount {
            name       = "root-home"
            mount_path = "/root"
          }
          port {
            container_port = 7624
            protocol       = "TCP"
          }
        }

        volume {
            name = "indi-control"
            host_path {
              path = "/indi"
            }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "root-home"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "100Mi"
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "indi_server" {
  metadata {
    name      = "indi-server"
    namespace = kubernetes_namespace.astro.metadata.0.name
    annotations = {
      prometheus_io_scrape = true
    }
  }
  spec {
    selector = {
      name = "indi-server"
    }
    port {
      port = 7624
    }
  }
}
