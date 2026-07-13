resource "kubernetes_namespace" "app" {
  metadata {
    name = "3tirewebapp-dev"
    labels = {
      app = "3tirewebapp"
    }
  }

  depends_on = [time_sleep.wait_for_cluster]
}


resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      "app.kubernetes.io/name" = "argocd"
    }
  }

  depends_on = [time_sleep.wait_for_cluster]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "6.7.3"

  timeout       = 600
  wait          = true
  wait_for_jobs = true

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "configs.params.server\\.insecure"
    value = "true"
  }

  depends_on = [kubernetes_namespace.argocd]
}
