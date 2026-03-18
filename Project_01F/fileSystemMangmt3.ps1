
# ---------------------------------------------
# This code retrieves the largest files in a specified directory and its subdirectories. It sorts the files by size in descending order and selects the top 15 largest files, displaying their name, full path, and size in megabytes (MB).
# ---------------------------------------------
$Path = "C:\Users\hamda"
$Files = Get-ChildItem -Path $Path -File -Recurse -ErrorAction SilentlyContinue

$Largest = $Files |
    Sort-Object Length -Descending |
    Select-Object Name, FullName, @{Name="SizeMB";Expression={"{0:N2}" -f ($_.Length / 1MB)}} -First 15

$Largest
