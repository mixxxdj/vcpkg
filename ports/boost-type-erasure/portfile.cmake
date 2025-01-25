# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/type_erasure
    REF boost-${VERSION}
    SHA512 48c24dafdd631057b09c11fc790cee8674211ee21296e1880bd6211f094f409c15a25b453b5914fd89456730d6e42bd7e123376fab6f6c3093b4b788c5141e18
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
