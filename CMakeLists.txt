project("Blender External Dependencies")
cmake_minimum_required(VERSION 3.0)

include(ExternalProject)

####################################################################################################
#
# USAGE:
#   for now this is intended to be used with cmake and msbuild
#   cmake. 
#   msbuild ALL_BUILD.vcxproj /p:COnfiguration=Release/Debug
#
#   the builds should also inherit any platformtoolset you might give them
####################################################################################################


set(LIBDIR ${CMAKE_CURRENT_BINARY_DIR}/lib)

# TODO FIXME highly MSVC specific
set(DEFAULT_C_FLAGS
 -DCMAKE_C_FLAGS_DEBUG="/MTd /Zi /Ob0 /Od /RTC1 /D_DEBUG" 
 -DCMAKE_C_FLAGS_MINSIZEREL="/MT /O1 /Ob1 /D NDEBUG"
 -DCMAKE_C_FLAGS_RELEASE="/MT /O2 /Ob2 /D NDEBUG"
 -DCMAKE_C_FLAGS_RELWITHDEBINFO="/MT /Zi /O2 /Ob1 /D NDEBUG"
 )

  
.########.##.......####.########.
......##..##........##..##.....##
.....##...##........##..##.....##
....##....##........##..########.
...##.....##........##..##.....##
..##......##........##..##.....##
.########.########.####.########.
 
set(ZLIB_VERSION 1.2.8)    
set(ZLIB_URI http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz)
 
ExternalProject_Add(external_zlib
  URL ${ZLIB_URI}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/zlib
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/zlib ${DEFAULT_C_FLAGS}
  INSTALL_DIR ${LIBDIR}/zlib
)


.########..##....##..######..
.##.....##.###...##.##....##.
.##.....##.####..##.##.......
.########..##.##.##.##...####
.##........##..####.##....##.
.##........##...###.##....##.
.##........##....##..######..

set(PNG_VERSION 1.6.21)
set(PNG_URI  http://prdownloads.sourceforge.net/libpng/libpng-${PNG_VERSION}.tar.gz)
set(PNG_HASH aca36ec8e0a3b406a5912243bc243717)
set(PNG_EXTRA_ARGS 
 -DZLIB_LIBRARY=${LIBDIR}/zlib/lib/zlibstatic.lib
 -DZLIB_INCLUDE_DIR=${LIBDIR}/zlib/include/
 -DPNG_STATIC=ON
)

ExternalProject_Add(external_png
  URL ${PNG_URI}
  URL_HASH MD5=${PNG_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/png
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/png ${DEFAULT_C_FLAGS} ${PNG_EXTRA_ARGS}
  INSTALL_DIR  ${LIBDIR}/png
)

add_dependencies(external_png external_zlib)

.......##.########..########..######..
.......##.##.....##.##.......##....##.
.......##.##.....##.##.......##.......
.......##.########..######...##...####
.##....##.##........##.......##....##.
.##....##.##........##.......##....##.
..######..##........########..######..

set(JPEG_VERSION 1.4.2)
set(JPEG_URI https://github.com/libjpeg-turbo/libjpeg-turbo/archive/${JPEG_VERSION}.tar.gz)
set(JPEG_HASH f9804884c1c41eb7f4febb9353a2cb27)
set(JPEG_EXTRA_ARGS  -DWITH_JPEG8=ON  -DCMAKE_DEBUG_POSTFIX=d )

ExternalProject_Add(external_jpeg
  URL ${JPEG_URI}
  URL_HASH MD5=${JPEG_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/jpg
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/jpg ${DEFAULT_C_FLAGS} ${JPEG_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/jpg
)
