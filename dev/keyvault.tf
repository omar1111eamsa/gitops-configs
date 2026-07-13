# Key Vault names must be globally unique across all of Azure, so we
# append a random suffix to avoid collisions with other people's vaults
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

# Auto-generated Postgres password — never typed in plaintext anywhere
resource "random_password" "postgres_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}
