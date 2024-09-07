#================================================= Export arc machine IDs from RG1 into a csv file 
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


#============================================ read csv file and move each object from RG1 to RG3 

# Connect to Azure (ensure you're logged in and have proper permissions)
Connect-AzAccount

# Set the CSV file path (modify as needed)
$csvFilePath = "C:\path\to\machine_ids.csv"

# Import CSV content (assuming header row with "MachineId")
$machineIds = Import-Csv -Path $csvFilePath | Select-Object -ExpandProperty MachineId

# Loop through each machine ID
foreach ($machineId in $machineIds) {
  # Try-Catch block for error handling
  try {
    # Get the hybrid machine by ID
    $machine = Get-AzResource -ResourceId "Microsoft.HybridMachine/machines/$machineId"

    # Move the machine to the new resource group (RG3)
    Move-AzResource -ResourceId $machine.Id -DestinationResourceGroupName "RG3"

    Write-Host "Successfully moved machine $machineId to RG3"
  }
  catch {
    Write-Warning "Error moving machine $machineId: $_"
  }
}

Write-Host "Machine movement completed."

#
#
#
#
#
#
#
