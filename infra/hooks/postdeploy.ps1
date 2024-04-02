# Load the azd environment variables
./infra/hooks/load_azd_env.ps1

# Convert WORKSPACE to lowercase and trim any whitespace  
$WORKSPACE = $env:WORKSPACE.ToLower().Trim()  
  
# Check if WORKSPACE is set to "azure"  
if ($WORKSPACE -eq "azure") {  
    # Add a delay to ensure that the service is up and running  
    Write-Host "Waiting for the service to be available..."  
    Start-Sleep -Seconds 30  
      
    # Check if AZD_PIPELINE_CONFIG_PROMPT is not set or is true  
    if ([string]::IsNullOrEmpty($env:AZD_PIPELINE_CONFIG_PROMPT) -or $env:AZD_PIPELINE_CONFIG_PROMPT -eq "true") {  
          
        Write-Host "======================================================"  
        Write-Host "                     Github Action Setup                 "  
        Write-Host "======================================================"  
          
        # Ask the user a question and get their response  
        $response = Read-Host "Do you want to configure a GitHub action to automatically deploy this repo to Azure when you push code changes? (Y/n) "  
  
        # Default response is "Y"  
        if([string]::IsNullOrEmpty($response)) { $response = "Y" }  
  
        # Check the response  
        if ($response -match "^[Yy]$") {  
            Write-Host "Configuring GitHub Action..."  
            azd auth login --scope https://graph.microsoft.com/.default  
            azd pipeline config  
            # Set AZD_GH_ACTION_PROMPT to false  
            azd env set AZD_PIPELINE_CONFIG_PROMPT false  
        }  
    }  
  
    Write-Host "Retrieving the external IP address of the service"  
    Write-Host "======================================================"  
    Write-Host " Website IP Address                 "  
    Write-Host "======================================================"  
    $WEB_IP = kubectl get ingress ingress-web -o jsonpath='{.status.loadBalancer.ingress[0].ip}'  
    Write-Host "WEB IP: http://$WEB_IP"  
}  
