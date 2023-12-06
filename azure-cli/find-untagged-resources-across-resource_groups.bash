# Azure CLI command to find untagged resources across all resource groups:
# This script uses the Azure CLI to list all resource groups and then iterates through each resource group to list all resources within. For each resource, it checks if the specified tag key exists. If the tag is not found, the resource details are added to the resourcesWithoutTag array, which is then displayed at the end. Note that this script assumes you have the jq tool installed for JSON parsing.
# Make sure to replace "YourTagKey" with your actual tag key.

tagKey="YourTagKey"

# Get a list of all resource groups
resourceGroups=$(az group list --query '[].name' --output tsv)

# Initialize an array to store untagged resources
resourcesWithoutTag=()

# Loop through each resource group
for resourceGroup in $resourceGroups; do
    # Get a list of all resources in the current resource group
    resources=$(az resource list --resource-group $resourceGroup --query '[].{Name:name, Type:type, Tags:tags}' --output json)

    # Loop through each resource
    for resource in $(echo $resources | jq -c '.[]'); do
        # Check if the specified tag key exists for the resource
        if [ "$(echo $resource | jq -r ".Tags.$tagKey")" == "null" ]; then
            resourcesWithoutTag+=("$resourceGroup - $(echo $resource | jq -r '.Type') - $(echo $resource | jq -r '.Name')")
        fi
    done
done

# Display untagged resources
if [ ${#resourcesWithoutTag[@]} -gt 0 ]; then
    echo "Untagged resources across all resource groups:"
    for resource in "${resourcesWithoutTag[@]}"; do
        echo "- $resource"
    done
else
    echo "All resources across all resource groups have the tag '$tagKey'."
fi
#