# YouTube Frame Extractor

A PowerShell script that extracts a single frame image at a specific timestamp from every video on a YouTube channel using `yt-dlp` and `ffmpeg`.

## Prerequisites

The following tools must be installed and available in your system PATH:
* **PowerShell** (Built into Windows, or PowerShell 7+)
* **yt-dlp**
* **ffmpeg**

## Configuration

Open the script in a text editor and modify the variables at the top:

```powershell
# Frame capture timestamp in seconds (e.g., 30 = 30 seconds, 300 = 5 minutes)
$T = 30

# Target channel URL (must end with /videos)
$channel = "https://www.youtube.com/@channelname/videos"

# Path to your exported YouTube cookies.txt file
$cookiePath = "C:\Users\yourusername\Desktop\cookies.txt"
```

> **Security Notice:** Never upload or commit your `cookies.txt` file to GitHub. It contains active session tokens for your account. Make sure to add `cookies.txt` to your `.gitignore` file.

## Script Code (`extract-frames.ps1`)

```powershell
New-Item -ItemType Directory -Force frames, clips | Out-Null
Remove-Item clips\* -Force
$T = 30
$channel = "https://www.youtube.com/@themuunlofi/videos"
$cookiePath = "C:\Users\ipeet\Desktop\cookies.txt"

yt-dlp --cookies $cookiePath --flat-playlist --print id $channel | ForEach-Object {
  $id = $_
  if (Test-Path "frames/$id.png") { return }
  Write-Host "Processing $id"
  yt-dlp --cookies $cookiePath -q --progress --no-continue -f "bv" -o "clips/$id.%(ext)s" "https://youtu.be/$id"
  $clip = Get-ChildItem "clips/$id.*" | Select-Object -First 1
  if ($clip) {
    ffmpeg -y -nostdin -loglevel error -ss $T -i $clip.FullName -frames:v 1 "frames/$id.png"
    Remove-Item $clip.FullName
  }
}
```

## Usage

1. Export your YouTube browser cookies in Netscape format (using a browser extension) and save them as `cookies.txt`.
2. Update `$cookiePath` in the script to match the file location of `cookies.txt`.
3. Open PowerShell and navigate to the project directory:
   ```powershell
   cd "C:\path\to\script-folder"
   ```
4. Run the script:
   ```powershell
   .\extract-frames.ps1
   ```

## Output and Behavior

* **Output Folder (`frames/`):** Extracted frame images saved as `<video_id>.png`.
* **Temp Folder (`clips/`):** Video clips are temporarily stored here and deleted immediately after processing.
* **Skip / Resume:** Skips downloading any video whose frame image already exists in `frames/`.
