#!/bin/bash

set -euo pipefail

# Fail script if the env var is not exported.
: "${KBS_URL}:?"
: "${KBS_RESOURCE_ID}:?"
: "${SYMMETRIC_KEY_FILE:=/tmp/key.bin}"
: "${AA_RESOURCE_URL:=127.0.0.1:50001}"

: "${TARGET_FOLDER}:?"
: "${ENCRYPTED_FILE_URL}:?"

# Talk to attestation agent on the peer pod vm host, get the key file from KBS and store it in the `$SYMMETRIC_KEY_FILE` file.
echo "Doing attestation and getting key file from KBS"
grpcurl -proto getresource.proto -plaintext -d @ "${AA_RESOURCE_URL}" getresource.GetResourceService.GetResource <<EOM | jq -r '.Resource' | base64 -d >"${SYMMETRIC_KEY_FILE}"
{
  "ResourcePath": "${KBS_RESOURCE_ID}",
  "KbcName":"cc_kbc",
  "KbsUri": "${KBS_URL}"
}
EOM

echo "Attestation done, key file stored in ${SYMMETRIC_KEY_FILE}"

# Download the data.
echo "Downloading encrypted data ..."
tmp_file="$(mktemp)"
curl -L -o "${tmp_file}" "${ENCRYPTED_FILE_URL}"

export SOURCE_ENCRYPTED_FILE="${tmp_file}"

/workdir/decrypt-folder.sh
