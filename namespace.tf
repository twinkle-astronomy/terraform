resource "kubernetes_namespace" "astro" {
  metadata {
    name = "astro"
  }
}
