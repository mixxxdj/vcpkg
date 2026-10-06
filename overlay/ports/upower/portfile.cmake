vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO upower/upower
    REF "v${VERSION}"
    SHA512 804e75d08bc1fef499748bcbd96b2d0d3aae9566be67b7da70ac993e73ad7de59f29ec436f5472b8ace350c81ad65ade6cf59ca5efd8591e8ca16de62ff64bde
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dgtk-doc=false
        -Didevice=disabled
        -Dintrospection=disabled
        -Dman=false
        -Dos_backend=dummy
        -Dpolkit=disabled
        -Dsystemdsystemunitdir=no
    ADDITIONAL_BINARIES
        "gdbus-codegen='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/gdbus-codegen'"
        "glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'"
)
vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

# Only the libupower-glib client library is needed; drop the daemon, the
# command line tool and the service files.
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/bin"
    "${CURRENT_PACKAGES_DIR}/debug/bin"
    "${CURRENT_PACKAGES_DIR}/libexec"
    "${CURRENT_PACKAGES_DIR}/debug/libexec"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/dbus-1"
    "${CURRENT_PACKAGES_DIR}/share/man"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
