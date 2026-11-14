#!/usr/bin/env bash
# Check that the host tools under <dir> only need version nodes this build
# host provides.
#
# Host tools restored from the NuGet binary cache may have been built on a
# newer host and require a newer glibc or libstdc++, which would fail as soon
# as the AppImage build invokes them. The acceptable versions are taken from
# this host's own libc, libstdc++ and libgcc_s (located via ldconfig), so the
# floor follows the host and holds no hardcoded values.
#
# Reference data only (version requirements), not definitions, is inspected on
# the audited files, so a tool that merely *exports* GLIBCXX_-versioned symbols
# is not misreported. Definitions of the host libraries are the "provided" set.
#
# Usage: check_buildenv_floor.sh <dir>

set -euo pipefail

[ $# -eq 1 ] || { echo "usage: $0 <dir>" >&2; exit 2; }
dir="$1"
[ -d "$dir" ] || { echo "error: audited directory not found: $dir" >&2; exit 2; }

ldconfig_cmd=""
for c in "$(command -v ldconfig 2>/dev/null)" /usr/sbin/ldconfig /sbin/ldconfig; do
    [ -n "$c" ] && [ -x "$c" ] && { ldconfig_cmd="$c"; break; }
done
[ -n "$ldconfig_cmd" ] || { echo "cannot locate ldconfig" >&2; exit 2; }

# Primary triplet so multilib paths (i386 on x86_64, etc.) are skipped.
triplet=""
case "$(uname -m)" in
    x86_64)        triplet="x86_64-linux-gnu" ;;
    aarch64|arm64) triplet="aarch64-linux-gnu" ;;
esac

locate_lib() {
    # $1: exact soname, e.g. libstdc++.so.6. grep -F, no regex escaping.
    local soname="$1"
    local out
    if [ -n "$triplet" ]; then
        out=$("$ldconfig_cmd" -p | grep -F "${triplet}/${soname}" | awk '{print $NF}' | head -n1)
    else
        out=$("$ldconfig_cmd" -p | grep -F "${soname}" | awk '{print $NF}' | head -n1)
    fi
    printf '%s\n' "$out"
}

libc="$(locate_lib 'libc.so.6')"
[ -n "$libc" ] || { echo "cannot locate host libc" >&2; exit 2; }
libstdcpp="$(locate_lib 'libstdc++.so.6')"
[ -n "$libstdcpp" ] || { echo "cannot locate host libstdc++" >&2; exit 2; }
libgcc_s="$(locate_lib 'libgcc_s.so.1')"
[ -n "$libgcc_s" ] || { echo "cannot locate host libgcc_s" >&2; exit 2; }

# Version nodes the host provides: definition data of the host libraries.
namespaces='(GLIBC|GLIBCXX|CXXABI|GCC)_[0-9.]+'
provided_nodes() {
    readelf --version-info "$1" 2>/dev/null \
        | awk '/\.gnu\.version_d/{f=1; next} /\.gnu\.version_r/{f=0} f' \
        | grep -oE "$namespaces" | sort -u || true
}
declare -A prov
while IFS= read -r node; do
    [ -n "$node" ] && prov["$node"]=1
done < <(provided_nodes "$libc"; provided_nodes "$libstdcpp"; provided_nodes "$libgcc_s")

# Version nodes the audited files reference: requirement data only.
required_nodes() {
    readelf --version-info "$1" 2>/dev/null \
        | awk '/\.gnu\.version_r/{f=1; next} f' \
        | grep -oE "$namespaces" | sort -u || true
}

fail=0
while IFS= read -r -d '' f; do
    file "$f" | grep -q ELF || continue
    while read -r node; do
        [ -n "$node" ] || continue
        if [ -z "${prov[$node]+1}" ]; then
            echo "floor violation: $f requires $node, the host does not provide it" >&2
            fail=1
        fi
    done < <(required_nodes "$f")
done < <(find "$dir" -type f -print0)

if [ "$fail" != 0 ]; then
    echo "restored host tools require newer glibc/libstdc++/libgcc_s nodes than this host provides" >&2
    exit 1
fi
echo "$dir: host tools meet this host's ABI floor"