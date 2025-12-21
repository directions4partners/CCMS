Param(
    [string] $appType,
    [ref] $compilationParams
)

# In CCMS it is better to have untranslated textx than having NAB tags in the build
# Clean up NAB tags , just in time for the build, but do not modify the source
Get-ChildItem -path (Join-Path $compilationParams.Value.appProjectFolder "Translations") -Filter *.xlf -Recurse | ForEach-Object {
    $file = $_.FullName
    Write-Host "Found translation file $($file), checking for NAB translation tags"
    try {
        # Remove NAB tags before compiling
        [xml]$xml = Get-Content -Encoding UTF8 -Path $file -Raw
        $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
        $ns.AddNamespace("x", "urn:oasis:names:tc:xliff:document:1.2")
        $transUnits = $xml.SelectNodes("//x:trans-unit", $ns)
        $modified = $false
        foreach ($tu in $transUnits) {
            $targets = $tu.SelectNodes("x:target", $ns)
            $source = $tu.SelectSingleNode("x:source", $ns).InnerText
            foreach ($targetNode in $targets) {
                $target = $targetNode.InnerText
                $newtarget = $target -replace '\[NAB:[^<>\[\]]*\]',''
                if ($target -ne $newtarget) {
                    if ($newtarget -eq '') {
                        $newtarget = $source
                        Write-Host "Found '$target' (source is '$source'), replacing with source"
                    }
                    else {
                        Write-Host "Found '$target' (source is '$source'), replacing with '$newtarget'"
                    }
                    $targetNode.InnerText = $newtarget
                    $modified = $true
                }
            }
        }
        if ($modified) {
            Write-Host "Modified translation file $($file)"
            $xml.Save($file)
        }
    } catch {
        Write-Host "Error processing translation file $($_.FullName): $_"
    }
}
