# Connect to managed identity in our Azure tenant
try {
    Connect-AzAccount -Identity -ErrorAction Stop
    Write-Output "Successfully connected to Azure account."
} catch {
    Write-Error "Failed to connect to Azure account: $_"
    exit 1
}

# Define the query to find disks that haven't had ownership updates in the last 90 days
$disksToBeRemoved = Search-AzGraph -Query '
resources
| where type == "microsoft.compute/disks"
| where todatetime(properties.LastOwnershipUpdateTime) < ago(90d)
| where properties.diskState == "Unattached"
| project name, diskState = properties.diskState, lastUpdateTime = format_datetime(todatetime(properties.LastOwnershipUpdateTime), "dd-MM-yyyy")
'

# Loop through each disk and output the disk information
foreach ($disk in $disksToBeRemoved) {
    # Output the disk information for verification
    Write-Output "Disk: $($disk.name), Last Update: $($disk.lastUpdateTime)"
    
}