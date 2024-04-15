# Load the azd environment variables
$DIR = Split-Path $MyInvocation.MyCommand.Path
& "$DIR\load_azd_env.ps1"

azd env get-values | Out-File -FilePath .env  
  
# Retrieve the internalId of the Cognitive Services account  
$INTERNAL_ID = az cognitiveservices account show `
    --name $env:AZURE_OPENAI_NAME `
    -g $env:AZURE_RESOURCE_GROUP `
--query "properties.internalId" -o tsv  
  
# Construct the URL  
$COGNITIVE_SERVICE_URL = "https://oai.azure.com/portal/$INTERNAL_ID?tenantid=$env:AZURE_TENANT_ID"  
  
# Display OpenAI Endpoint and other details  
Write-Output "======================================================"  
Write-Output " AI Configuration                 "  
Write-Output "======================================================"  
Write-Output "    OpenAI Endpoint: $env:AZURE_OPENAI_ENDPOINT                    "  
Write-Output "    SKU Name: $env:AZURE_OPENAI_SKU_NAME                             "  
Write-Output "    AI Model Name: $env:AZURE_OPENAI_MODEL_NAME                    "  
Write-Output "    Model Version: $env:AZURE_OPENAI_MODEL_VERSION                    "  
Write-Output "    Model Capacity: $env:AZURE_OPENAI_MODEL_CAPACITY                "  
Write-Output "    Azure Portal Link:                                 "  
Write-Output "    https://ms.portal.azure.com/#@microsoft.onmicrosoft.com/resource/subscriptions/$env:AZURE_SUBSCRIPTION_ID/resourceGroups/$env:AZURE_RESOURCE_GROUP/providers/Microsoft.CognitiveServices/accounts/$env:AZURE_OPENAI_NAME/overview"  
Write-Output "    Azure OpenAI Studio: $COGNITIVE_SERVICE_URL    "  
Write-Output ""  
Write-Output "======================================================"  
Write-Output " AI Test                 "  
Write-Output "======================================================"  
Write-Output " You can run the following to test the AI Service: "  
Write-Output "      ./tests/test-ai.sh"  
Write-Output ""  
Write-Output "======================================================"  
Write-Output " AI Key                 "  
Write-Output "======================================================"  
Write-Output " The Azure OpenAI Key is stored in the .env file in the root of this repo.  "  
Write-Output ""  
Write-Output " You can also find the key by running this following command: "  
Write-Output ""  
Write-Output "    azd env get-values"  
Write-Output ""  
Write-Output "======================================================"  
Write-Output " Run Locally with F5                 "  
Write-Output "======================================================"  
Write-Output " If you are using VS Code, then you can run the application locally by pressing F5."  
Write-Output " Once you do so, the application will be running here: http://localhost:3000"  