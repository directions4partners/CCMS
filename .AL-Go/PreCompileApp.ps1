Param(
    [string] $appType,
    [hashtable] $compilationParams
)

Get-ChildItem -path (Join-Path $compilationParams.appProjectFolder "Translations") -Filter *.xlf -Recurse | ForEach-Object {
    Write-Host "Found translation file: $($_.FullName)"
    Write-Host "---------------------------------------------- BEFORE -----------------------------------------------"
    Get-Content -Path $_.FullName | Out-Host
    # Remove NAB tags before compiling
    Get-Content -Path $_.FullName | ForEach-Object { $_ -replace '\[NAB:[^<>\[\]]*\]','' } | Set-Content -Path $_.FullName
    Write-Host "---------------------------------------------- AFTER -----------------------------------------------"
    Get-Content -Path $_.FullName | Out-Host
    Write-Host "---------------------------------------------- END -----------------------------------------------"
}
