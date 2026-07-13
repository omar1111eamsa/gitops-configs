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
    azurerm_key_vault_access_policy.aks_kubelet,
    kubernetes_namespace.app
  ]
}

resource "kubectl_manifest" "postgres_external_secret" {
  yaml_body = <<-YAML
    apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      name: postgres-credentials
      namespace: 3tirewebapp-dev
    spec:
      refreshInterval: 1h
      secretStoreRef:
        name: azure-keyvault-store
        kind: SecretStore
      target:
        name: postgres-credentials-from-kv
        creationPolicy: Owner
      data:
        - secretKey: POSTGRES_USER
          remoteRef:
            key: postgres-username
        - secretKey: POSTGRES_PASSWORD
          remoteRef:
            key: postgres-password
        - secretKey: POSTGRES_DB
          remoteRef:
            key: postgres-database
  YAML

  depends_on = [
    kubectl_manifest.secret_store,
    azurerm_key_vault_secret.postgres_username,
    azurerm_key_vault_secret.postgres_password,
    azurerm_key_vault_secret.postgres_database,
    kubernetes_namespace.app
  ]
}
