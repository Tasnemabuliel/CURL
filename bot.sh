#!/bin/bash
mkdir -p output

echo "Starting data extraction..."
log_file="output/summary.txt"
echo " Summary of Extracted Data – $(date)" > "$log_file"
echo "--------------------------------------" >> "$log_file"

# פונקציה לשליפת תוכן
fetch_and_extract() {
  local label="$1"
  local url="$2"
  local pattern="$3"
  local file="$4"

  echo " Fetching $label..."
  curl -s -A "Mozilla/5.0" "$url" > "$file"

  echo " Extracting $label..."
  grep -Eo "$pattern" "$file" > "${file%.html}.txt"

  if [ ! -s "${file%.html}.txt" ]; then
    echo " No $label found." >> "${file%.html}.txt"
  fi

  echo " $label:" >> "$log_file"
  cat "${file%.html}.txt" >> "$log_file"
  echo "" >> "$log_file"
}

# 1. Date from timeanddate.com
fetch_and_extract "Date" "https://www.timeanddate.com" '[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}' output/date.html

# 2. IP Address from whatismyip.com
fetch_and_extract "IP Address" "https://www.whatismyip.com" '([0-9]{1,3}\.){3}[0-9]{1,3}' output/ip.html

# 3. Headline from Ynet
fetch_and_extract "Headline" "https://www.ynet.co.il" '<title>[^<]+</title>' output/ynet.html

# 4. Download link from Bugzilla
fetch_and_extract "Download Link" "https://www.bugzilla.org" 'href="[^"]+\.zip"' output/bugzilla.html

# 5. Tutorial name from JMeter
fetch_and_extract "Tutorial Title" "https://jmeter.apache.org" '(?i)tutorial[^<]+' output/jmeter.html

# 6. Student names from Moodle
fetch_and_extract "Student Names" "https://moodle.sce.ac.il" '[A-Z][a-z]+\s[A-Z][a-z]+' output/moodle.html

# 7. NFT jobs from LinkedIn
fetch_and_extract "NFT Jobs" "https://www.linkedin.com/jobs" 'NFT[^<]+' output/linkedin.html

# 8. Books from Amazon
fetch_and_extract "Books" "https://www.amazon.com" 'software[^<]*non[^<]*functional[^<]*testing' output/amazon.html

echo "Extraction finished. See output/summary.txt for full results."
