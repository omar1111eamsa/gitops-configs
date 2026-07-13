resource "kubernetes_namespace" "app" {
  metadata {
    name = "3tirewebapp-dev"
    labels = {
      app = "3tirewebapp"
    }
  }

  depends_on = [time_sleep.wait_for_cluster]
}
