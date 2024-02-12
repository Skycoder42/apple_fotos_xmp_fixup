#!/bin/bash
set -exo pipefail

exiftool -CreateDate -OffsetTimeOriginal -d "%Y-%m-%dT%H:%M:%S" "Test_2 - 1.png"

# exiftool -AllDates="2023:12:12 12:12:12" "Test_2 - 1.png"

# exiftool "Test_2 - 1.png"

# exiftool -SubSecDateTimeOriginal="2022:12:12 12:00:00.24-08:00" /path/to/files/

