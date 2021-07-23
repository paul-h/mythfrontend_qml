# - Try to find MDK SDK
#
# MDK_FOUND - system has MDK
# MDK_INCLUDE_DIRS - the MDK include directory
# MDK_LIBRARIES - The MDK libraries
# MDK_VERSION_STRING -the version of MDK SDK found
#
# target_link_libraries(tgt PRIVATE mdk) will add all flags

# Compute the installation prefix relative to this file.
get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
if(_IMPORT_PREFIX STREQUAL "/")
  set(_IMPORT_PREFIX "")
endif()

if(ANDROID_ABI)
  set(_IMPORT_ARCH ${ANDROID_ABI})
elseif(CMAKE_ANDROID_ARCH_ABI)
  set(_IMPORT_ARCH ${CMAKE_ANDROID_ARCH_ABI})
elseif(CMAKE_C_COMPILER_ARCHITECTURE_ID) # msvc
  set(_IMPORT_ARCH ${CMAKE_C_COMPILER_ARCHITECTURE_ID}) # ARMV7 ARM64 X86 x64
elseif(WIN32)
  set(_IMPORT_ARCH ${CMAKE_SYSTEM_PROCESSOR})
elseif(CMAKE_SYSTEM_NAME STREQUAL Linux)
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "ar*64")
    set(_IMPORT_ARCH arm64)
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm")
    set(_IMPORT_ARCH armhf)
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "64")
    set(_IMPORT_ARCH amd64)
  endif()
endif()
string(TOLOWER "${_IMPORT_ARCH}" _IMPORT_ARCH)
if(WIN32)
  if(_IMPORT_ARCH MATCHES armv7) #msvc
    set(_IMPORT_ARCH arm)
  elseif(_IMPORT_ARCH MATCHES amd64) #msvc
    set(_IMPORT_ARCH x64)
  endif()
endif()

#list(APPEND CMAKE_FIND_ROOT_PATH ${_IMPORT_PREFIX})
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH) # for cross build, find paths out sysroot
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH) # for cross build, find paths out sysroot
find_path(MDK_INCLUDE_DIR mdk/global.h PATHS ${_IMPORT_PREFIX}/include)
find_library(MDK_LIBRARY NAMES mdk libmdk PATHS ${_IMPORT_PREFIX}/lib/${_IMPORT_ARCH}) # FIXME: may select host library
if(MDK_LIBRARY)
  if(APPLE)
    set(MDK_LIBRARY ${MDK_LIBRARY}/mdk) # was .framework, IMPORTED_LOCATION is file path
  endif()
else()
  if(APPLE)
    set(MDK_XCFWK ${_IMPORT_PREFIX}/lib/mdk.xcframework)
    if(EXISTS ${MDK_XCFWK})
      if(IOS)
        if(${CMAKE_OSX_SYSROOT} MATCHES Simulator)
          file(GLOB MDK_FWK LIST_DIRECTORIES true ${MDK_XCFWK}/ios-*-simulator)
        else()
          file(GLOB MDK_FWK LIST_DIRECTORIES true ${MDK_XCFWK}/ios-arm*)
        endif()
      else()
        file(GLOB MDK_FWK LIST_DIRECTORIES true ${MDK_XCFWK}/macos-*)
      endif()
      if(EXISTS ${MDK_FWK})
        set(MDK_LIBRARY ${MDK_FWK}/mdk.framework/mdk)
      endif()
    endif()
  endif()
endif()


set(MDK_INCLUDE_DIRS ${_IMPORT_PREFIX}/include)
set(MDK_LIBRARIES ${MDK_LIBRARY})

if(MDK_INCLUDE_DIR AND EXISTS "${MDK_INCLUDE_DIR}/mdk/c/global.h")
  file(STRINGS "${MDK_INCLUDE_DIR}/mdk/c/global.h" mdk_version_str
       REGEX "^#[\t ]*define[\t ]+MDK_(MAJOR|MINOR|MICRO)[\t ]+[0-9]+$")

  unset(MDK_VERSION_STRING)
  foreach(VPART MAJOR MINOR MICRO)
    foreach(VLINE ${mdk_version_str})
      if(VLINE MATCHES "^#[\t ]*define[\t ]+MDK_${VPART}[\t ]+([0-9]+)$")
        set(MDK_VERSION_PART "${CMAKE_MATCH_1}")
        if(DEFINED MDK_VERSION_STRING)
          string(APPEND MDK_VERSION_STRING ".${MDK_VERSION_PART}")
        else()
          set(MDK_VERSION_STRING "${MDK_VERSION_PART}")
        endif()
        unset(MDK_VERSION_PART)
      endif()
    endforeach()
  endforeach()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MDK
                                  REQUIRED_VARS MDK_LIBRARY MDK_INCLUDE_DIR
                                  VERSION_VAR MDK_VERSION_STRING)
add_library(mdk SHARED IMPORTED) # FIXME: ios needs CMAKE_SYSTEM_VERSION=9.0+(not DCMAKE_OSX_DEPLOYMENT_TARGET): Attempting to use @rpath without CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG being set.  This could be because you are using a Mac OS X version less than 10.5 or because CMake's platform configuration is corrupt
set_target_properties(mdk PROPERTIES
  IMPORTED_LOCATION "${MDK_LIBRARIES}"
  IMPORTED_IMPLIB "${MDK_LIBRARY}" # for win32, .lib import library
  INTERFACE_INCLUDE_DIRECTORIES "${MDK_INCLUDE_DIRS}"
  #IMPORTED_SONAME "@rpath/mdk.framework/mdk"
  #IMPORTED_NO_SONAME 1 # -lmdk instead of full path
  )

if(APPLE)
  set_property(TARGET mdk PROPERTY FRAMEWORK 1)
else()
  if(ANDROID)
    add_library(mdk-ffmpeg SHARED IMPORTED)
    set_target_properties(mdk-ffmpeg PROPERTIES
            IMPORTED_LOCATION ${_IMPORT_PREFIX}/lib/${_IMPORT_ARCH}/libffmpeg.so
            )
    #add_dependencies(mdk mdk-ffmpeg)
    target_link_libraries(mdk INTERFACE mdk-ffmpeg)
  endif()
endif()

mark_as_advanced(MDK_INCLUDE_DIRS MDK_LIBRARIES)