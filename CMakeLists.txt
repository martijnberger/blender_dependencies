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


set(LIBDIR ${CMAKE_CURRENT_BINARY_DIR})

# TODO FIXME highly MSVC specific
set(DEFAULT_C_FLAGS
 -DCMAKE_C_FLAGS_DEBUG="/MTd /Zi /Ob0 /Od /RTC1 /D_DEBUG" 
 -DCMAKE_C_FLAGS_MINSIZEREL="/MT /O1 /Ob1 /D NDEBUG"
 -DCMAKE_C_FLAGS_RELEASE="/MT /O2 /Ob2 /D NDEBUG"
 -DCMAKE_C_FLAGS_RELWITHDEBINFO="/MT /Zi /O2 /Ob1 /D NDEBUG"
 )

set(ZLIB_VERSION 1.2.8)    
set(ZLIB_URI http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz)
 
ExternalProject_Add(external_zlib
  URL ${ZLIB_URI}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/zlib
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/zlib ${DEFAULT_C_FLAGS}
  INSTALL_DIR ${LIBDIR}/zlib
)

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

set(BOOST_VERSION 1.60.0)
set(BOOST_VERSION_NODOTS 1_60_0)
set(BOOST_URI http://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION}/boost_${BOOST_VERSION_NODOTS}.tar.bz2/download)
set(BOOST_MD5 65a840e1a0b13a558ff19eeb2c4f0cbe)
set(BOOST_OPTIONS --with-filesystem
				  --with-locale
				  --with-thread
				  --with-regex
				  --with-system
				  --with-date_time
				  --with-wave)

ExternalProject_Add(external_boost
  URL ${BOOST_URI}
  URL_HASH MD5=${BOOST_MD5}
  UPDATE_COMMAND  ""
  CONFIGURE_COMMAND bootstrap.bat
  BUILD_COMMAND bjam -j4 architecture=x86 address-model=64 variant=release link=static runtime-link=static threading=multi ${BOOST_OPTIONS}  --prefix=${LIBDIR}/boost install
  BUILD_IN_SOURCE 1
  INSTALL_COMMAND ""
)


set(BLOSC_VERSION 1.7.1)
set(BLOSC_URI https://github.com/Blosc/c-blosc/archive/v${BLOSC_VERSION}.zip)
#set(BLOSC_HASH f9804884c1c41eb7f4febb9353a2cb27)
set(BLOSC_EXTRA_ARGS -DZLIB_INCLUDE_DIR=${LIBDIR}/zlib/include/
					 -DZLIB_LIBRARY=${LIBDIR}/zlib/lib/libz_st.lib
					 -DBUILD_TESTS=OFF
					 -DBUILD_BENCHMARKS=OFF
					 -DCMAKE_DEBUG_POSTFIX=_d)

ExternalProject_Add(external_blosc
  URL ${BLOSC_URI}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/blosc
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/blosc ${DEFAULT_C_FLAGS} ${BLOSC_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/blosc
)

set(PTHREADS_VERSION 2-9-1)
set(PTHREADS_URI ftp://sourceware.org/pub/pthreads-win32/pthreads-w32-${PTHREADS_VERSION}-release.tar.gz)
set(PTHREADS_SHA512 9c06e85310766834370c3dceb83faafd397da18a32411ca7645c8eb6b9495fea54ca2872f4a3e8d83cb5fdc5dea7f3f0464be5bb9af3222a6534574a184bd551 )
set(PTHREADS_BUILD cd ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/ && cd  && nmake VC /e XCFLAGS=/MD /e XLIBS=/NODEFAULTLIB:msvcr )

ExternalProject_Add(external_pthreads
  URL ${PTHREADS_URI}
  URL_HASH SHA512=${PTHREADS_SHA512}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads
  CONFIGURE_COMMAND echo .
  BUILD_COMMAND ${PTHREADS_BUILD}
  INSTALL_COMMAND COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/pthreadVC2.dll ${LIBDIR}/pthreads/lib/pthreadVC2.dll && 
					      ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/pthreadVC2.lib ${LIBDIR}/pthreads/lib/pthreadVC2.lib &&		
						  ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/pthread.h ${LIBDIR}/pthreads/inc/pthread.h		     && 
						  ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/sched.h ${LIBDIR}/pthreads/inc/sched.h               &&
						  ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/semaphore.h ${LIBDIR}/pthreads/inc/semaphore.h		 
  INSTALL_DIR ${LIBDIR}/pthreads
)