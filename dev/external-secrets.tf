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


resource "kubectl_manifest" "secret_store" {
  yaml_body = <<-YAML
    apiVersion: external-secrets.io/v1beta1
    kind: SecretStore
    metadata:
      name: azure-keyvault-store
      namespace: 3tirewebapp-dev
    spec:
      provider:
        azurekv:
          authType: ManagedIdentity
          identityId: ${azurerm_kubernetes_cluster.main.kubelet_identity[0].client_id}
          vaultUrl: ${azurerm_key_vault.main.vault_uri}
          tenantId: ${data.azurerm_client_config.current.tenant_id}
  YAML

  depends_on = [
    helm_release.external_secrets,
    azurerm_key_vault_access_policy.aks_kubelet
  ]
}
