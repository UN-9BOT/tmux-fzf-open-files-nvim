#!/usr/bin/env bash

# awk for anything that resembles a file path with a file extension on the end.
# only return unique paths using seen
# modified this to allow for incremental parsing using streaming.
# intended use is through a pipe like: tmux capture-pane | parse-files
parse_files() {
  LC_ALL=C awk '
  BEGIN { RS = "\n"; FS = ""; }
  {
    while (match($0, /@?[^[:space:]"]*\/[[:alnum:]._-]+(\/[[:alnum:]._-]+)*\.[[:alnum:]]+( ?)?(:[0-9]+:[0-9]+|:[0-9]+|:L[0-9]+|\([0-9]+( ?, ?[0-9]+)?\))?/)) {
      match_str = substr($0, RSTART, RLENGTH)
      # Extract just the file path (without @ and without location info)
      match(match_str, /^@?[^[:space:]"]*\/[[:alnum:]._-]+(\/[[:alnum:]._-]+)*\.[[:alnum:]]+/)
      path = substr(match_str, 1, RLENGTH)
      # Remove @ prefix if present
      if (substr(path, 1, 1) == "@") {
        path = substr(path, 2)
      }
      # Extract location info (everything after the file path, excluding the space)
      if (substr(match_str, 1, 1) == "@") {
        location_info = substr(match_str, length(path) + 2)
      } else {
        location_info = substr(match_str, length(path) + 1)
      }
      # Remove trailing space from location_info
      gsub(/[[:space:]]+$/, "", location_info)
      norm = ""
      loc = location_info
      sub(/^[[:space:]]+/, "", loc)
      if (loc ~ /^:[0-9]+:[0-9]+$/) {
        split(substr(loc, 2), parts, ":")
        norm = ":" parts[1] ":" parts[2]
      } else if (loc ~ /^:[0-9]+$/) {
        norm = ":" substr(loc, 2)
      } else if (loc ~ /^:L[0-9]+$/) {
        norm = ":" substr(loc, 3)
      } else if (loc ~ /^\([0-9]+[[:space:]]*,[[:space:]]*[0-9]+\)$/) {
        tmp = substr(loc, 2, length(loc) - 2)
        gsub(/[[:space:]]*/, "", tmp)
        split(tmp, parts, ",")
        norm = ":" parts[1] ":" parts[2]
      } else if (loc ~ /^\([0-9]+\)$/) {
        norm = ":" substr(loc, 2, length(loc) - 2)
      } else if (loc != "") {
        norm = loc
      }
      key = path norm
      output = path location_info
      if (!seen[key]++) {
        print output
      }
      $0 = substr($0, RSTART + RLENGTH)  # Skip the matched part
    }
  }'
}

# remove invalid file path characters by using gsub with an allow list regular expression
# temporarily override locale settings for awk command
remove_invalid_characters() {
  LC_ALL=C awk '{ gsub(/[^[:alnum:][:space:].:_~\/-]/, "", $0); print }'
}
