
if (NOT ${VCPKG_CROSSCOMPILING}) 
    # Qt installs the host tools to /home/sperry/workspace/vcpkg/installed/{HOST_TRIPLET}/tools/qt5
    # and not to the ${CURRENT_PACKAGES_DIR}. This helper package creates the a valid package from these files 
    # at packages/qt5-host-tools_${TARGET_TRIPLET}
    if (NOT EXISTS "${CURRENT_HOST_INSTALLED_DIR}/lib/pkgconfig/Qt5Core.pc") 
        message(STATUS "creating a package from ${CURRENT_HOST_INSTALLED_DIR}/tools/qt5")
        file(COPY "${CURRENT_HOST_INSTALLED_DIR}/tools/qt5/" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/qt5/")
        file(REMOVE_RECURSE "${CURRENT_HOST_INSTALLED_DIR}/tools/qt5")
    endif()    
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
    file(TOUCH "${CURRENT_PACKAGES_DIR}/include/qt5-host-tools")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/qt5-host-tools")
    file(TOUCH "${CURRENT_PACKAGES_DIR}/share/qt5-host-tools/copyright")
else()
    # crosscompiling 
    message(FATAL_ERROR "qt5-host-tools can only be installed for the host")
endif()
