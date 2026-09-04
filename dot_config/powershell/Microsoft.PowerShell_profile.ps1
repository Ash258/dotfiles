function Import-OpEnv {
    <#
    .SYNOPSIS
        Injects secrets from a 1Password-templated .env file directly into
        the current PowerShell session's environment — no plaintext file
        is ever written to disk.

    .PARAMETER Path
        Path to the .env template file containing op:// references.
        Defaults to ".env" in the current directory.

    .PARAMETER Quiet
        Suppress the per-variable confirmation output.

    .EXAMPLE
        Import-OpEnv
        Import-OpEnv -Path ".env.production"
        Import-OpEnv .env -Quiet
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Path = ".env",

        [switch]$Quiet
    )

    if (-not (Get-Command op -ErrorAction SilentlyContinue)) {
        Write-Error "1Password CLI ('op') not found in PATH."
        return
    }

    if (-not (Test-Path $Path)) {
        Write-Error "File not found: $Path"
        return
    }

    $lineNum = 0
    $count = 0

    # -i / -o omitted => op inject resolves op:// refs and streams to stdout only
    op inject -i $Path | ForEach-Object {
        $lineNum++
        $line = $_

        # Skip blank lines and comments
        if ([string]::IsNullOrWhiteSpace($line) -or $line.TrimStart().StartsWith('#')) {
            return
        }

        # Capture everything after the FIRST '=' as the value (handles '=' in secrets)
        if ($line -match '^\s*([^#=]+?)\s*=\s*(.*)$') {
            $name  = $matches[1]
            $value = $matches[2].Trim()

            # Strip one layer of matching surrounding quotes, if present
            if (($value.StartsWith('"') -and $value.EndsWith('"')) -or
                ($value.StartsWith("'") -and $value.EndsWith("'"))) {
                $value = $value.Substring(1, $value.Length - 2)
            }

            Set-Item -Path "env:$name" -Value $value
            $count++

            if (-not $Quiet) {
                Write-Host "Set env:$name" -ForegroundColor DarkGray
            }
        }
        else {
            Write-Warning "Skipped unparseable line $lineNum in $Path"
        }
    }

    if (-not $Quiet) {
        Write-Host "Imported $count secret(s) from $Path into the current session." -ForegroundColor Green
    }
}

(&mise activate pwsh) | Out-String | Invoke-Expression
