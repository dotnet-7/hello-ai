# AZD LOGIN

# Load the azd environment variables
$DIR = Split-Path $MyInvocation.MyCommand.Path
& "$DIR\load_azd_env.ps1"

# Initialize IS_BROWSER variable to false  
$IS_BROWSER = $false  
  
# Check if 'code' command exists  
if (Get-Command 'code' -ErrorAction SilentlyContinue) {  
    # Run 'code -s' and capture the output  
    $output = code -s 2>&1  
  
    # Check if the output indicates it's running in a browser  
    if ($output -like "*The --status argument is not yet supported in browsers.*") {  
        $IS_BROWSER = $true  
    }  
}  
  
# Check if IS_BROWSER is true and CODESPACE_NAME is set  
if ($IS_BROWSER -eq $true -and [string]::IsNullOrEmpty($env:CODESPACE_NAME) -eq $false) {  
    # Construct the URL with CODESPACE_NAME  
    $url = "https://github.com/codespaces/$env:CODESPACE_NAME?editor=vscode"  
  
    # Display the security policy explanation message and the URL  
    Write-Output "Due to security policies that prevent authenticating with Azure and Microsoft accounts directly from the browser, you are required to open this project in Visual Studio Code Desktop. This restriction is in place to ensure the security of your account details and to comply with best practices for authentication workflows. Please use the following link to proceed with opening your Codespace in Visual Studio Code Desktop:"  
    Write-Output $url  
    exit  
}  
  
# AZD LOGIN  
Write-Output "Checking Azure Developer CLI (azd) login status..."  
  
# Check if the user is logged in to Azure  
$login_status = azd auth login --check-status  
  
# Check if the user is not logged in  
if ($login_status -like "*Not logged in*") {  
    Write-Output "Not logged in to the Azure Developer CLI, initiating login process..."  
    # Command to log in to Azure  
    azd auth login  
} else {  
    Write-Output "Already logged in to Azure Developer CLI."  
}  
  
Write-Output "Checking Azure (az) CLI login status..."  
  
# AZ LOGIN  
$EXPIRED_TOKEN = az ad signed-in-user show --query 'id' -o tsv 2>$null  
  
if ([string]::IsNullOrEmpty($EXPIRED_TOKEN)) {  
    Write-Output "Not logged in to Azure, initiating login process..."  
    az login --scope https://graph.microsoft.com/.default -o none  
} else {  
    Write-Output "Already logged in to the Azure (az) CLI."  
}  
  
# Check if AZURE_SUBSCRIPTION_ID is set  
if ([string]::IsNullOrEmpty($env:AZURE_SUBSCRIPTION_ID)) {  
    $ACCOUNT = az account show --query '[id,name]'  
    Write-Output "No Azure subscription ID set."  
    Write-Output "You can set the `AZURE_SUBSCRIPTION_ID` environment variable with `azd env set AZURE_SUBSCRIPTION_ID`."  
    Write-Output "Current subscription:"  
    Write-Output $ACCOUNT  
  
    $response = Read-Host -Prompt "Do you want to use the above subscription? (Y/n)"  
    $response = if([string]::IsNullOrEmpty($response)){"Y"}else{$response}  
    switch ($response) {  
        {$_ -match "^[Yy](ES)?$"} {  
            Write-Output "Using the selected subscription."  
            break  
        }  
        default {  
            Write-Output "Listing available subscriptions..."  
            $SUBSCRIPTIONS = az account list --query 'sort_by([], &name)' --output json  
            Write-Output "Available subscriptions:"  
            Write-Output $SUBSCRIPTIONS | ConvertFrom-Json | Format-Table -AutoSize  
  
            $subscription_input = Read-Host -Prompt "Enter the name or ID of the subscription you want to use"  
            $AZURE_SUBSCRIPTION_ID = $SUBSCRIPTIONS | ConvertFrom-Json | Where-Object {($_.name -eq $subscription_input) -or ($_.id -eq $subscription_input)} | Select-Object -ExpandProperty id  
            if ([string]::IsNullOrEmpty($AZURE_SUBSCRIPTION_ID) -eq $false) {  
                Write-Output "Setting active subscription to: $AZURE_SUBSCRIPTION_ID"  
                az account set -s $AZURE_SUBSCRIPTION_ID  
            } else {  
                Write-Output "Subscription not found. Please enter a valid subscription name or ID."  
                exit 1  
            }  
            break  
        }  
    }  
} else {  
    Write-Output "Azure subscription ID is already set."  
    az account set -s $env:AZURE_SUBSCRIPTION_ID  
}  