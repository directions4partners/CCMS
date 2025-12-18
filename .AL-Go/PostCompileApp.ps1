Param(
    [string] $appFilePath,
    [string] $appType,
    [hashtable] $compilationParams
)

if ($appType -eq 'app') {
    Write-Host "Checking translations for app: $appFilePath"
}
else {
    return
}
$compilationParams | ForEach-Object {
    Write-Host "Parameter: $($_.Key) = $($_.Value)"
}
