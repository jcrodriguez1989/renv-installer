if [[ ! -o interactive ]]; then
    return
fi

compctl -K _renv renv

_renv() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(renv commands)"
  else
    completions="$(renv completions ${words[2,-2]})"
  fi

  reply=(${(ps:\n:)completions})
}
