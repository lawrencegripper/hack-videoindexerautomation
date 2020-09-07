variable resource_group_name {
  default = "vimoduletest1"
}
variable resource_group_location {
  default = "northeurope"
}
variable vi_api_key {
  description = "The API key for accessing the VI API. Docs on how to obtain here: https://docs.microsoft.com/en-us/azure/media-services/video-indexer/video-indexer-use-apis#subscribe-to-the-api"
}

resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
  number  = false
}

resource "azurerm_resource_group" "env" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

# Create a media services instance

resource "azurerm_storage_account" "media_storage" {
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.env.name

  account_tier             = "Standard"
  account_replication_type = "LRS"
  name                     = "mediastor${random_string.random.result}"
}

resource "azurerm_media_services_account" "media" {
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.env.name

  name = "mediastor${random_string.random.result}"
  storage_account {
    id         = azurerm_storage_account.media_storage.id
    is_primary = true
  }
}

# Create the VI SP used by Video indexer to talk to Media services
resource "azuread_application" "vi" {
  name                       = "${random_string.random.result}vi"
  identifier_uris            = ["http://${random_string.random.result}vi"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true

}

resource "azuread_service_principal" "vi" {
  application_id               = azuread_application.vi.application_id
  app_role_assignment_required = false
}

resource "random_string" "pw" {
  length = 24
}

resource "azuread_service_principal_password" "vi" {
  service_principal_id = azuread_service_principal.vi.id
  value                = random_string.pw.result
  # Review best way forward with this setting
  end_date = "2050-01-01T01:02:03Z"
}

resource "azurerm_role_assignment" "vi_mediaservices_access" {
  scope                = azurerm_resource_group.env.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.vi.object_id
}

# Create the VI instance via the VI API
data "azurerm_client_config" "current" {
}

resource "shell_script" "videoindexer_account" {
  depends_on = [azurerm_role_assignment.vi_mediaservices_access]

  lifecycle_commands {
    create = "pwsh ${path.module}/scripts/videoindexer.ps1 -type create"
    read   = "pwsh ${path.module}/scripts/videoindexer.ps1 -type read"
    update = "pwsh ${path.module}/scripts/videoindexer.ps1 -type update"
    delete = "pwsh ${path.module}/scripts/videoindexer.ps1 -type delete"
  }

  environment = {
    debug_log = true
    LOCATION  = var.resource_group_location
    API_KEY   = var.vi_api_key
    CREATE_JSON = jsonencode(jsondecode(<<JSON
      {
        "subscriptionId": "${data.azurerm_client_config.current.subscription_id}",
        "resourceGroup": "${azurerm_resource_group.env.name}",
        "resource": "${azurerm_media_services_account.media.name}",
        "aadTenantId": "${data.azurerm_client_config.current.tenant_id}",
        "aadConnection": {
          "applicationId": "${azuread_application.vi.application_id}",
          "applicationKey": "${azuread_service_principal_password.vi.value}"
        },
        "autoScale": true
      }
JSON
    ))
  }
}
