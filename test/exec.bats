#!/usr/bin/env bats

load test_helper

create_executable() {
  name="${1?}"
  shift 1
  bin="${RENV_ROOT}/versions/${RENV_VERSION}/bin"
  mkdir -p "$bin"
  { if [ $# -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed -Ee '1s/^ +//' > "${bin}/$name"
  chmod +x "${bin}/$name"
}

@test "fails with invalid version" {
  export RENV_VERSION="3.4"
  run renv-exec R -V
  assert_failure "renv: version \`3.4' is not installed (set by RENV_VERSION environment variable)"
}

@test "fails with invalid version set from file" {
  mkdir -p "$RENV_TEST_DIR"
  cd "$RENV_TEST_DIR"
  echo 2.7 > .R-version
  run renv-exec rspec
  assert_failure "renv: version \`2.7' is not installed (set by $PWD/.R-version)"
}

@test "completes with names of executables" {
  export RENV_VERSION="3.4"
  create_executable "fab" "#!/bin/sh"
  create_executable "R" "#!/bin/sh"

  renv-rehash
  run renv-completions exec
  assert_success
  assert_output <<OUT
--help
fab
R
OUT
}

@test "carries original IFS within hooks" {
  create_hook exec hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export RENV_VERSION=system
  IFS=$' \t\n' run renv-exec env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "forwards all arguments" {
  export RENV_VERSION="3.4"
  create_executable "R" <<SH
#!$BASH
echo \$0
for arg; do
  # hack to avoid bash builtin echo which can't output '-e'
  printf "  %s\\n" "\$arg"
done
SH

  run renv-exec R -w "/path to/R script.rb" -- extra args
  assert_success
  assert_output <<OUT
${RENV_ROOT}/versions/3.4/bin/R
  -w
  /path to/R script.rb
  --
  extra
  args
OUT
}
