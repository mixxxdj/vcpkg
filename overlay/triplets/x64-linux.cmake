set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_CMAKE_SYSTEM_NAME Linux)

# glib must be shared to avoid a constructor ordering crash when
# statically linked alongside FFmpeg via LINK_GROUP:RESCAN.
# fontconfig, freetype, harfbuzz, alsa and jack2 must be shared too,
# because the AppImage build delegates them to the host system.
if(PORT MATCHES "^(glib|fontconfig|freetype|harfbuzz|alsa|jack2)$")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
