# Define input parameters for the script
param(

    # Required parameter: the starting directory path to scan
    [Parameter(Mandatory=$true)]
    [string]$Path,

    # Optional parameter: minimum file size (in MB) to include in results (default = 100MB)
    [Parameter(Mandatory=$false)]
    [int]$ThresholdMB = 100,

    # Optional parameter: number of top largest files to return (default = 20)
    [Parameter(Mandatory=$false)]
    [int]$Top = 20
)

# Check if the provided path exists
if (-not (Test-Path $Path)) {

    # Display error message if path is invalid
    Write-Host "Invalid path provided." -ForegroundColor Red

    # Stop script execution
    exit
}

# Inform user that the scan is starting
Write-Host "Scanning $Path for files larger than $ThresholdMB MB..." -ForegroundColor Cyan

# Convert threshold from MB to bytes for accurate file size comparison
$thresholdBytes = $ThresholdMB * 1MB

# Start error handling block
try {

    # Get all files in the directory (including subfolders), suppress errors like access denied
    $files = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue |

        # Filter files to only include those larger than the threshold
        Where-Object { $_.Length -ge $thresholdBytes }

    # If no files meet the criteria
    if (-not $files) {

        # Inform user that no large files were found
        Write-Host "No large files found." -ForegroundColor Yellow

        # Stop script execution
        exit
    }

    # Sort files by size (largest first) and select top N results
    $topFiles = $files |

        # Sort files in descending order by file size
        Sort-Object Length -Descending |

        # Select only the top specified number of files
        Select-Object -First $Top `

        # Create a custom property for full file path
        @{Name="FullPath"; Expression={$_.FullName}},

        # Convert file size to GB and round to 2 decimal places
        @{Name="Size(GB)"; Expression={[math]::Round($_.Length / 1GB, 2)}}

        # Include last modified date
        LastWriteTime

    # Display results in a formatted table
    $topFiles | Format-Table -AutoSize

    # Get drive information based on the first letter of the path (e.g., C:)
    $drive = Get-PSDrive -Name ($Path.Substring(0,1))

    # Display drive summary header
    Write-Host "n===== DRIVE SUMMARY =====" -ForegroundColor Yellow

    # Display used disk space in GB
    Write-Host "Used: $([math]::Round(($drive.Used / 1GB),2)) GB"

    # Display free disk space in GB
    Write-Host "Free: $([math]::Round(($drive.Free / 1GB),2)) GB"

    # Convert results to an HTML report and save to file
    $topFiles | ConvertTo-Html -Title "Disk Cleanup Report" |

        # Write HTML output to file
        Out-File ".\DiskCleanupReport.html"

    # Notify user that report was successfully exported
    Write-Host "`nReport exported to DiskCleanupReport.html" -ForegroundColor Green
}

# Catch any unexpected errors during execution
catch {

    # Display error message
    Write-Host "Error during scan: $_" -ForegroundColor Red
}
