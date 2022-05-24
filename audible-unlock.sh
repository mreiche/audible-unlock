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
PWD=$(pwd)
RCRACK_BIN="$PWD/tables/run/rcrack.exe"

if [[ "$OSTYPE" == "cygwin" ]]; then
  RCRACK_CMD="$RCRACK_BIN"
else
  WINE=$(which wine)
  RCRACK_CMD="$WINE $RCRACK_BIN"
fi

FFPROBE=$(which ffprobe)
FFMPEG=$(which ffmpeg)
GAWK=$(which gawk)

for filepath in *.aax; do
  $FFPROBE "$filepath" -- 2>&1 | cat - > out.txt
  checksum=$("$GAWK" 'match($0, /file checksum == ([A-z0-9]+)/, a) { print a[1] }' out.txt)
  hours=$("$GAWK" 'match($0, /Duration: ([0-9]+):([0-9]+):([0-9]+)/, a) { print a[1] }' out.txt)
  minutes=$("$GAWK" 'match($0, /Duration: ([0-9]+):([0-9]+):([0-9]+)/, a) { print a[2] }' out.txt)
  seconds=$("$GAWK" 'match($0, /Duration: ([0-9]+):([0-9]+):([0-9]+)/, a) { print a[3] }' out.txt)
  echo checksum \'$checksum\'
  echo duration $hours:$minutes:$seconds
  let "seconds = $seconds - 2*$INTRO_OUTRO_SEC"
  if [ $seconds -lt 0 ]; then
    let minutes--
    let "seconds = 60 + $seconds"
  fi

  if [[ -z $checksum ]]; then
    echo "Unable to read checksum"
    exit 1
  fi

  echo target duration $hours:$minutes:$seconds
  echo "Searching for key..."
  $RCRACK_CMD tables -h "$checksum" > key.txt
  if [[ $? != 0 ]]; then
    echo "Failed reading key  ($RCRACK_CMD tables -h $checksum > key.txt)"
    exit 1
  fi

  hexkey=$("$GAWK" 'match($0, /hex:([A-z0-9]+)/, a) { print a[1] }' key.txt)
  filename=$(basename -- "$filepath")
  extension="${filename##*.}"
  filename="${filename%.*}"
  echo "Decoding file..."
  $FFMPEG -activation_bytes "$hexkey" -i "$filepath" -c:a copy -vn -ss 3.6 -t $hours:$minutes:$seconds "$filename.mp4"
  if [[ $? != 0 ]]; then
    echo "Failed decoding ($FFMPEG -activation_bytes $hexkey -i $filepath -c:a copy -vn -ss 3.6 -t $hours:$minutes:$seconds $filename.mp4)"
    exit 1
  fi

done
