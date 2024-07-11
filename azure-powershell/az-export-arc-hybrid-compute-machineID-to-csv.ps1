# Connect to Azure (ensure you're logged in and have proper permissions)
Connect-AzAccount

# Set the resource group name
$resourceGroup = "RG1"

# Get all hybrid machines in the resource group
$hybridMachines = Get-AzResource -ResourceType "Microsoft.HybridMachine/machines" -ResourceGroup $resourceGroup

# Extract machine IDs and create CSV data
$machineIds = $hybridMachines | Select-Object -ExpandProperty Id | Select-Object -ExpandProperty Split("/")[-1]

# Create and format CSV content
$csvContent = $machineIds | ConvertTo-Csv -NoTypeInformation

# Set the CSV file path (modify as needed)
$csvFilePath = "C:\path\to\output.csv"

# Write CSV content to the file
Out-File -FilePath $csvFilePath -InputObject $csvContent -Encoding UTF8

# Optional: Display success message
Write-Host "Machine IDs exported successfully to: $csvFilePath"


#==============

