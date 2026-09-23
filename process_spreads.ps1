Add-Type -AssemblyName System.Drawing

function Convert-SketchToSpread {
    param(
        [string]$sketchPath,
        [string]$outputPath,
        [double]$padRatio = 0.05
    )

    $template = New-Object System.Drawing.Bitmap("e:\ui\001\public\landing-pages\meng-to-sketchbook\marina-bay-sands.png")
    $sketch = New-Object System.Drawing.Bitmap($sketchPath)

    Write-Host "Source image: $($sketch.Width) x $($sketch.Height)"

    # Find the bounding box of the book in the sketch by scanning contrast against background
    # Most generated images have the book covering roughly 5% to 95% horizontally and 20% to 80% vertically.
    # Let's inspect rows and columns to find the paper edges:
    # A standard 3:2 generated image with book has the book centered.
    # We can crop the book tightly:
    # Let's measure where the book edges are:
    $w = $sketch.Width
    $h = $sketch.Height
    
    # Book horizontal bounds: typically from ~5% to ~95%
    # Book vertical bounds: typically from ~19% to ~83%
    # To be precise, let's find the book by brightness difference from the neutral background:
    # Or measure directly:
    $srcX = [int]($w * 0.052)
    $srcW = [int]($w * 0.896)
    $srcY = [int]($h * 0.205)
    $srcH = [int]($h * 0.605)

    $srcRect = New-Object System.Drawing.Rectangle($srcX, $srcY, $srcW, $srcH)
    Write-Host "Crop rect: $srcX, $srcY, $srcW, $srcH"

    $outBmp = New-Object System.Drawing.Bitmap($template.Width, $template.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($outBmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    # Exact book rect on 1760x1240 canvas: (90, 270, 1580, 695)
    $dstRect = New-Object System.Drawing.Rectangle(90, 270, 1580, 695)
    $g.DrawImage($sketch, $dstRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()

    # Now mask alpha from template so outside the book is transparent with smooth anti-aliased edge
    $rect = New-Object System.Drawing.Rectangle(0, 0, $template.Width, $template.Height)
    $tmplData = $template.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $outData = $outBmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

    $bytesCount = $tmplData.Stride * $template.Height
    $tmplBytes = New-Object byte[] $bytesCount
    $outBytes = New-Object byte[] $bytesCount

    [System.Runtime.InteropServices.Marshal]::Copy($tmplData.Scan0, $tmplBytes, 0, $bytesCount)
    [System.Runtime.InteropServices.Marshal]::Copy($outData.Scan0, $outBytes, 0, $bytesCount)

    # 4 bytes per pixel: B, G, R, A
    for ($i = 0; $i -lt $bytesCount; $i += 4) {
        $a = $tmplBytes[$i + 3]
        if ($a -eq 0) {
            $outBytes[$i + 3] = 0
        } else {
            $origA = $outBytes[$i + 3]
            $outBytes[$i + 3] = [byte](($origA * $a) / 255)
        }
    }

    [System.Runtime.InteropServices.Marshal]::Copy($outBytes, 0, $outData.Scan0, $bytesCount)
    $template.UnlockBits($tmplData)
    $outBmp.UnlockBits($outData)

    $outBmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $template.Dispose()
    $sketch.Dispose()
    $outBmp.Dispose()
    Write-Host "Created spread: $outputPath"
}

# 1. Ngo Mon Hue
Convert-SketchToSpread `
    -sketchPath "C:\Users\Ngoc Minh Kien\.gemini\antigravity\brain\c2add51e-bfff-4403-a210-f7b42a7911a3\ngo_mon_hue_v2_1790152819197.jpg" `
    -outputPath "e:\ui\001\public\landing-pages\meng-to-sketchbook\ngo-mon-hue.png"

# 2. Chua Cau Hoi An
Convert-SketchToSpread `
    -sketchPath "C:\Users\Ngoc Minh Kien\.gemini\antigravity\brain\c2add51e-bfff-4403-a210-f7b42a7911a3\chua_cau_v2_1790153071252.jpg" `
    -outputPath "e:\ui\001\public\landing-pages\meng-to-sketchbook\chua-cau-hoi-an.png"

# 3. Cho Ben Thanh
Convert-SketchToSpread `
    -sketchPath "C:\Users\Ngoc Minh Kien\.gemini\antigravity\brain\c2add51e-bfff-4403-a210-f7b42a7911a3\ben_thanh_v2_1790153175390.jpg" `
    -outputPath "e:\ui\001\public\landing-pages\meng-to-sketchbook\cho-ben-thanh.png"
