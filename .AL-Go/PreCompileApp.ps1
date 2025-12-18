Param(
    [string] $appType,
    [ref] [hashtable] $compilationParams
)

if ($appType -eq 'app') {
    Write-Host "Checking translations for app: $appFilePath"
}
else {
    return
}
$compilationParams.Value.features += "TranslationFile"
