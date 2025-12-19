Param(
    [string] $appFilePath,
    [string] $appType,
    [hashtable] $compilationParams
)

function CheckTranslations([string] $appFolderPath, [string] $workspaceFilePath = $null, [switch] $writeErrors, [switch] $preRelease) {
    function HandleError([string] $message) {
        if ($writeErrors) {
            throw $message
        }
        else {
            Write-Host "::warning::$message"
        }
    }

    # Check if Node.js is installed
    $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
    if (-not $nodeCmd) {
        HandleError "Node.js is not installed or not in PATH. Please install Node.js from https://nodejs.org/"
        return
    }

    # Determine which release to download
    $releaseUrl = "https://api.github.com/repos/jwikman/nab-al-tools/releases"
    if ($preRelease) {
        $releaseUrl += "?per_page=1"
        Write-Host "Fetching latest pre-release of NAB AL Tools RefreshXLF from GitHub..."
    }
    else {
        $releaseUrl += "/latest"
        Write-Host "Fetching latest release of NAB AL Tools RefreshXLF from GitHub..."
    }

    try {
        # Get release information
        $release = Invoke-RestMethod -Uri $releaseUrl -Headers @{ "User-Agent" = "PowerShell" }
        if ($preRelease) {
            $release = $release | Where-Object { $_.prerelease -eq $true } | Select-Object -First 1
            if (-not $release) {
                HandleError "No pre-release found"
                return
            }
        }

        $version = $release.tag_name
        Write-Host "Found version: $version"

        # Find RefreshXLF.js asset
        $asset = $release.assets | Where-Object { $_.name -eq "RefreshXLF.js" }
        if (-not $asset) {
            HandleError "RefreshXLF.js not found in release assets"
            return
        }

        # Setup temp file path with version
        $tempFolder = [System.IO.Path]::GetTempPath()
        $scriptPath = Join-Path $tempFolder "RefreshXLF.js"

        # Download if not already cached
        if (Test-Path $scriptPath) {
            Remove-Item $scriptPath -ErrorAction SilentlyContinue -Force
        }
        Write-Host "Downloading RefreshXLF.js to $scriptPath..."
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $scriptPath -Headers @{ "User-Agent" = "PowerShell" }
        Write-Host "Download complete"

        # Build command arguments
        $arguments = @(
            $scriptPath,
            "`"$appFolderPath`""
        )

        if ($workspaceFilePath) {
            $arguments += "`"$workspaceFilePath`""
        }

        $arguments += "--github-message"
        $arguments += "--check-only"

        if ($writeErrors) {
            $arguments += "--fail-changed"
        }

        # Execute RefreshXLF.js
        Write-Host "Running RefreshXLF.js..."
        $cmdLine = "node " + ($arguments -join " ")

        Invoke-Expression $cmdLine | Out-Host
        $exitCode = $LASTEXITCODE

        if ($exitCode -ne 0) {
            HandleError "RefreshXLF.js failed with exit code $exitCode"
            return
        }

        Write-Host "Translation check completed successfully"

    }
    catch {
        HandleError "Failed to download or execute RefreshXLF.js: $_"
        return
    }
}

if ($appType -eq 'app') {
    Write-Host "Checking translations for app: $appFilePath"
}
else {
    return
}

Get-ChildItem -path (Join-Path $compilationParams.appProjectFolder "Translations") -Filter *.xlf -Recurse | ForEach-Object {
    Write-Host "Found translation file: $($_.FullName)"
}
CheckTranslations -appFolderPath $compilationParams.appProjectFolder -preRelease
