resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
  }

  depends_on = [time_sleep.wait_for_cluster]
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = kubernetes_namespace.external_secrets.metadata[0].name
  version    = "0.9.13"

  timeout       = 300
  wait          = true
  wait_for_jobs = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [kubernetes_namespace.external_secrets]
}
