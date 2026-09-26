vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO digital-stage/zita-resampler
    REF c998d1bd08a0bc17d26da6f9a8ab17e7a1d7408b
    SHA512 97917629f2919b8d0f7a7fb9bc7f32a023a5cb488e3e8f3f321cc8a7162cea80b608403fcfa37d56f2fd4de7436eb8d5b0683f595fd1a89d95db889246c4de16 
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

