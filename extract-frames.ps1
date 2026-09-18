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
