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
$compilationParams | ConvertTo-Json | Out-Host

