#!/usr/bin/env bash
base64_encoded_command="${1?Please provide a command; ensure that it is base64 encoded.}"

echo "Running: $(echo "$base64_encoded_command" | base64 -d -)"
eval $(echo "$base64_encoded_command" | base64 -d -)
