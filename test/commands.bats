#!/usr/bin/env bats

load test_helper

@test "commands" {
  run renv-commands
  assert_success
  assert_line "init"
  assert_line "rehash"
  assert_line "shell"
  refute_line "sh-shell"
  assert_line "echo"
}

@test "commands --sh" {
  run renv-commands --sh
  assert_success
  refute_line "init"
  assert_line "shell"
}

@test "commands in path with spaces" {
  path="${RENV_TEST_DIR}/my commands"
  cmd="${path}/renv-sh-hello"
  mkdir -p "$path"
  touch "$cmd"
  chmod +x "$cmd"

  PATH="${path}:$PATH" run renv-commands --sh
  assert_success
  assert_line "hello"
}

@test "commands --no-sh" {
  run renv-commands --no-sh
  assert_success
  assert_line "init"
  refute_line "shell"
}
