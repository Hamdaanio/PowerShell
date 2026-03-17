# ---------------------------------------------
# Delete Temporary Files for All Users
# ---------------------------------------------
$UserProfiles = Get-ChildItem -Path "C:\Users" -Directory

foreach ($Profile in $UserProfiles) {
    $TempPath = Join-Path -Path $Profile.FullName -ChildPath "AppData\Local\Temp"

    if (Test-Path $TempPath) {
        Write-Host "Cleaning temp files for user: $($Profile.Name)" -ForegroundColor Cyan

        try {
            Get-ChildItem -Path $TempPath -Recurse -Force -ErrorAction SilentlyContinue |
                Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

            Write-Host "Temp cleaned for $($Profile.Name)" -ForegroundColor Green
        }
        catch {
            Write-Host "Could not clean temp for $($Profile.Name): $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "No temp folder found for $($Profile.Name)" -ForegroundColor DarkGray
    }
}

Write-Host "All user temp folders processed." -ForegroundColor Magenta
