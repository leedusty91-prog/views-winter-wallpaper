set -e
cd "$(dirname "$0")"
mkdir -p out
while pgrep -f "capture.js 1920" >/dev/null; do sleep 10; done
ffmpeg -y -loglevel error -i m1920.mp4 -c:v libx264 -preset slow -b:v 23M -maxrate 30M -bufsize 46M -pass 1 -passlogfile p1080 -an -f null /dev/null
ffmpeg -y -loglevel error -i m1920.mp4 -c:v libx264 -preset slow -b:v 23M -maxrate 30M -bufsize 46M -pass 2 -passlogfile p1080 -pix_fmt yuv420p -profile:v high -tag:v avc1 -movflags +faststart -an out/views-storm-1920x1080-h264.mp4
ffmpeg -y -loglevel error -t 10 -i m1920.mp4 -c:v libx264 -preset slow -b:v 14M -maxrate 20M -bufsize 28M -pass 1 -passlogfile pprev -an -f null /dev/null
ffmpeg -y -loglevel error -t 10 -i m1920.mp4 -c:v libx264 -preset slow -b:v 14M -maxrate 20M -bufsize 28M -pass 2 -passlogfile pprev -pix_fmt yuv420p -tag:v avc1 -movflags +faststart -an out/views-storm-preview-10s-1080p.mp4
echo 1080done
while pgrep -f "capture.js 2560" >/dev/null; do sleep 10; done
ffmpeg -y -loglevel error -i m2560.mp4 -c:v libx265 -preset medium -b:v 22M -x265-params pass=1:stats=p2560.log:log-level=error -an -f null /dev/null
ffmpeg -y -loglevel error -i m2560.mp4 -c:v libx265 -preset medium -b:v 22M -x265-params pass=2:stats=p2560.log:log-level=error -pix_fmt yuv420p -tag:v hvc1 -movflags +faststart -an out/views-storm-2560x1664-hevc.mp4
echo ALLDONE
