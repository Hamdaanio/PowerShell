# Clear classic logs
Get-EventLog -List | ForEach-Object {
    try {
        Clear-EventLog -LogName $_.Log
        Write-Host "Cleared classic log: $($_.Log)"
    }
    catch {
        Write-Host "Could not clear classic log: $($_.Log)"
    }
}

# Clear modern logs
$ModernLogs = wevtutil el

foreach ($Log in $ModernLogs) {
    try {
        wevtutil cl "$Log"
        Write-Host "Cleared modern log: $Log"
    }
    catch {
        Write-Host "Could not clear modern log: $Log"
    }
}
