
# Load the azd environment variables
$DIR = Split-Path $MyInvocation.MyCommand.Path
& "$DIR\load_azd_env.ps1"

# Convert WORKSPACE to lowercase and trim any whitespace  
$WORKSPACE = $env:WORKSPACE.ToLower().Trim()  
  
# Check if WORKSPACE is set to "azure"  
if ($WORKSPACE -eq "azure") {  
    # Add a delay to ensure that the service is up and running  
    Write-Output "Waiting for the service to be available..."  
    Start-Sleep -Seconds 30  
  
    # Check if AZD_PIPELINE_CONFIG_PROMPT is not set or is true  
    if ([string]::IsNullOrEmpty($env:AZD_PIPELINE_CONFIG_PROMPT) -or $env:AZD_PIPELINE_CONFIG_PROMPT -eq "true") {  
        Write-Output "======================================================"  
        Write-Output "                     Github Action Setup                 "  
        Write-Output "======================================================"  
  
        # Ask the user a question and get their response  
        $response = Read-Host -Prompt "Do you want to configure a GitHub action to automatically deploy this repo to Azure when you push code changes? (Y/n)"  
  
        # Default response is "Y"  
        $response = if([string]::IsNullOrEmpty($response)){"Y"}else{$response}  
  
        # Check the response  
        if ($response -match "^[Yy]$") {  
            Write-Output "Configuring GitHub Action..."  
            azd auth login --scope https://graph.microsoft.com/.default  
            azd pipeline config  
            # Set AZD_GH_ACTION_PROMPT to false  
            azd env set AZD_PIPELINE_CONFIG_PROMPT false  
        }  
    }  
  
    Write-Output "Retrieving the external IP address of the service"  
    Write-Output "======================================================"  
    Write-Output " Website IP Address                 "  
    Write-Output "======================================================"  
    $WEB_IP = kubectl get ingress ingress-web -o jsonpath='{.status.loadBalancer.ingress[0].ip}'  
    Write-Output "WEB IP: http://$WEB_IP"  
}  