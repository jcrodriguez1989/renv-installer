#!/usr/bin/env bats

load test_helper

@test "default" {
  run renv-global
  assert_success
  assert_output "system"
}

@test "read RENV_ROOT/version" {
  mkdir -p "$RENV_ROOT"
  echo "1.2.3" > "$RENV_ROOT/version"
  run renv-global
  assert_success
  assert_output "1.2.3"
}

@test "set RENV_ROOT/version" {
  mkdir -p "$RENV_ROOT/versions/1.2.3"
  run renv-global "1.2.3"
  assert_success
  run renv-global
  assert_success "1.2.3"
}

@test "fail setting invalid RENV_ROOT/version" {
  mkdir -p "$RENV_ROOT"
  run renv-global "1.2.3"
  assert_failure "renv: version \`1.2.3' not installed"
}
