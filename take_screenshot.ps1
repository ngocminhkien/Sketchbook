param(
    [string]$url,
    [string]$outFile
)
$chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
$tempProfile = "$env:TEMP\chrome_snap_$(Get-Random)"
& $chrome --headless --disable-gpu "--screenshot=$outFile" --window-size=1440,900 --virtual-time-budget=6000 "--user-data-dir=$tempProfile" $url
if (Test-Path $tempProfile) {
    Remove-Item -Recurse -Force $tempProfile -ErrorAction SilentlyContinue
}
