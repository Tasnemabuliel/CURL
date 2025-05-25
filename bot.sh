#!/bin/bash
mkdir -p output

echo "Starting data extraction..."
log_file="output/summary.txt"
echo " Summary of Extracted Data – $(date)" > "$log_file"
echo "--------------------------------------" >> "$log_file"

# Function to extract and log
extract_and_log() {
  local label="$1"
  local command="$2"
  local outfile="$3"

  echo " Extracting $label..."
  eval "$command" > "$outfile"

  if [ ! -s "$outfile" ]; then
    echo " No $label found or site uses JS." > "$outfile"
  fi

  echo " $label:" >> "$log_file"
  cat "$outfile" >> "$log_file"
  echo "" >> "$log_file"
}

# 1. Date using timeapi.io + jq
extract_and_log "Date" "curl -s 'https://www.timeapi.io/api/Time/current/zone?timeZone=Israel' | jq -r '.dateTime'" output/date.txt

# 2. IP Address
extract_and_log "IP Address" "curl -s https://checkip.amazonaws.com" output/ip.txt

# 3. Headline from BBC
extract_and_log "Headline" "curl -s https://www.bbc.com/news | grep -oP '<title>\\K[^<]+' | head -n 1" output/bbc.txt

# 4. Download Link (mozilla FTP)
extract_and_log "Download Link" "curl -sL 'https://ftp.mozilla.org/pub/security/nss/releases/NSS_3_98_RTM/src/nss-3.98.tar.gz' | grep -oP 'href=\\"\\K[^\\"]+\\.(zip|tar\\.gz)' | head -n 1" output/bugzilla.txt

# 5. Tutorial Title from JMeter manual
extract_and_log "Tutorial Title" "curl -s https://jmeter.apache.org/usermanual/index.html | grep -i -o 'Tutorial' | head -n 1" output/jmeter.txt

# 6. Student Names using RandomUser API + jq
extract_and_log "Student Names" "curl -s 'https://randomuser.me/api/?results=5&nat=us' | jq -r '.results[] | \"\(.name.first) \(.name.last)\"'" output/students.txt

# 7. NFT Jobs from Remotive API
extract_and_log "NFT Jobs" "curl -s 'https://remotive.io/api/remote-jobs?search=qa' | jq -r '.jobs[] | .title' | head -n 3"

# 8. Books from Google Books API
extract_and_log "Books" "curl -s 'https://www.googleapis.com/books/v1/volumes?q=non+functional+testing' | jq -r '.items[].volumeInfo.title' | head -n 3" output/books.txt

echo "Extraction finished. See output/summary.txt for full results."
