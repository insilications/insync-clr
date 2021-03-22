message(STATUS "cmake version ${CMAKE_VERSION}")
project (insync)
cmake_minimum_required (VERSION 3.20.0)

set(LIB_INSTALL_DIR lib64 CACHE STRING "Install location of libraries")
set(BIN_INSTALL_DIR bin CACHE STRING "Install location of executables")
set(SHARE_INSTALL_DIR share CACHE STRING "Install location of executables")

install(CODE "execute_process(COMMAND sh ${PROJECT_SOURCE_DIR}/download.bash)")
install(DIRECTORY ${PROJECT_BINARY_DIR}/usr/lib/ DESTINATION ${LIB_INSTALL_DIR} USE_SOURCE_PERMISSIONS)
install(DIRECTORY ${PROJECT_BINARY_DIR}/usr/bin/ DESTINATION ${BIN_INSTALL_DIR} USE_SOURCE_PERMISSIONS)
install(DIRECTORY ${PROJECT_BINARY_DIR}/usr/share/ DESTINATION ${SHARE_INSTALL_DIR} USE_SOURCE_PERMISSIONS)
