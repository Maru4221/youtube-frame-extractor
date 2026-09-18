# YouTube Frame Extractor

A PowerShell script that extracts a single frame image at a specific timestamp from a single video or every video on a YouTube channel.

## Prerequisites

The following tools must be installed and available in your system PATH:
- **PowerShell** (Built into Windows, or PowerShell 7+)
- **yt-dlp**
- **ffmpeg**

---

## Configuration

Open `video frame downloader script.ps1` in a text editor and modify the configuration variables:

```powershell
# Frame capture timestamp in seconds (e.g., 30 = 30 seconds, 300 = 5 minutes)
$T = 30

# Target channel URL (must end with /videos)
$channel = "https://www.youtube.com/@channelname/videos"
```

---

## Script Code (`video frame downloader script.ps1`)

```powershell
New-Item -ItemType Directory -Force frames, clips | Out-Null
Remove-Item clips\* -Force
$T = 30
$channel = "https://www.youtube.com/@themuunlofi/videos"

yt-dlp --flat-playlist --print id $channel | ForEach-Object {
  $id = $_
  if (Test-Path "frames/$id.png") { return }
  Write-Host "Processing $id"
  yt-dlp -q --progress --no-continue -f "bv" -o "clips/$id.%(ext)s" "https://youtu.be/$id"
  $clip = Get-ChildItem "clips/$id.*" | Select-Object -First 1
  if ($clip) {
    ffmpeg -y -nostdin -loglevel error -ss $T -i $clip.FullName -frames:v 1 "frames/$id.png"
    Remove-Item $clip.FullName
  }
}
```

---

## Usage

1. Open PowerShell and change directory to the folder containing `extract-frames.ps1`:
   ```powershell
   cd "C:\path\to\your\folder"
   ```

2. Execute the script:
   ```powershell
   .\extract-frames.ps1
   ```

---

## Output and Behavior

- **Output Folder (`frames/`):** Captured frames are saved as `<video_id>.png`.
- **Temp Folder (`clips/`):** Video clips are temporarily stored here and deleted immediately after frame extraction.
- **Skip / Resume:** If `frames/<video_id>.png` already exists, the script skips downloading that video.
