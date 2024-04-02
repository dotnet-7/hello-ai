# Load the azd environment variables
./infra/hooks/load_azd_env.ps1

if ([string]::IsNullOrEmpty($env:GITHUB_WORKSPACE)) {
    # The GITHUB_WORKSPACE is not set, meaning this is not running in a GitHub Action
    $DIR = Split-Path $MyInvocation.MyCommand.Path
    & "$DIR\login.ps1"
}
