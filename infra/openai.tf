resource "azurecaf_name" "cog_name" {
  name          = local.resource_token
  resource_type = "azurerm_cognitive_account"
  random_length = 0
  clean_input   = true
}

resource "azurerm_cognitive_account" "cog" {
  name                  = azurecaf_name.cog_name.result
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  kind                  = "OpenAI"
  sku_name              = var.openai_sku_name
  custom_subdomain_name = azurecaf_name.cog_name.result
  tags                  = azurerm_resource_group.rg.tags
}

resource "azurerm_cognitive_deployment" "deployment" {
  name                 = var.openai_model_name
  cognitive_account_id = azurerm_cognitive_account.cog.id

  model {
    format  = "OpenAI"
    name    = var.openai_model_name
    version = var.openai_model_version
  }

  scale {
    type     = "Standard"
    capacity = var.openai_model_capacity
  }
}

resource "azurerm_cognitive_deployment" "embeddings_deployment" {
  name                 = var.openai_embeddings_model_name
  cognitive_account_id = azurerm_cognitive_account.cog.id

  model {
    format  = "OpenAI"
    name    = var.openai_embeddings_model_name
    version = var.openai_embeddings_model_version
  }

  scale {
    type     = "Standard"
    capacity = var.openai_embeddings_model_capacity
  }
}
