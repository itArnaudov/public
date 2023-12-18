#This script iterates through all resource groups in the subscription and checks each resource within those groups for the presence of the specified tag. Resources without the specified tag are then listed at the end. Remember to replace "YourTagKey" with your actual tag key.
#
# Install Azure PowerShell module if not already installed
# Install-Module -Name Az -AllowClobber -Force -Scope CurrentUser

# Import the Azure PowerShell module
Import-Module Az

# Authenticate to Azure (you will be prompted for credentials)
Connect-AzAccount

# Get all resource groups in the subscription
$resourceGroups = Get-AzResourceGroup

# Specify the tag key to check
$tagKey = "YourTagKey"

# Initialize an array to store untagged resources
$resourcesWithoutTag = @()

# Loop through each resource group
foreach ($resourceGroup in $resourceGroups) {
    # Get all resources in the current resource group
    $resources = Get-AzResource -ResourceGroupName $resourceGroup.ResourceGroupName

    # Loop through each resource
    foreach ($resource in $resources) {
        # Check if the specified tag key exists for the resource
        if (-not $resource.Tags.ContainsKey($tagKey)) {
            $resourcesWithoutTag += $resource
        }
    }
}

# Display untagged resources
if ($resourcesWithoutTag.Count -gt 0) {
    Write-Host "Untagged resources across all resource groups:"
    foreach ($resource in $resourcesWithoutTag) {
        Write-Host "- $($resource.ResourceType) - $($resource.ResourceGroupName) - $($resource.Name)"
    }
} else {
    Write-Host "All resources across all resource groups have the tag '$tagKey'."
}
#

#========================================================================================= using graph api 

# Here's a high-level overview of the process using Microsoft Graph API:
# 1.    Authentication: Acquire an access token to authenticate your requests to Microsoft Graph API. This involves setting up an Azure AD App registration, obtaining the necessary application ID and secret, and configuring the required permissions.
# 2.    Querying Azure Resource Graph API: Use Microsoft Graph API to query the Azure Resource Graph and retrieve information about resources, including their tags.
# 3.    Filtering Untagged Resources: Process the results of the query to identify resources that do not have the specified tag.

# Below is an example using PowerShell and the Invoke-RestMethod cmdlet to make a call to Microsoft Graph API. Note that this is a simplified example, and you need to set up proper authentication and handle pagination for large result sets.

# Set your Azure AD App registration details
$appId = "YourAppId"
$tenantId = "YourTenantId"
$clientSecret = "YourClientSecret"
$resource = "https://graph.microsoft.com"
$tagKey = "YourTagKey"

# Acquire an access token
$tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/token"
$tokenParams = @{
    client_id     = $appId
    client_secret = $clientSecret
    resource      = $resource
    grant_type    = "client_credentials"
}
$tokenResponse = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -Body $tokenParams

# Use the access token to query Azure Resource Graph API
$queryUrl = "https://graph.microsoft.com/v1.0/subscriptions/{subscription-id}/providers/Microsoft.ResourceGraph/resources?api-version=1.0"
$headers = @{
    Authorization = "Bearer $($tokenResponse.access_token)"
}

# Make the request to Azure Resource Graph API
$result = Invoke-RestMethod -Uri $queryUrl -Method Get -Headers $headers

# Process the result to identify untagged resources
$resourcesWithoutTag = $result.value | Where-Object { -not $_.tags.ContainsKey($tagKey) }

# Display untagged resources
if ($resourcesWithoutTag.Count -gt 0) {
    Write-Host "Untagged resources:"
    foreach ($resource in $resourcesWithoutTag) {
        Write-Host "- $($resource.type) - $($resource.name)"
    }
} else {
    Write-Host "All resources have the tag '$tagKey'."
}
#
#Remember to replace placeholders like "YourAppId," "YourTenantId," "YourClientSecret," and "YourTagKey" with your actual values. Also, ensure that your Azure AD App registration has the necessary permissions to query Azure Resource Graph API. Additionally, this example assumes you have the required PowerShell modules installed.
#
