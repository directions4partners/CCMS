Param(
    [string] $appType,
    [ref] $compilationParams
)

if ($appType -eq 'appxxx') {
    $compilationParams.Value["features"] += "TranslationFile"
}
