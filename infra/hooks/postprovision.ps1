azd env get-values > .env  

# Load the azd environment variables
./infra/hooks/load_azd_env.ps1

# Retrieve the internalId of the Cognitive Services account  
$INTERNAL_ID = az cognitiveservices account show `
    --name $env:AZURE_OPENAI_NAME `
    -g $env:AZURE_RESOURCE_GROUP `
    --query "properties.internalId" -o tsv  
  
# Construct the URL  
$COGNITIVE_SERVICE_URL = "https://oai.azure.com/portal/$INTERNAL_ID?tenantid=$env:AZURE_TENANT_ID"  
  
# Display OpenAI Endpoint and other details  
Write-Host "======================================================"  
Write-Host " AI Configuration                 "  
Write-Host "======================================================"  
Write-Host "    OpenAI Endpoint: $env:AZURE_OPENAI_ENDPOINT                    "  
Write-Host "    SKU Name: $env:AZURE_OPENAI_SKU_NAME                             "  
Write-Host "    AI Model Name: $env:AZURE_OPENAI_MODEL_NAME                    "  
Write-Host "    Model Version: $env:AZURE_OPENAI_MODEL_VERSION                    "  
Write-Host "    Model Capacity: $env:AZURE_OPENAI_MODEL_CAPACITY                "  
Write-Host "    Azure Portal Link:                                 "  
Write-Host "    https://ms.portal.azure.com/#@microsoft.onmicrosoft.com/resource/subscriptions/$env:AZURE_SUBSCRIPTION_ID/resourceGroups/$env:AZURE_RESOURCE_GROUP/providers/Microsoft.CognitiveServices/accounts/$env:AZURE_OPENAI_NAME/overview"  
Write-Host "    Azure OpenAI Studio: $COGNITIVE_SERVICE_URL    "  
Write-Host ""  
Write-Host "======================================================"  
Write-Host " AI Test                 "  
Write-Host "======================================================"  
Write-Host " You can run the following to test the AI Service: "  
Write-Host "      ./tests/test-ai.sh"  
Write-Host ""  
Write-Host "======================================================"  
Write-Host " AI Key                 "  
Write-Host "======================================================"  
Write-Host " The Azure OpenAI Key is stored in the .env file in the root of this repo.  "  
Write-Host ""  
Write-Host " You can also find the key by running this following command: "  
Write-Host ""  
Write-Host "    azd env get-values"  
Write-Host ""  
Write-Host "======================================================"  
Write-Host " Run Locally with F5                 "  
Write-Host "======================================================"  
Write-Host " If you are using VS Code, then you can run the application locally by pressing F5."  
Write-Host " Once you do so, the application will be running here: http://localhost:3000"  
