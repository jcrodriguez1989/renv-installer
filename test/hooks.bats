#!/usr/bin/env bats

load test_helper

@test "prints usage help given no argument" {
  run renv-hooks
  assert_failure "Usage: renv hooks <command>"
}

@test "prints list of hooks" {
  path1="${RENV_TEST_DIR}/renv.d"
  path2="${RENV_TEST_DIR}/etc/renv_hooks"
  RENV_HOOK_PATH="$path1"
  create_hook exec "hello.bash"
  create_hook exec "ahoy.bash"
  create_hook exec "invalid.sh"
  create_hook which "boom.bash"
  RENV_HOOK_PATH="$path2"
  create_hook exec "bueno.bash"

  RENV_HOOK_PATH="$path1:$path2" run renv-hooks exec
  assert_success
  assert_output <<OUT
${RENV_TEST_DIR}/renv.d/exec/ahoy.bash
${RENV_TEST_DIR}/renv.d/exec/hello.bash
${RENV_TEST_DIR}/etc/renv_hooks/exec/bueno.bash
OUT
}

@test "supports hook paths with spaces" {
  path1="${RENV_TEST_DIR}/my hooks/renv.d"
  path2="${RENV_TEST_DIR}/etc/renv hooks"
  RENV_HOOK_PATH="$path1"
  create_hook exec "hello.bash"
  RENV_HOOK_PATH="$path2"
  create_hook exec "ahoy.bash"

  RENV_HOOK_PATH="$path1:$path2" run renv-hooks exec
  assert_success
  assert_output <<OUT
${RENV_TEST_DIR}/my hooks/renv.d/exec/hello.bash
${RENV_TEST_DIR}/etc/renv hooks/exec/ahoy.bash
OUT
}

@test "resolves relative paths" {
  RENV_HOOK_PATH="${RENV_TEST_DIR}/renv.d"
  create_hook exec "hello.bash"
  mkdir -p "$HOME"

  RENV_HOOK_PATH="${HOME}/../renv.d" run renv-hooks exec
  assert_success "${RENV_TEST_DIR}/renv.d/exec/hello.bash"
}

@test "resolves symlinks" {
  path="${RENV_TEST_DIR}/renv.d"
  mkdir -p "${path}/exec"
  mkdir -p "$HOME"
  touch "${HOME}/hola.bash"
  ln -s "../../home/hola.bash" "${path}/exec/hello.bash"
  touch "${path}/exec/bright.sh"
  ln -s "bright.sh" "${path}/exec/world.bash"

  RENV_HOOK_PATH="$path" run renv-hooks exec
  assert_success
  assert_output <<OUT
${HOME}/hola.bash
${RENV_TEST_DIR}/renv.d/exec/bright.sh
OUT
}
