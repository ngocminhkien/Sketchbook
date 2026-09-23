param(
    [string]$url,
    [string]$outFile
)
$chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
if (-not (Test-Path $chrome)) {
    $chrome = 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
}
$tempProfile = Join-Path $env:TEMP ("chrome_snap_" + [System.Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $tempProfile -Force | Out-Null
try {
    $argList = @(
        "--headless=new",
        "--disable-gpu",
        "--hide-scrollbars",
        "--window-size=1440,900",
        "--virtual-time-budget=4000",
        "--user-data-dir=$tempProfile",
        "--screenshot=$outFile",
        $url
    )
    $proc = Start-Process -FilePath $chrome -ArgumentList $argList -Wait -PassThru -NoNewWindow
    Write-Output "Chrome exited with code $($proc.ExitCode)"
} finally {
    Start-Sleep -Milliseconds 500
    Remove-Item -Recurse -Force $tempProfile -ErrorAction SilentlyContinue
}

