#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/../scripts/awk_pane_files.sh"

@test "parse_files should return a file path" {
  result="$(echo "something more text here/is/a/file.txt more text" | parse_files)"
  [ "$result" = "here/is/a/file.txt" ]
}

@test "folder paths are ignored" {
  result="$(echo "something with /home/person/something/else" | parse_files)"
  [ "$result" = "" ]
}

@test "parse_files should return unique files only" {
  result="$(echo "/home/pete/file.txt
    /home/pete/file.txt
    /home/pete/file.txt
    /home/pete/file.txt" | parse_files)"
  [ "$result" = "/home/pete/file.txt" ]
}

@test "parse_files should return unique files only with multiple locations" {
  result="$(echo "/home/pete/file.py:10
    /home/pete/file.py:20" | parse_files)"
  expected="/home/pete/file.py:10
/home/pete/file.py:20"
  [ "$result" = "$expected" ]
}

@test "parse_files should dedup across line-only formats" {
  result="$(echo "/home/pete/file.py:99
    /home/pete/file.py:L99
    /home/pete/file.py(99)" | parse_files)"
  [ "$result" = "/home/pete/file.py:99" ]
}

@test "parse_files should dedup across line+col formats" {
  result="$(echo "/home/pete/file.py:99:1
    /home/pete/file.py(99, 1)" | parse_files)"
  [ "$result" = "/home/pete/file.py:99:1" ]
}

@test "parse_files should keep line and line+col distinct" {
  result="$(echo "/home/pete/file.py:99
    /home/pete/file.py:99:1" | parse_files)"
  expected="/home/pete/file.py:99
/home/pete/file.py:99:1"
  [ "$result" = "$expected" ]
}

@test "parse_files should return unique files only double prompt newline separated" {
  result="$(echo "❯ echo \"something/somethingelse.txt\"
    something/somethingelse.txt" | parse_files)"
  echo "$result"
  [ "$result" = "something/somethingelse.txt" ]
}

@test "remove invalid characters" {
  result="$(echo "(&&here/is-dashes-in-name/a/file.txt)" | remove_invalid_characters)"
  [ "$result" = "here/is-dashes-in-name/a/file.txt" ]
}

@test "remove invalid characters quotes" {
  result="$(echo "\"\"(&&here/is-dashes-in-name/a/file.txt)" | remove_invalid_characters)"
  [ "$result" = "here/is-dashes-in-name/a/file.txt" ]
}

@test "parse_files should handle :line:col format" {
  result="$(echo "src/file.py:86:12 more text" | parse_files)"
  [ "$result" = "src/file.py:86:12" ]
}

@test "parse_files should handle :line format" {
  result="$(echo "src/file.py:86 more text" | parse_files)"
  [ "$result" = "src/file.py:86" ]
}

@test "parse_files should handle :Lline format" {
  result="$(echo "src/file.py:L99 more text" | parse_files)"
  [ "$result" = "src/file.py:L99" ]
}

@test "parse_files should handle space before location format" {
  result="$(echo "src/file.py :86 more text" | parse_files)"
  [ "$result" = "src/file.py :86" ]
}

@test "parse_files should handle @ prefix with :Lline format" {
  result="$(echo "@src/file.py:L99 more text" | parse_files)"
  [ "$result" = "src/file.py:L99" ]
}

@test "parse_files should handle (line, col) format" {
  result="$(echo "src/file.py(45, 20) more text" | parse_files)"
  [ "$result" = "src/file.py(45, 20)" ]
}

@test "parse_files should handle (line) format" {
  result="$(echo "src/file.py(45) more text" | parse_files)"
  [ "$result" = "src/file.py(45)" ]
}
