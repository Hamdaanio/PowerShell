# Define input parameters for the script
param(
    # Optional parameter to accept one or more computer names
    [Parameter(Mandatory=$false)]
    [string[]]$ComputerName,

    # Optional parameter to accept a file path containing computer names
    [Parameter(Mandatory=$false)]
    [string]$InputFile
)

# If an input file is provided
if ($InputFile) {

    # Check if the file actually exists
    if (Test-Path $InputFile) {

        # Read all lines from the file and store as computer names
        $ComputerName = Get-Content $InputFile
    } else {

        # Display error if file is not found
        Write-Host "Input file not found." -ForegroundColor Red

        # Stop script execution
        exit
    }
}

# If no computer names were provided at all
if (-not $ComputerName) {

    # Prompt user to provide input
    Write-Host "Please provide computer names or an input file." -ForegroundColor Red

    # Stop script execution
    exit
}

# Initialize an empty array to store results
$results = @()

# Loop through each computer in the list
foreach ($computer in $ComputerName) {

    # Display which computer is currently being processed
    Write-Host "Processing $computer..." -ForegroundColor Cyan

    # Check if the computer is reachable (ping test)
    $reachable = Test-Connection -ComputerName $computer -Count 1 -Quiet -ErrorAction SilentlyContinue

    # If the computer is NOT reachable
    if (-not $reachable) {

        # Add a result object showing failure information
        $results += [PSCustomObject]@{
            ComputerName = $computer         # Store computer name
            Reachable    = "No"              # Mark as not reachable
            Status       = "WARNING"         # Status indicator
            OS           = $null             # No OS info available
            Version      = $null             # No version info
            Manufacturer = $null             # No manufacturer info
            MemoryGB     = $null             # No memory info
            LastBoot     = $null             # No boot time
            Error        = "Host unreachable" # Error message
        }

        # Skip to next computer in the loop
        continue
    }

    # Try to collect system information
    try {

        # Get operating system details remotely using CIM
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computer -ErrorAction Stop

        # Get hardware/system details remotely
        $cs = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $computer -ErrorAction Stop

        # Add a successful result object
        $results += [PSCustomObject]@{
            ComputerName = $computer                     # Store computer name
            Reachable    = "Yes"                         # Mark as reachable
            Status       = "PASS"                        # Status indicator
            OS           = $os.Caption                   # OS name (e.g., Windows Server)
            Version      = $os.Version                   # OS version
            Manufacturer = $cs.Manufacturer              # Hardware manufacturer
            MemoryGB     = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2) # Convert memory to GB
            LastBoot     = $os.LastBootUpTime            # Last reboot time
            Error        = $null                         # No error
        }
    }
    catch {

        # If something fails during data collection
        $results += [PSCustomObject]@{
            ComputerName = $computer                     # Store computer name
            Reachable    = "Yes"                         # It responded but had issues
            Status       = "WARNING"                     # Warning status
            OS           = $null                         # Data unavailable
            Version      = $null
            Manufacturer = $null
            MemoryGB     = $null
            LastBoot     = $null
            Error        = $_.Exception.Message          # Capture actual error message
        }
    }
}

# Display results in a formatted table
$results | Format-Table -AutoSize

# Count total number of systems processed
$total = $results.Count

# Count how many systems were reachable
$reachableCount = ($results | Where-Object {$_.Reachable -eq "Yes"}).Count

# Count how many systems were unreachable
$unreachableCount = ($results | Where-Object {$_.Reachable -eq "No"}).Count

# Display summary header
Write-Host "`n===== SUMMARY =====" -ForegroundColor Yellow

# Display total systems
Write-Host "Total Systems: $total"

# Display reachable systems count
Write-Host "Reachable: $reachableCount"

# Display unreachable systems count
Write-Host "Unreachable: $unreachableCount"

# Export results to a CSV file for reporting
$results | Export-Csv -Path ".\ServerAuditReport.csv" -NoTypeInformation

# Notify user that export is complete
Write-Host "`nReport exported to ServerAuditReport.csv" -ForegroundColor Green
