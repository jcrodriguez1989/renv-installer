#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${RENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "empty rehash" {
  assert [ ! -d "${RENV_ROOT}/shims" ]
  run renv-rehash
  assert_success ""
  assert [ -d "${RENV_ROOT}/shims" ]
  rmdir "${RENV_ROOT}/shims"
}

@test "non-writable shims directory" {
  mkdir -p "${RENV_ROOT}/shims"
  chmod -w "${RENV_ROOT}/shims"
  run renv-rehash
  assert_failure "renv: cannot rehash: ${RENV_ROOT}/shims isn't writable"
}

@test "rehash in progress" {
  export RENV_REHASH_TIMEOUT=1
  mkdir -p "${RENV_ROOT}/shims"
  touch "${RENV_ROOT}/shims/.renv-shim"
  run renv-rehash
  assert_failure "renv: cannot rehash: ${RENV_ROOT}/shims/.renv-shim exists"
}

@test "wait until lock acquisition" {
  export RENV_REHASH_TIMEOUT=5
  mkdir -p "${RENV_ROOT}/shims"
  touch "${RENV_ROOT}/shims/.renv-shim"
  bash -c "sleep 1 && rm -f ${RENV_ROOT}/shims/.renv-shim" &
  run renv-rehash
  assert_success
}

@test "creates shims" {
  create_executable "2.7" "R"
  create_executable "2.7" "fab"
  create_executable "3.4" "R"
  create_executable "3.4" "R.test"

  assert [ ! -e "${RENV_ROOT}/shims/fab" ]
  assert [ ! -e "${RENV_ROOT}/shims/R" ]
  assert [ ! -e "${RENV_ROOT}/shims/R.test" ]

  run renv-rehash
  assert_success ""

  run ls "${RENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
fab
R
R.test
OUT
}

@test "removes stale shims" {
  mkdir -p "${RENV_ROOT}/shims"
  touch "${RENV_ROOT}/shims/oldshim1"
  chmod +x "${RENV_ROOT}/shims/oldshim1"

  create_executable "3.4" "fab"
  create_executable "3.4" "R"

  run renv-rehash
  assert_success ""

  assert [ ! -e "${RENV_ROOT}/shims/oldshim1" ]
}

@test "binary install locations containing spaces" {
  create_executable "dirname1 p247" "R"
  create_executable "dirname2 preview1" "R.test"

  assert [ ! -e "${RENV_ROOT}/shims/R" ]
  assert [ ! -e "${RENV_ROOT}/shims/R.test" ]

  run renv-rehash
  assert_success ""

  run ls "${RENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
R
R.test
OUT
}

@test "carries original IFS within hooks" {
  create_hook rehash hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  IFS=$' \t\n' run renv-rehash
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "sh-rehash in bash" {
  create_executable "3.4" "R"
  RENV_SHELL=bash run renv-sh-rehash
  assert_success "hash -r 2>/dev/null || true"
  assert [ -x "${RENV_ROOT}/shims/R" ]
}

@test "sh-rehash in fish" {
  create_executable "3.4" "R"
  RENV_SHELL=fish run renv-sh-rehash
  assert_success ""
  assert [ -x "${RENV_ROOT}/shims/R" ]
}
