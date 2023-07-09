set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)

# DjInterop has not yet a stable API. We link it statically to allow running 
# experimental Mixxx build without conflicts
if(${PORT} MATCHES "libdjinterop")
    set(VCPKG_LIBRARY_LINKAGE static)
else()
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

set(VCPKG_BUILD_TYPE release)
