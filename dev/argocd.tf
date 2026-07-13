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

resource "kubectl_manifest" "app" {
  yaml_body = <<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: 3tierwebapp-dev
      namespace: argocd
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      project: default
      source:
        repoURL: ${var.gitops_repo_url}
        targetRevision: HEAD
        path: ${var.gitops_repo_path}
      destination:
        server: https://kubernetes.default.svc
        namespace: 3tirewebapp-dev
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=false
        retry:
          limit: 5
          backoff:
            duration: 5s
            factor: 2
            maxDuration: 3m
  YAML

  depends_on = [
    helm_release.argocd,
    kubernetes_namespace.app
  ]
}
