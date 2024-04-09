set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)

# Mixxx loads fdk-aac dynamically at runtime. This allows the user to replace 
# the version of fdk-aac we ship which has the patent-encumbered HE-AAC 
#removed with another build that supports HE-AAC.
if(${PORT} MATCHES "fdk-aac")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
else()
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

set(VCPKG_CMAKE_SYSTEM_NAME Darwin)
set(VCPKG_OSX_ARCHITECTURES x86_64)

# Minimum supported macOS version as target platform for Qt6.5 is 11
# https://doc.qt.io/qt-6.5/supported-platforms.html#desktop-platforms
set(VCPKG_OSX_DEPLOYMENT_TARGET 11.0)

# All Apple computer supported by macOS 11, have processors with AVX instruction set
set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -mavx")
set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -mavx")

set(VCPKG_BUILD_TYPE release)
