#!/usr/bin/env bash

# Parse different location formats and extract line and column numbers
# Supports: :line:col, :line, :Lline, (line), (line, col)
parse_location() {
  local location="$1"
  local line=""
  local col=""
  
  # Remove leading/trailing whitespace
  location="$(echo "$location" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  
  # Match :line:col format
  if [[ $location =~ ^:([0-9]+):([0-9]+)$ ]]; then
    line="${BASH_REMATCH[1]}"
    col="${BASH_REMATCH[2]}"
  # Match :line format
  elif [[ $location =~ ^:([0-9]+)$ ]]; then
    line="${BASH_REMATCH[1]}"
    col="1"
  # Match :Lline format
  elif [[ $location =~ ^:L([0-9]+)$ ]]; then
    line="${BASH_REMATCH[1]}"
    col="1"
  # Match (line, col) format
  elif [[ $location =~ ^\(([0-9]+)[[:space:]]*,[[:space:]]*([0-9]+)\)$ ]]; then
    line="${BASH_REMATCH[1]}"
    col="${BASH_REMATCH[2]}"
  # Match (line) format
  elif [[ $location =~ ^\(([0-9]+)\)$ ]]; then
    line="${BASH_REMATCH[1]}"
    col="1"
  fi
  
  echo "$line:$col"
}

to_tabedit_strings() {
  files="$1"
  result=""
  
  while IFS= read -r line; do
    # Remove leading/trailing whitespace
    line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [ -z "$line" ] && continue
    
    # Try to extract file path and location info
    # Match pattern: filepath (with optional space) :line:col or :line or :Lline or (line) or (line, col)
    if [[ $line =~ ^([^:()]+)\ ?(:[0-9]+:[0-9]+|:[0-9]+|:L[0-9]+|\([0-9]+( ?, ?[0-9]+)?\))?$ ]]; then
      filepath="${BASH_REMATCH[1]}"
      location="${BASH_REMATCH[2]}"
      
      # Remove trailing space from filepath
      filepath="${filepath%% }"
      
      if [ -z "$location" ]; then
        result+="tabedit $filepath |"
      else
        local_info=$(parse_location "$location")
        line_num="${local_info%:*}"
        col_num="${local_info#*:}"
        result+="tabedit +call\\ cursor($line_num,$col_num) $filepath |"
      fi
    else
      # No location info, just open file
      result+="tabedit $line |"
    fi
  done <<<"$files"
  
  # Convert to space-separated format with trailing pipe
  echo "$result" | sed 's/|/ | /g'
}
