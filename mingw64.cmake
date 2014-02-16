
SET(CMAKE_SYSTEM_NAME Windows)

SET(CMAKE_C_COMPILER "x86_64-w64-mingw32-gcc")
SET(CMAKE_CXX_COMPILER "x86_64-w64-mingw32-g++")
SET(CMAKE_AR "x86_64-w64-mingw32-ar" CACHE STRING "Path to the AR program" FORCE)
SET(CMAKE_LINKER "x86_64-w64-mingw32-ld")
SET(CMAKE_NM "x86_64-w64-mingw32-nm")
SET(CMAKE_OBJCOPY "x86_64-w64-mingw32-objcopy")
SET(CMAKE_OBJDUMP "x86_64-w64-mingw32-objdump")
SET(CMAKE_STRIP "x86_64-w64-mingw32-strip")
SET(CMAKE_RANLIB "x86_64-w64-mingw32-ranlib")
SET(CMAKE_RC_COMPILER "x86_64-w64-mingw32-windres")

SET(CMAKE_FIND_ROOT_PATH "/jenkins-worker/mingw" "/jenkins-worker/mingw/x86_64-w64-mingw32")

SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

SET(CMAKE_C_FLAGS "-m64" CACHE STRING "Flags used by the compiler during all build types." FORCE)
SET(CMAKE_CXX_FLAGS "-m64" CACHE STRING "Flags used by the compiler during all build types." FORCE)
SET(CMAKE_EXE_LINKER_FLAGS "-m64" CACHE STRING "Flags used by the linker." FORCE)
SET(CMAKE_SHARED_LINKER_FLAGS "-m64" CACHE STRING "Flags used by the linker during the creation of dll's." FORCE)
SET(CMAKE_MODULE_LINKER_FLAGS "-m64" CACHE STRING "Flags used by the linker during the creation of modules." FORCE)
SET(CMAKE_STATIC_LINKER_FLAGS "--target=pe-x86-64" CACHE STRING "Flags used by the linker during the creation of static libraries." FORCE)
SET(CMAKE_RC_FLAGS "--target=pe-x86-64" CACHE STRING "Flags for the Windows resource compiler." FORCE)

SET(MINGW TRUE)
