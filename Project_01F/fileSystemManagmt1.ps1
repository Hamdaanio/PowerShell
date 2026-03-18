$Path = "C:\Users\hamda\Downloads"
$Days = 60

$Files = Get-ChildItem -Path $Path -File -Recurse

$OldFiles = $Files | Where-Object {
    $_.LastWriteTime -lt (Get-Date).AddDays(-$Days)
}

$OldFiles | Remove-Item -Force

