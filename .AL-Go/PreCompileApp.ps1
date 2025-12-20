Param(
    [string] $appType,
    [ref] $compilationParams
)

Get-ChildItem -path (Join-Path $compilationParams.Value.appProjectFolder "Translations") -Filter *.xlf -Recurse | ForEach-Object {
    Write-Host "Found translation file: $($_.FullName)"
    # Remove NAB tags before compiling
    $lines = Get-Content -Path $_.FullName -Encoding UTF8 | ForEach-Object { $_ -replace '\[NAB:[^<>\[\]]*\]','' }
    Set-Content -Path $_.FullName -Value $lines -Encoding UTF8
}
