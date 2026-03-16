#this is a test file for powershell

function Check-processStatus {
    param (
        $WebsiteURL | Test-Connection 
    )
    if ($WebsiteURL -eq True) {
        Write-Host "Site is working."
    }
    else {
        Write-Host "Site is not working."
    }
    
}
Check-processStatus "https://www.google.com"