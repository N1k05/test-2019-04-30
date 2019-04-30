$limit = (Get-Date).AddDays(-7)
$path = "C:\tmp"

Get-ChildItem -Path $path | Where-Object { $_.CreationTime -lt $limit } | Remove-Item -Force
