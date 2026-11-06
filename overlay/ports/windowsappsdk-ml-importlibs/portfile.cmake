vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
set(VCPKG_BUILD_TYPE release)
set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled) # import libraries only, the DLLs are system libraries and provided by the OS

set(ML_VERSION 1.8.2223)

vcpkg_download_distfile(ML_ARCHIVE
	URLS "https://api.nuget.org/v3-flatcontainer/microsoft.windowsappsdk.ml/${ML_VERSION}/microsoft.windowsappsdk.ml.${ML_VERSION}.nupkg"
	FILENAME "microsoft.windowsappsdk.ml.${ML_VERSION}.zip"
	SHA512 32E63C1C20573EC7A3AFC457B7A4186C7C1AAE5A657E00B8B57C423767378420693C0572450A7C09C422EC1C2870AD516E073A0B39E00EDF79BA80C7FD4620CD
)

vcpkg_extract_source_archive(ML_SOURCE ARCHIVE "${ML_ARCHIVE}" NO_REMOVE_ONE_LEVEL)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
	set(NATIVE_ARCH arm64)
else()
	set(NATIVE_ARCH x64)
endif()

# Windows ML: C API headers (e.g. WinMLEpCatalog.h, WinMLAsync.h) and the ONNX Runtime headers,
# installed into a port-specific subdirectory so they do not clash with a regular onnxruntime port.
# WindowsMLAutoInitializer* is excluded.
file(INSTALL "${ML_SOURCE}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/windowsappsdk-ml"
	 PATTERN "WindowsMLAutoInitializer*" EXCLUDE)
file(INSTALL "${ML_SOURCE}/lib/native/${NATIVE_ARCH}/Microsoft.Windows.AI.MachineLearning.lib"
	 "${ML_SOURCE}/lib/native/${NATIVE_ARCH}/onnxruntime.lib"
	 DESTINATION "${CURRENT_PACKAGES_DIR}/lib/windowsappsdk-ml")

# Only import libraries are installed above; no DLLs on purpose (provided by the OS at runtime).
file(INSTALL "${ML_SOURCE}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
