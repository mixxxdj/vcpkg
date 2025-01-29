set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)

# Oscpack does not allow dynamic linking on Windows 
# because of missing __declspec(dllexport) decorations 
if(${PORT} MATCHES "oscpack")
    set(VCPKG_LIBRARY_LINKAGE static)
else()
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

