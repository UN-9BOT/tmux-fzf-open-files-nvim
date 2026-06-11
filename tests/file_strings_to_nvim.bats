#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/../scripts/file_strings_to_nvim.sh"

@test "should return files tabedit with line numbers" {
  result="$(to_tabedit_strings "/home/somefile.ts
  /home/file-with_ln:13:536")"
  expected_result="tabedit /home/somefile.ts | tabedit +call\ cursor(13,536) /home/file-with_ln |"

  result=$(echo "$result" | xargs)
  expected_result=$(echo "$expected_result" | xargs)

  [ "$result" = "$expected_result" ]
}

@test "should parse :Lline format" {
  result="$(to_tabedit_strings "/home/file.py:L99")"
  expected_result="tabedit +call\ cursor(99,1) /home/file.py |"

  result=$(echo "$result" | xargs)
  expected_result=$(echo "$expected_result" | xargs)

  [ "$result" = "$expected_result" ]
}

@test "should parse (line, column) format" {
  result="$(to_tabedit_strings "/home/file.py(45, 20)")"
  expected_result="tabedit +call\ cursor(45,20) /home/file.py |"

  result=$(echo "$result" | xargs)
  expected_result=$(echo "$expected_result" | xargs)

  [ "$result" = "$expected_result" ]
}

@test "should parse (line) format" {
  result="$(to_tabedit_strings "/home/file.py(45)")"
  expected_result="tabedit +call\ cursor(45,1) /home/file.py |"

  result=$(echo "$result" | xargs)
  expected_result=$(echo "$expected_result" | xargs)

  [ "$result" = "$expected_result" ]
}

@test "should parse :line format" {
  result="$(to_tabedit_strings "/home/file.py:42")"
  expected_result="tabedit +call\ cursor(42,1) /home/file.py |"

  result=$(echo "$result" | xargs)
  expected_result=$(echo "$expected_result" | xargs)

  [ "$result" = "$expected_result" ]
}

@test "should handle space before location format" {
  result="$(to_tabedit_strings "/home/file.py :99")"
  expected_result="tabedit +call\ cursor(99,1) /home/file.py |"

  result=$(echo "$result" | xargs)
  expected_result=$(echo "$expected_result" | xargs)

  [ "$result" = "$expected_result" ]
}
