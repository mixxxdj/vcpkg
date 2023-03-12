function(qt_configure_qmake)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 arg
        ""
        "SOURCE_PATH"
        "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG;BUILD_OPTIONS;BUILD_OPTIONS_RELEASE;BUILD_OPTIONS_DEBUG"
    )

    # Find qmake executable
    find_program(qmake_executable NAMES qmake PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/qt5/bin" NO_DEFAULT_PATH)

    if(NOT qmake_executable)
        message(FATAL_ERROR "qt_configure_qmake: unable to find qmake.")
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        vcpkg_list(APPEND arg_OPTIONS "CONFIG-=shared" "CONFIG*=static")
    else()
        vcpkg_list(APPEND arg_OPTIONS "CONFIG-=static" "CONFIG*=shared")
        vcpkg_list(APPEND arg_OPTIONS_DEBUG "CONFIG*=separate_debug_info")
    endif()

    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_CRT_LINKAGE STREQUAL "static")
        vcpkg_list(APPEND arg_OPTIONS "CONFIG*=static-runtime")
    endif()

    if(DEFINED VCPKG_OSX_DEPLOYMENT_TARGET)
        set(ENV{QMAKE_MACOSX_DEPLOYMENT_TARGET} ${VCPKG_OSX_DEPLOYMENT_TARGET})
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        z_vcpkg_setup_pkgconfig_path(BASE_DIRS "${CURRENT_INSTALLED_DIR}" "${CURRENT_PACKAGES_DIR}")

        set(current_binary_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

        # Cleanup build directories
        file(REMOVE_RECURSE "${current_binary_dir}")

        configure_file("${CURRENT_INSTALLED_DIR}/tools/qt5/qt_release.conf" "${current_binary_dir}/qt.conf")
    
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
        file(MAKE_DIRECTORY "${current_binary_dir}")

        vcpkg_list(SET build_opt_param)
        if(DEFINED arg_BUILD_OPTIONS OR DEFINED arg_BUILD_OPTIONS_RELEASE)
            vcpkg_list(SET build_opt_param -- ${arg_BUILD_OPTIONS} ${arg_BUILD_OPTIONS_RELEASE})
        endif()

        vcpkg_execute_required_process(
            COMMAND "${qmake_executable}" CONFIG-=debug CONFIG+=release
                    ${arg_OPTIONS} ${arg_OPTIONS_RELEASE} ${arg_SOURCE_PATH}
                    -qtconf "${current_binary_dir}/qt.conf"
                    ${build_opt_param}
            WORKING_DIRECTORY "${current_binary_dir}"
            LOGNAME "config-${TARGET_TRIPLET}-rel"
        )
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")
        if(EXISTS "${current_binary_dir}/config.log")
            file(REMOVE "${CURRENT_BUILDTREES_DIR}/internal-config-${TARGET_TRIPLET}-rel.log")
            file(RENAME "${current_binary_dir}/config.log" "${CURRENT_BUILDTREES_DIR}/internal-config-${TARGET_TRIPLET}-rel.log")
        endif()

        z_vcpkg_restore_pkgconfig_path()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        z_vcpkg_setup_pkgconfig_path(BASE_DIRS "${CURRENT_INSTALLED_DIR}/debug" "${CURRENT_PACKAGES_DIR}/debug")

        set(current_binary_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

        # Cleanup build directories
        file(REMOVE_RECURSE "${current_binary_dir}")

        configure_file("${CURRENT_INSTALLED_DIR}/tools/qt5/qt_debug.conf" "${current_binary_dir}/qt.conf")

        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
        file(MAKE_DIRECTORY "${current_binary_dir}")

        vcpkg_list(SET build_opt_param)
        if(DEFINED arg_BUILD_OPTIONS OR DEFINED arg_BUILD_OPTIONS_DEBUG)
            vcpkg_list(SET build_opt_param -- ${arg_BUILD_OPTIONS} ${arg_BUILD_OPTIONS_DEBUG})
        endif()
        vcpkg_execute_required_process(
            COMMAND "${qmake_executable}" CONFIG-=release CONFIG+=debug
                    ${arg_OPTIONS} ${arg_OPTIONS_DEBUG} ${arg_SOURCE_PATH}
                    -qtconf "${current_binary_dir}/qt.conf"
                    ${build_opt_param}
            WORKING_DIRECTORY "${current_binary_dir}"
            LOGNAME "config-${TARGET_TRIPLET}-dbg"
        )
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")
        if(EXISTS "${current_binary_dir}/config.log")
            file(REMOVE "${CURRENT_BUILDTREES_DIR}/internal-config-${TARGET_TRIPLET}-dbg.log")
            file(RENAME "${current_binary_dir}/config.log" "${CURRENT_BUILDTREES_DIR}/internal-config-${TARGET_TRIPLET}-dbg.log")
        endif()
        
        z_vcpkg_restore_pkgconfig_path()
    endif()
endfunction()


function(qt_build_submodule SOURCE_PATH)
    # This fixes issues on machines with default codepages that are not ASCII compatible, such as some CJK encodings
    set(ENV{_CL_} "/utf-8")

    vcpkg_find_acquire_program(PYTHON2)
    get_filename_component(PYTHON2_EXE_PATH ${PYTHON2} DIRECTORY)
    vcpkg_add_to_path("${PYTHON2_EXE_PATH}")
    
    qt_configure_qmake(SOURCE_PATH ${SOURCE_PATH})

    vcpkg_build_qmake(SKIP_MAKEFILES)
    
    #Fix the installation location within the makefiles
    qt_fix_makefile_install("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/")
    qt_fix_makefile_install("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/")
    
    #Install the module files
    vcpkg_build_qmake(TARGETS install SKIP_MAKEFILES BUILD_LOGNAME install)
    
    qt_fix_cmake(${CURRENT_PACKAGES_DIR} ${PORT})

    #Replace with VCPKG variables if PR #7733 is merged
    unset(BUILDTYPES)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(_buildname "DEBUG")
        list(APPEND BUILDTYPES ${_buildname})
        set(_short_name_${_buildname} "dbg")
        set(_path_suffix_${_buildname} "/debug")        
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(_buildname "RELEASE")
        list(APPEND BUILDTYPES ${_buildname})
        set(_short_name_${_buildname} "rel")
        set(_path_suffix_${_buildname} "")        
    endif()
    unset(_buildname)

    foreach(_buildname ${BUILDTYPES})
        set(CURRENT_BUILD_PACKAGE_DIR "${CURRENT_PACKAGES_DIR}${_path_suffix_${_buildname}}")
        #Fix PRL files 
        file(GLOB_RECURSE PRL_FILES "${CURRENT_BUILD_PACKAGE_DIR}/lib/*.prl" "${CURRENT_PACKAGES_DIR}/tools/qt5${_path_suffix_${_buildname}}/lib/*.prl" 
                                    "${CURRENT_PACKAGES_DIR}/tools/qt5${_path_suffix_${_buildname}}/mkspecs/*.pri")
        qt_fix_prl("${CURRENT_BUILD_PACKAGE_DIR}" "${PRL_FILES}")
        
        # This makes it impossible to use the build tools in any meaningful way. qt5 assumes they are all in one folder!
        # So does the Qt VS Plugin which even assumes all of the in a bin folder  
        #Move tools to the correct directory
        #if(EXISTS ${CURRENT_BUILD_PACKAGE_DIR}/tools/qt5)
        #    file(RENAME ${CURRENT_BUILD_PACKAGE_DIR}/tools/qt5 ${CURRENT_PACKAGES_DIR}/tools/${PORT})
        #endif()
        
        # Move executables in bin to tools
        # This is ok since those are not build tools.
        file(GLOB PACKAGE_EXE ${CURRENT_BUILD_PACKAGE_DIR}/bin/*.exe)
        if(PACKAGE_EXE)
            file(INSTALL ${PACKAGE_EXE} DESTINATION "${CURRENT_BUILD_PACKAGE_DIR}/tools/${PORT}")
            file(REMOVE ${PACKAGE_EXE})
            foreach(_exe ${PACKAGE_EXE})
                string(REPLACE ".exe" ".pdb" _prb_file ${_exe})
                if(EXISTS ${_prb_file})
                    file(INSTALL ${_prb_file} DESTINATION "${CURRENT_BUILD_PACKAGE_DIR}/tools/${PORT}")
                    file(REMOVE ${_prb_file})
                endif()
            endforeach()
        endif()
        
        #cleanup empty folders
        file(GLOB PACKAGE_LIBS "${CURRENT_BUILD_PACKAGE_DIR}/lib/*")
        if(NOT PACKAGE_LIBS)
            file(REMOVE_RECURSE "${CURRENT_BUILD_PACKAGE_DIR}/lib")
        endif()
        
        file(GLOB PACKAGE_BINS "${CURRENT_BUILD_PACKAGE_DIR}/bin/*")
        if(NOT PACKAGE_BINS)
            file(REMOVE_RECURSE "${CURRENT_BUILD_PACKAGE_DIR}/bin")
        endif()
    endforeach()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/tools/qt5/bin")
        file(COPY "${CURRENT_PACKAGES_DIR}/tools/qt5/bin" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
    endif()
endfunction()
