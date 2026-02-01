#!/usr/bin/env bash
#
# Deploy artifacts (e.g. dmg, deb files) built by CI to downloads.mixxx.org.

set -Eeuo pipefail

[ -z "${SSH_HOST}" ] && echo "Please set the SSH_HOST env var." >&2 && exit 1
[ -z "${SSH_KEY}" ] && echo "Please set the SSH_KEY env var." >&2 && exit 1
[ -z "${SSH_PASSWORD}" ] && echo "Please set the SSH_PASSWORD env var." >&2 && exit 1
[ -z "${SSH_USER}" ] && echo "Please set the SSH_USER env var." >&2 && exit 1
[ -z "${UPLOAD_ID}" ] && echo "Please set the UPLOAD_ID env var." >&2 && exit 1
[ -z "${OS}" ] && echo "Please set the OS env var." >&2 && exit 1
[ -z "${DESTDIR}" ] && echo "Please set the DESTDIR env var." >&2 && exit 1

SSH="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
DEST_PATH="${DESTDIR}/${GIT_BRANCH}/${OS}"
TMP_PATH="../../.tmp/${UPLOAD_ID}"

echo "Deploying to ${TMP_PATH}, then to ${DEST_PATH}."

eval "$(ssh-agent -s)" >/dev/null

cleanup() {
  eval "$(ssh-agent -k)" >/dev/null
}
trap cleanup EXIT

# Add private key to SSH agent
ssh-add - <<< "${SSH_KEY}" >/dev/null

# realpath does not exist on macOS
command -v realpath >/dev/null 2>&1 || realpath() {
    [[ "$1" = /* ]] && echo "$1" || echo "${PWD}/${1#./}"
}

# sha256sum doesn't exist on Windows (Git Bash) or macOS
command -v sha256sum >/dev/null 2>&1 || sha256sum() {
    openssl dgst -sha256 "$@" | sed 's/^SHA256(\(.*\))= \(\w\+\)$/\2  \1/'
}

for FILEPATH in "$@"
do
    # Always upload to a temporary path.
    # This prevents users from downloading an incomplete file from the server which has not yet finished deploying.
    echo "Deploying artifact: ${FILEPATH}"
    FILENAME="$(basename "${FILEPATH}")"
    FILENAME_HASH="${FILENAME}.sha256sum"
    FILEPATH_HASH="${FILEPATH}.sha256sum"

    # There should be no path components in the shasum file, so we need to cd to it first.
    pushd "$(dirname "$(realpath "${FILEPATH}")")"
    sha256sum "${FILENAME}" > "${FILENAME_HASH}"
    popd

    FILEEXT="${FILENAME##*.}"
    
    # Ensure directories exist
    ${SSH} "${SSH_USER}@${SSH_HOST}" "mkdir -p '${DEST_PATH}' '${DEST_PATH}/${TMP_PATH}'"

    rsync -e "${SSH}" --partial --partial-dir="${TMP_PATH}" --delay-updates -r "${FILEPATH}" "${FILEPATH_HASH}" "${SSH_USER}@${SSH_HOST}:${DEST_PATH}"
done
