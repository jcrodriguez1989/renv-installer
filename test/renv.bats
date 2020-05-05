#!/usr/bin/env bats

load test_helper

@test "blank invocation" {
  run renv
  assert_failure
  assert_line 0 "$(renv---version)"
}

@test "invalid command" {
  run renv does-not-exist
  assert_failure
  assert_output "renv: no such command \`does-not-exist'"
}

@test "default RENV_ROOT" {
  RENV_ROOT="" HOME=/home/mislav run renv root
  assert_success
  assert_output "/home/mislav/.renv"
}

@test "inherited RENV_ROOT" {
  RENV_ROOT=/opt/renv run renv root
  assert_success
  assert_output "/opt/renv"
}

@test "default RENV_DIR" {
  run renv echo RENV_DIR
  assert_output "$(pwd)"
}

@test "inherited RENV_DIR" {
  dir="${BATS_TMPDIR}/myproject"
  mkdir -p "$dir"
  RENV_DIR="$dir" run renv echo RENV_DIR
  assert_output "$dir"
}

@test "invalid RENV_DIR" {
  dir="${BATS_TMPDIR}/does-not-exist"
  assert [ ! -d "$dir" ]
  RENV_DIR="$dir" run renv echo RENV_DIR
  assert_failure
  assert_output "renv: cannot change working directory to \`$dir'"
}

@test "adds its own libexec to PATH" {
  run renv echo "PATH"
  assert_success "${BATS_TEST_DIRNAME%/*}/libexec:$PATH"
}

@test "adds plugin bin dirs to PATH" {
  mkdir -p "$RENV_ROOT"/plugins/R-build/bin
  mkdir -p "$RENV_ROOT"/plugins/renv-each/bin
  run renv echo -F: "PATH"
  assert_success
  assert_line 0 "${BATS_TEST_DIRNAME%/*}/libexec"
  assert_line 1 "${RENV_ROOT}/plugins/renv-each/bin"
  assert_line 2 "${RENV_ROOT}/plugins/R-build/bin"
}

@test "RENV_HOOK_PATH preserves value from environment" {
  RENV_HOOK_PATH=/my/hook/path:/other/hooks run renv echo -F: "RENV_HOOK_PATH"
  assert_success
  assert_line 0 "/my/hook/path"
  assert_line 1 "/other/hooks"
  assert_line 2 "${RENV_ROOT}/renv.d"
}

@test "RENV_HOOK_PATH includes renv built-in plugins" {
  unset RENV_HOOK_PATH
  run renv echo "RENV_HOOK_PATH"
  assert_success "${RENV_ROOT}/renv.d:${BATS_TEST_DIRNAME%/*}/renv.d:/usr/local/etc/renv.d:/etc/renv.d:/usr/lib/renv/hooks"
}
