#!/usr/bin/env bash
GYB_SRC_DIRECTORY=$HOME/src/gyb
GYB_SRC_URL=https://github.com/carlosonunez/gyb-docker

clone_gyb_repo_if_not_present() {
  if ! test -d "$GYB_SRC_DIRECTORY"
  then
    >&2 echo "INFO: gyb source dir not found; cloning."
    pushd "$HOME/src"
    git clone "$GYB_SRC_URL"
    mv gyb-docker gyb
    popd
  fi
}

run_gyb_command() {
  email_address="${1:-personal}"
  export LOCAL_FOLDER="$HOME/.gyb/${email_address}"
  mkdir -p "$LOCAL_FOLDER" 2>/dev/null
  docker-compose -f "${GYB_SRC_DIRECTORY}/docker-compose.yml" run --rm gyb
}

clone_gyb_repo_if_not_present &&
run_gyb_command
