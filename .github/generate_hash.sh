#!/bin/bash
#
# Generate hash for artifacts (e.g. dmg, deb files) built by CI to downloads.mixxx.org.

set -eu -o pipefail

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
    echo "Generating hash for artifact: ${FILEPATH}"
    FILENAME="$(basename "${FILEPATH}")"
    FILENAME_HASH="${FILENAME}.sha256sum"
    FILEPATH_HASH="${FILEPATH}.sha256sum"

    # There should be no path components in the shasum file, so we need to cd to it first.
    pushd "$(dirname "$(realpath "${FILEPATH}")")"
    sha256sum "${FILENAME}" > "${FILENAME_HASH}"
    popd
done
