#!/usr/bin/env bash
# This programm converts all Audible .aax files to unlocked mp3
# and removes intro and outro
#
# Usage:
#   ./audible-unlock.sh
#
# Autor: Mike Reiche
# See: https://github.com/inAudible-NG/tables

INTRO_OUTRO_SEC=3

if [[ "$OSTYPE" == "cygwin" ]]; then
  RCRACK_CMD="tables/run/rcrack.exe"
else
  RCRACK_CMD="tables/rcrack"
fi

for filepath in *.aax; do
  ffprobe.exe "$filepath" -- 2>&1 | cat - > out.txt
  checksum=$(gawk 'match($0, /file checksum == ([A-z0-9]+)/, a) { print a[1] }' out.txt)
  hours=$(gawk 'match($0, /Duration: ([0-9]+):([0-9]+):([0-9]+)/, a) { print a[1] }' out.txt)
  minutes=$(gawk 'match($0, /Duration: ([0-9]+):([0-9]+):([0-9]+)/, a) { print a[2] }' out.txt)
  seconds=$(gawk 'match($0, /Duration: ([0-9]+):([0-9]+):([0-9]+)/, a) { print a[3] }' out.txt)
  echo checksum \'$checksum\'
  echo duration $hours:$minutes:$seconds
  let "seconds = $seconds - 2*$INTRO_OUTRO_SEC"
  if [ $seconds -lt 0 ]; then
    let minutes--
    let "seconds = 60 + $seconds"
  fi
  echo target duration $hours:$minutes:$seconds
  echo "search for key..."
  $RCRACK_CMD tables -h "$checksum" > key.txt
  hexkey=$(gawk 'match($0, /hex:([A-z0-9]+)/, a) { print a[1] }' key.txt)
  filename=$(basename -- "$filepath")
  extension="${filename##*.}"
  filename="${filename%.*}"
  echo "decode file..."
  ffmpeg.exe -activation_bytes $hexkey -i "$filepath" -c:a copy -vn -ss 3.6 -t $hours:$minutes:$seconds "$filename.mp4"
done
