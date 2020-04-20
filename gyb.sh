#!/usr/bin/env bash

usage() {
  cat <<-USAGE
gyb.sh (email_address) [gyb_commands]
Runs a Dockerized instance of gyb.

ARGUMENTS:

  email_address       The email address to run gyb against.

NOTES:

- If you've set up GYB in the past and have a 'client_secrets.json' file,
  copy it into the $HOME/.gyb/\${email_address}_credentials/ directory.
USAGE
}

if test -z "$1"
then
  usage
  exit 1
fi
email_address="${1?Please provide an email address.}"
shift
export LOCAL_FOLDER="$HOME/.gyb/${email_address}"
export CREDENTIALS_FOLDER="$HOME/.gyb/${email_address}_credentials"
export EMAIL_ADDRESS="$email_address"
mkdir -p "$LOCAL_FOLDER" 2>/dev/null
mkdir -p "$CREDENTIALS_FOLDER" 2>/dev/null
if ! test -f "${CREDENTIALS_FOLDER}/client_secrets.json"
then
  touch "${CREDENTIALS_FOLDER}/client_secrets.json"
  touch "${CREDENTIALS_FOLDER}/email.cfg"
  >&2 echo "INFO: You need to set up GYB. Let's do that first."

  # We have to copy the client_secrets.json file out of the container because gyb
  # refuses to create a new project if this file exists but Docker will create
  # the file as a directory if the file used by the volume mount doesn't exist.
  # https://github.com/jay0lee/got-your-back/blob/master/gyb.py#L911-L913
  docker-compose -f "$(dirname $0)/docker-compose.yml" run --user root \
    gyb-without-project \
      "$(echo "./gyb --email ${email_address} \
--local-folder /tmp/local_folder \
--action create-project" | base64 -)"

  docker ps -a | \
    grep gyb-without-project | \
    awk '{print $1}' | \
    head -1 | \
    xargs -I {} sh -c "docker start {} && \
docker exec {} sh -c 'cat /usr/local/bin/gyb/client_secrets.json'" > "${CREDENTIALS_FOLDER}/client_secrets.json"

  docker ps -a | \
    grep gyb-without-project | \
    awk '{print $1}' | \
    head -1 | \
    xargs -I {} sh -c "docker start {} && \
docker exec {} sh -c 'cat /usr/local/bin/gyb/oauth2service.json' " > "${CREDENTIALS_FOLDER}/oauth2service.json"
fi

docker-compose -f "$(dirname $0)/docker-compose.yml" run --user root \
  gyb \
  "$(echo "./gyb --email ${email_address} --local-folder /tmp/local_folder ${@:1}" | base64 -)"
