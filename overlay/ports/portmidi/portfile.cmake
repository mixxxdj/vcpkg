vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PortMidi/portmidi
    REF "928520f7b79f371854387cb480b4e3b5bf5dac95"
    SHA512 e5ba3f794d8c9b86099d7ec23eb662202a2c8a405e01e06b6dca6eda9d10c04d5ad94b6998b0ece428ed34837b72695d459dfb0a9d81ce178422398f38860933
    HEAD_REF master
    PATCHES
        "ios-support.patch" # Upstream PR: https://github.com/PortMidi/portmidi/pull/65
        "android-support.patch"
)

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(PM_USE_STATIC_RUNTIME ON)
else()
    set(PM_USE_STATIC_RUNTIME OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPM_USE_STATIC_RUNTIME="${PM_USE_STATIC_RUNTIME}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/PortMidi)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
