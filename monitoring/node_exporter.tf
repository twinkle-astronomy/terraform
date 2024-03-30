resource "kubernetes_daemonset" "node_exporter" {
  metadata {
    name      = "node-exporter"
    namespace = kubernetes_namespace.monitoring.metadata.0.name

  }
  wait_for_rollout = false
  spec {
    selector {
      match_labels = {
        name = "node-exporter"
      }
    }
    template {
      metadata {
        labels = {
          name = "node-exporter"
        }
        annotations = {
            prometheus_io_scrape = true
        }
      }
      spec {
        host_network = true
        host_pid = true
        container {
            name = "node-exporter"
            image = "prom/node-exporter"
            port {
                container_port = 9100
                protocol = "TCP"
                }

            args = [
                "--path.sysfs=/host/sys",
                "--path.rootfs=/host/root",
                "--collector.filesystem.ignored-mount-points=^/(dev|proc|sys|var/lib/docker/.+|var/lib/kubelet/pods/.+)($|/)",
                "--collector.netclass.ignored-devices=^(veth.*)$"
            ]
            volume_mount {
                name       = "sys"
                mount_path = "/host/sys"
                mount_propagation = "HostToContainer"
                read_only = true
            }

            volume_mount {
                name       = "root"
                mount_path = "/host/root"
                mount_propagation = "HostToContainer"
                read_only = true
            }
        }
        volume {
            name = "sys"
            host_path {
            path = "/sys"
            }
        }
        volume {
            name = "root"
            host_path {
                path = "/"
            }
        }
      }
    }
  }
}

min(node_cpu_scaling_frequency_min_hertz)
max(node_cpu_scaling_frequency_max_hertz)