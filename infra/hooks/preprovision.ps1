# Load the azd environment variables
$DIR = Split-Path $MyInvocation.MyCommand.Path
& "$DIR\load_azd_env.ps1"


if ([string]::IsNullOrEmpty($env:GITHUB_WORKSPACE)) {  
    # The GITHUB_WORKSPACE is not set, meaning this is not running in a GitHub Action  
    & "$DIR\login.ps1"  
}  
  
# Convert WORKSPACE to lowercase and trim any whitespace  
$WORKSPACE = $env:WORKSPACE.ToLower().Trim()  
  
# Continue with the rest of the script based on WORKSPACE value and FORCE_TERRAFORM_REMOTE_STATE_CREATION condition  
if ($WORKSPACE -eq "default" -and ([string]::IsNullOrEmpty($env:FORCE_TERRAFORM_REMOTE_STATE_CREATION) -or $env:FORCE_TERRAFORM_REMOTE_STATE_CREATION -eq "true")) {  
    # Define the file path  
    $TF_DIR = "infra/tfstate"  
      
    # Set TF_VAR_location to the value of AZURE_LOCATION  
    $env:TF_VAR_location = $env:AZURE_LOCATION  
      
    # Set TF_VAR_environment_name to the value of AZURE_ENV_NAME  
    $env:TF_VAR_environment_name = $env:AZURE_ENV_NAME  
      
    # Initialize and apply Terraform configuration  
    terraform -chdir=$TF_DIR init  
    terraform -chdir=$TF_DIR apply -auto-approve  
      
    # Add a delay to ensure that the service is up and running  
    Write-Output "Waiting for the service to be available..."  
    Start-Sleep -Seconds 30  
      
    # Capture the outputs  
    $RS_STORAGE_ACCOUNT = terraform -chdir=$TF_DIR output -raw RS_STORAGE_ACCOUNT  
    $RS_CONTAINER_NAME = terraform -chdir=$TF_DIR output -raw RS_CONTAINER_NAME  
    $RS_RESOURCE_GROUP = terraform -chdir=$TF_DIR output -raw RS_RESOURCE_GROUP  
      
    # Set the environment variables using the outputs  
    azd env set RS_STORAGE_ACCOUNT $RS_STORAGE_ACCOUNT  
    azd env set RS_CONTAINER_NAME $RS_CONTAINER_NAME  
    azd env set RS_RESOURCE_GROUP $RS_RESOURCE_GROUP  
  
    # Set FORCE_TERRAFORM_REMOTE_STATE_CREATION to false at the end of the block  
    azd env set FORCE_TERRAFORM_REMOTE_STATE_CREATION "false"  
}  
  
# Configure the TF workspace for GH Action runs  
$TF_WORKSPACE_DIR = "$($env:GITHUB_WORKSPACE)/.azure/$env:AZURE_ENV_NAME/infra/.terraform"  
  
# Create the directory if it doesn't exist  
if (-not (Test-Path -Path $TF_WORKSPACE_DIR)) {  
    New-Item -ItemType Directory -Path $TF_WORKSPACE_DIR -Force  
}  
  
# Use the variable with the terraform command  
terraform -chdir=$TF_WORKSPACE_DIR workspace select -or-create $WORKSPACE  
