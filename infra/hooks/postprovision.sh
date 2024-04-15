#!/bin/bash

# Load the azd environment variables
DIR=$(dirname "$(realpath "$0")")
"$DIR/load_azd_env.sh"

azd env get-values > .env

# Retrieve the internalId of the Cognitive Services account
INTERNAL_ID=$(az cognitiveservices account show \
    --name ${AZURE_OPENAI_NAME} \
    -g ${AZURE_RESOURCE_GROUP} \
--query "properties.internalId" -o tsv)

# Construct the URL
COGNITIVE_SERVICE_URL="https://oai.azure.com/portal/${INTERNAL_ID}?tenantid=${AZURE_TENANT_ID}"

# Display OpenAI Endpoint and other details
echo "======================================================"
echo " AI Configuration                 "
echo "======================================================"
echo "    OpenAI Endpoint: ${AZURE_OPENAI_ENDPOINT}                    "
echo "    SKU Name: ${AZURE_OPENAI_SKU_NAME}                             "
echo "    AI Model Name: ${AZURE_OPENAI_MODEL_NAME}                    "
echo "    Model Version: ${AZURE_OPENAI_MODEL_VERSION}                    "
echo "    Model Capacity: ${AZURE_OPENAI_MODEL_CAPACITY}                "
echo "    Azure Portal Link:                                 "
echo "    https://ms.portal.azure.com/#@microsoft.onmicrosoft.com/resource/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_RESOURCE_GROUP}/providers/Microsoft.CognitiveServices/accounts/${AZURE_OPENAI_NAME}/overview"
echo "    Azure OpenAI Studio: ${COGNITIVE_SERVICE_URL}    "
echo ""
echo "======================================================"
echo " AI Test                 "
echo "======================================================"
echo " You can run the following to test the AI Service: "
echo "      ./tests/test-ai.sh"
echo ""
echo "======================================================"
echo " AI Key                 "
echo "======================================================"
echo " The Azure OpenAI Key is stored in the .env file in the root of this repo.  "
echo ""
echo " You can also find the key by running this following command: "
echo ""
echo "    azd env get-values"
echo ""
echo "======================================================"
echo " Run Locally with F5                 "
echo "======================================================"
echo " If you are using VS Code, then you can run the application locally by pressing F5."
echo " Once you do so, the application will be running here: http://localhost:3000"

