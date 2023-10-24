vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    GITHUB_HOST https://codeberg.org
    REPO soundtouch/soundtouch
    REF 2.3.1
    SHA512 016717c9539acf8f59b74dc1e70a4ffe628f923db2d23a7d71d9544a6b23b5aa602d2cf3f18f990647d996b2ab46e53756e4eddee9e2e6539e1704e8fa5f3519
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    soundstretch SOUNDSTRETCH
    soundtouchdll SOUNDTOUCH_DLL
)

if(SOUNDTOUCH_DLL)
  vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SoundTouch)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if(SOUNDSTRETCH)
  vcpkg_copy_tools(TOOL_NAMES soundstretch AUTO_CLEAN)
endif()

file(INSTALL "${SOURCE_PATH}/COPYING.TXT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
