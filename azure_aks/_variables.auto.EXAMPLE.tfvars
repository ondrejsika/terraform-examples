# az login
# az account list
# # Switch to the SikaLabs TRAINING subscription
# az account set --subscription 200acaec-2d60-43ad-915a-e8f5352a4ba7
# # Create a Service Principal for subscription SikaLabs TRAINING
# az ad sp create-for-rbac --role="Contributor" --scopes /subscriptions/200acaec-2d60-43ad-915a-e8f5352a4ba7

azurerm_tenant_id       = "xxx"
azurerm_subscription_id = "xxx"
azurerm_client_id       = "xxx"
azurerm_client_secret   = "xxx"
