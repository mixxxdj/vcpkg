vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PortAudio/portaudio
    REF b0cc303e95fdb7c6c953337051378071c9043e88
    SHA512 fa7b40604ed97c1c5157c4faeb2188e7bbbddd06752811ff8d3facd30151e2f9104737210b7df21cf0f5c0661b28eb6db9b51da09cf015924b4e56835c111c46
    PATCHES
        "0001-Add-basic-support-for-iOS-to-portaudio.patch"
        "0002-Update-CMakeLists-with-iOS-implementation.patch"
        "0003-Fix-renamed-memory-allocation-functions.patch"
        "0004-Add-Android-OBOE.patch" # https://github.com/PortAudio/portaudio/pull/1084
)

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} dynamic PA_BUILD_SHARED)
string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} static PA_BUILD_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    asio PA_USE_ASIO
    jack PA_USE_JACK
)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Android")
    set(FEATURE_OPTIONS 
        ${FEATURE_OPTIONS}
        -DOBOE_LIBRARIES=${CURRENT_INSTALLED_DIR}/lib/liboboe.a
        -DOBOE_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/
    )
endif()

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
