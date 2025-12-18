Param(
    [string] $appType,
    [ref] $compilationParams
)

if ($appType -eq 'app') {
    $compilationParams.Value["features"] += "TranslationFile"
}
