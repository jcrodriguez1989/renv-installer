#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${RENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "finds versions where present" {
  create_executable "2.7" "R"
  create_executable "2.7" "fab"
  create_executable "3.4" "R"
  create_executable "3.4" "R.test"

  run renv-whence R
  assert_success
  assert_output <<OUT
2.7
3.4
OUT

  run renv-whence fab
  assert_success "2.7"

  run renv-whence R.test
  assert_success "3.4"
}
