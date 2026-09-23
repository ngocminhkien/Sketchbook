$port = 5503
$root = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($root)) { $root = "e:\ui\001" }

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Output "MengToSketchbookLandingPage Server running at http://localhost:$port/"

$mimeTypes = @{
    ".html"  = "text/html; charset=utf-8"
    ".css"   = "text/css; charset=utf-8"
    ".js"    = "application/javascript; charset=utf-8"
    ".mjs"   = "application/javascript; charset=utf-8"
    ".jpg"   = "image/jpeg"
    ".jpeg"  = "image/jpeg"
    ".png"   = "image/png"
    ".svg"   = "image/svg+xml"
    ".ico"   = "image/x-icon"
    ".json"  = "application/json"
    ".woff2" = "font/woff2"
    ".woff"  = "font/woff"
    ".ttf"   = "font/ttf"
}

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        try {
            $request = $context.Request
            $response = $context.Response

            $rawUrl = [System.Uri]::UnescapeDataString($request.Url.LocalPath)
            $relPath = $rawUrl.TrimStart("/").Replace("/", "\")
            
            $filePath = Join-Path $root $relPath
            if (-not (Test-Path $filePath -PathType Leaf)) {
                $publicPath = Join-Path (Join-Path $root "public") $relPath
                if (Test-Path $publicPath -PathType Leaf) {
                    $filePath = $publicPath
                }
            }

            if ([string]::IsNullOrWhiteSpace($relPath) -or (Test-Path $filePath -PathType Container)) {
                $filePath = Join-Path $filePath "index.html"
                if (-not (Test-Path $filePath -PathType Leaf)) {
                    $filePath = Join-Path $root "index.html"
                }
            }

            $response.AddHeader("Cache-Control", "no-cache")
            $response.AddHeader("Access-Control-Allow-Origin", "*")

            if (Test-Path $filePath -PathType Leaf) {
                $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                $contentType = if ($mimeTypes.ContainsKey($ext)) { $mimeTypes[$ext] } else { "application/octet-stream" }
                $response.ContentType = $contentType
                $response.StatusCode = 200

                $bytes = [System.IO.File]::ReadAllBytes($filePath)
                $response.ContentLength64 = $bytes.Length
                if ($request.HttpMethod -ne "HEAD") {
                    $response.OutputStream.Write($bytes, 0, $bytes.Length)
                }
            } else {
                $response.StatusCode = 404
                $errBytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $rawUrl")
                $response.ContentLength64 = $errBytes.Length
                if ($request.HttpMethod -ne "HEAD") {
                    $response.OutputStream.Write($errBytes, 0, $errBytes.Length)
                }
            }
            $response.OutputStream.Close()
        } catch {
            try { $context.Response.OutputStream.Close() } catch {}
        }
    }
} finally {
    $listener.Stop()
}
