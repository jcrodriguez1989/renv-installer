#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin
  if [[ $1 == */* ]]; then bin="$1"
  else bin="${RENV_ROOT}/versions/${1}/bin"
  fi
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "outputs path to executable" {
  create_executable "2.7" "R"
  create_executable "3.4" "R.test"

  RENV_VERSION=2.7 run renv-which R
  assert_success "${RENV_ROOT}/versions/2.7/bin/R"

  RENV_VERSION=3.4 run renv-which R.test
  assert_success "${RENV_ROOT}/versions/3.4/bin/R.test"

  RENV_VERSION=3.4:2.7 run renv-which R.test
  assert_success "${RENV_ROOT}/versions/3.4/bin/R.test"
}

@test "searches PATH for system version" {
  create_executable "${RENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${RENV_ROOT}/shims" "kill-all-humans"

  RENV_VERSION=system run renv-which kill-all-humans
  assert_success "${RENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims prepended)" {
  create_executable "${RENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${RENV_ROOT}/shims" "kill-all-humans"

  PATH="${RENV_ROOT}/shims:$PATH" RENV_VERSION=system run renv-which kill-all-humans
  assert_success "${RENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims appended)" {
  create_executable "${RENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${RENV_ROOT}/shims" "kill-all-humans"

  PATH="$PATH:${RENV_ROOT}/shims" RENV_VERSION=system run renv-which kill-all-humans
  assert_success "${RENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims spread)" {
  create_executable "${RENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${RENV_ROOT}/shims" "kill-all-humans"

  PATH="${RENV_ROOT}/shims:${RENV_ROOT}/shims:/tmp/non-existent:$PATH:${RENV_ROOT}/shims" \
    RENV_VERSION=system run renv-which kill-all-humans
  assert_success "${RENV_TEST_DIR}/bin/kill-all-humans"
}

@test "doesn't include current directory in PATH search" {
  mkdir -p "$RENV_TEST_DIR"
  cd "$RENV_TEST_DIR"
  touch kill-all-humans
  chmod +x kill-all-humans
  PATH="$(path_without "kill-all-humans")" RENV_VERSION=system run renv-which kill-all-humans
  assert_failure "renv: kill-all-humans: command not found"
}

@test "version not installed" {
  create_executable "3.4" "R.test"
  RENV_VERSION=3.3 run renv-which R.test
  assert_failure "renv: version \`3.3' is not installed (set by RENV_VERSION environment variable)"
}

@test "versions not installed" {
  create_executable "3.4" "R.test"
  RENV_VERSION=2.7:3.3 run renv-which R.test
  assert_failure <<OUT
renv: version \`2.7' is not installed (set by RENV_VERSION environment variable)
renv: version \`3.3' is not installed (set by RENV_VERSION environment variable)
OUT
}

@test "no executable found" {
  create_executable "2.7" "R.test"
  RENV_VERSION=2.7 run renv-which fab
  assert_failure "renv: fab: command not found"
}

@test "no executable found for system version" {
  PATH="$(path_without "rake")" RENV_VERSION=system run renv-which rake
  assert_failure "renv: rake: command not found"
}

@test "executable found in other versions" {
  create_executable "2.7" "R"
  create_executable "3.3" "R.test"
  create_executable "3.4" "R.test"

  RENV_VERSION=2.7 run renv-which R.test
  assert_failure
  assert_output <<OUT
renv: R.test: command not found

The \`R.test' command exists in these R versions:
  3.3
  3.4
OUT
}

@test "carries original IFS within hooks" {
  create_hook which hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  IFS=$' \t\n' RENV_VERSION=system run renv-which anything
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "discovers version from renv-version-name" {
  mkdir -p "$RENV_ROOT"
  cat > "${RENV_ROOT}/version" <<<"3.4"
  create_executable "3.4" "R"

  mkdir -p "$RENV_TEST_DIR"
  cd "$RENV_TEST_DIR"

  RENV_VERSION= run renv-which R
  assert_success "${RENV_ROOT}/versions/3.4/bin/R"
}
