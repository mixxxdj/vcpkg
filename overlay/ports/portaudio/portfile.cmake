vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PortAudio/portaudio
    REF 2dc8b6eb17ac5fda1f89722cfa0889bfc6e73434
    SHA512 4fba8fa433f09fc742db7229607d56efbdac43adf1ca2e3c4bb095a0a09aa58783bf9cc3f390f3a0c2d3276ad6b002614d9f71efa830f737ecab4e3d63539934
    PATCHES
        enable_jack_on_windows.patch
        pa_initalize_recursive_guard.patch
        wasapi_loopback.patch
)

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} dynamic PA_BUILD_SHARED)
string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} static PA_BUILD_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    asio PA_USE_ASIO
    jack PA_USE_JACK
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPA_USE_DS=ON
        -DPA_USE_WASAPI=ON
        -DPA_USE_WDMKS=ON
        -DPA_USE_WMME=ON
        -DPA_LIBNAME_ADD_SUFFIX=OFF
        -DPA_BUILD_SHARED=${PA_BUILD_SHARED}
        -DPA_BUILD_STATIC=${PA_BUILD_STATIC}
        -DPA_DLL_LINK_WITH_STATIC_RUNTIME=OFF
    OPTIONS_DEBUG
        -DPA_ENABLE_DEBUG_OUTPUT:BOOL=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
