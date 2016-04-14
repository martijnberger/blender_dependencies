project("Blender External Dependencies")
cmake_minimum_required(VERSION 3.5)

include(ExternalProject)
OPTION(ENABLE_MINGW64 "Enable building of ffmpeg/iconv/libsndfile/lapack/fftw3 by installing mingw64" ON)
####################################################################################################
#
# USAGE:
#   Don't call this cmake file your self, use the build_deps batch file
#   build_deps 2013 or
#   build_deps 2015 
#
#   Note this currently only builds 64 bit versions of the dependencies, 32 bit is not supported or tested
#
####################################################################################################
# Status code # Description                                                                        #
####################################################################################################
# Work        # Work started, not completed                                                        #
# Done        # Done, Compiles without errors, not tested with blender yet                         #
# Prob        # There's a problem                                                                  #
# ????        # No idea what to do with this                                                       #
# Links       # Blender Compiles and links in release mode                                         #
# NoTest      # no clue how to test,component seems not referenced in default build?               #
# Tested      # Linked against blender and working                                                 #
####################################################################################################
# TODO                                                                                             #
####################################################################################################
# - Dependencies between projects                                                                  #
# - Apply patches to projects                                                                      #
#############################################################################################################
#Dependency            # VC12   # VC14   # Notes                                                            #
#############################################################################################################
#alembic               # Done   # Done   # Used latest from git                                             #
#blosc                 # Links  # Done   #                                                                  #
#boost                 # Links  # Done   #	                                                                #
#ffmpeg                # Links  # Done   # Build with mingw64, not as feature complete as in svn            #
#fftw3                 # Links  # Done   # Build with mingw64                                               #
#freetype              # Links  # Done   #                                                                  #
#iconv                 # NoTest # Done   # Build with mingw64                                               #
#jack                  # Prob   # Prob   # Last Supported msvc is 6.0                                       #
#jpeg                  # Links  # Done   #                                                                  #
#lapack                # NoTest # Done   # Needs the intel compiler or mingw to build                       #
#llvm                  # Links  # Work   # Compiles, llvm patch patch not applied yet.                      #
#openal                # Links  # Done   # Uses openal-soft, unsure what the old libs were                  #
#opencollada           # Links  # Done   #                                                                  #
#OpenColorIO           # Links  # Done   # requires cmake 3.5 to find boost 1.6.0                           #
#openexr               # Links  # Done   # Split into IlmBase & OpenExr                                     #
#opengl                # NoTest # Done   # Split into feeglut & glew                                        #
#Freeglut              # NoTest # Done   # dep of the opengl folder                                         #
#glew                  # NoTest # Done   # dep of the opengl folder, and opensubdiv                         #
#OpenImageIO           # Links  # Done   #                                                                  #
#opensubdiv            # Done   # Done   # Cuda Disabled for 2015 due to missing support                    #
#cuew                  # Done   # Done   # Dep for opensubdiv                                               #
#clew                  # Done   # Done   # Dep for opensubdiv                                               #
#glfw                  # Done   # Done   # Dep for opensubdiv                                               #
#openvdb               # Links  # Done   #                                                                  #
#osl                   # Links  # Done   #                                                                  #
#package               # ????   #        # Has a bunch of python stuff                                      #
#png                   # Links  # Done   #                                                                  #
#pthreads              # Links  # Done   #                                                                  #
#python                # ????   #        # Skip? Unsure why                                                 #
#release               # ????   #        # Installer scripts                                                # 
#sdl                   # Links  # Done   #                                                                  #
#sndfile               # Links  # Done   # build with mingw64                                               #
#tbb                   # Links  # Done   #                                                                  #
#thumbhandler          # ????   # ????   # Not sure what this is                                            #
#tiff                  # Links  # Done   #                                                                  #
#wintab                # ????   #        # Just a bunch of header files, nothing to build                   #
#zlib                  # Links  # Done   #                                                                  #
#############################################################################################################

if(NOT BUILD_MODE)
    set(BUILD_MODE "Release")
    message(STATUS "Build type not specified: defaulting to a release build.")
endif()
Message("BuildMode = ${BUILD_MODE}")
set(PATCH_CMD ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/msys/1.0/bin/patch.exe)

if (BUILD_MODE STREQUAL "Debug")
    set(LIBDIR ${CMAKE_CURRENT_BINARY_DIR}/Debug)
ELSE(BUILD_MODE STREQUAL "Debug")
    set(LIBDIR ${CMAKE_CURRENT_BINARY_DIR}/Release)
ENDIF(BUILD_MODE STREQUAL "Debug")

message("LIBDIR = ${LIBDIR}")

# TODO FIXME highly MSVC specific

 set(BLEND_CMAKE_C_FLAGS_DEBUG "/MTd /Zi /Ob0 /Od /RTC1 /D_DEBUG")
 set(BLEND_C_FLAGS_MINSIZEREL "/MT /O1 /Ob1 /D NDEBUG")
 set(BLEND_C_FLAGS_RELEASE "/MT /O2 /Ob2 /DNDEBUG")
 set(BLEND_C_FLAGS_RELWITHDEBINFO "/MT /Zi /O2 /Ob1 /D NDEBUG")

set(DEFAULT_C_FLAGS
 -DCMAKE_C_FLAGS_DEBUG=${BLEND_CMAKE_C_FLAGS_DEBUG}
 -DCMAKE_C_FLAGS_MINSIZEREL=${BLEND_C_FLAGS_MINSIZEREL}
 -DCMAKE_C_FLAGS_RELEASE=${BLEND_C_FLAGS_RELEASE}
 -DCMAKE_C_FLAGS_RELWITHDEBINFO=${BLEND_C_FLAGS_RELWITHDEBINFO}
 )

set(BLEND_CMAKE_CXX_FLAGS_DEBUG "/D_DEBUG /D PLATFORM_WINDOWS /MTd /Zi /Ob0 /Od /RTC1" )
set(BLEND_CMAKE_CXX_FLAGS_MINSIZEREL "/MT /O1 /Ob1 /D NDEBUG  /D PLATFORM_WINDOWS")
set(BLEND_CMAKE_CXX_FLAGS_RELEASE "/MT /O2 /Ob2 /D NDEBUG /D PLATFORM_WINDOWS" )
set(BLEND_CMAKE_CXX_FLAGS_RELWITHDEBINFO "/MT /Zi /O2 /Ob1 /D NDEBUG /D PLATFORM_WINDOWS" )

set(DEFAULT_CXX_FLAGS
 -DCMAKE_CXX_FLAGS_DEBUG=${BLEND_CMAKE_C_FLAGS_DEBUG}
 -DCMAKE_CXX_FLAGS_MINSIZEREL=${BLEND_C_FLAGS_MINSIZEREL}
 -DCMAKE_CXX_FLAGS_RELEASE=${BLEND_C_FLAGS_RELEASE}
 -DCMAKE_CXX_FLAGS_RELWITHDEBINFO=${BLEND_C_FLAGS_RELWITHDEBINFO}
 )

set(ZLIB_VERSION 1.2.8)    
set(ZLIB_URI http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz)
set(ZLIB_HASH 44d667c142d7cda120332623eab69f40)
ExternalProject_Add(external_zlib
  URL ${ZLIB_URI}
  URL_HASH MD5=${ZLIB_HASH}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/zlib
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/zlib ${DEFAULT_C_FLAGS}
  INSTALL_DIR ${LIBDIR}/zlib
)

if (BUILD_MODE STREQUAL Debug)
 ExternalProject_Add_Step(external_zlib after_install
 COMMAND ${CMAKE_COMMAND} -E copy ${LIBDIR}/zlib/lib/zlibstaticd.lib  ${LIBDIR}/zlib/lib/zlibstatic.lib
 DEPENDEES install
 )
endif (BUILD_MODE STREQUAL Debug)

if (BUILD_MODE STREQUAL Release)
set(OPENAL_VERSION 1.17.2)
set(OPENAL_URI  http://kcat.strangesoft.net/openal-releases/openal-soft-${OPENAL_VERSION}.tar.bz2)
set(OPENAL_HASH 1764e0d8fec499589b47ebc724e0913d)
set(OPENAL_EXTRA_ARGS 
	-DALSOFT_UTILS=Off
	-DALSOFT_NO_CONFIG_UTIL=On
	-DALSOFT_EXAMPLES=Off
	-DALSOFT_TESTS=Off
	-DALSOFT_CONFIG=Off
	-DALSOFT_HRTF_DEFS=Off
	-DALSOFT_INSTALL=On
)

ExternalProject_Add(external_openal
  URL ${OPENAL_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${OPENAL_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/openal
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/openal ${DEFAULT_C_FLAGS} ${OPENAL_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/openal
)
endif (BUILD_MODE STREQUAL Release)


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
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${PNG_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/png
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/png ${DEFAULT_C_FLAGS} ${PNG_EXTRA_ARGS}
  INSTALL_DIR  ${LIBDIR}/png
)

add_dependencies(external_png external_zlib)
if (BUILD_MODE STREQUAL Debug)
ExternalProject_Add_Step(external_png after_install
 COMMAND ${CMAKE_COMMAND} -E copy ${LIBDIR}/png/lib/libpng16_staticd.lib  ${LIBDIR}/png/lib/libpng16.lib
 DEPENDEES install
 )
endif (BUILD_MODE STREQUAL Debug)



set(JPEG_VERSION 1.4.2)
set(JPEG_URI https://github.com/libjpeg-turbo/libjpeg-turbo/archive/${JPEG_VERSION}.tar.gz)
set(JPEG_HASH f9804884c1c41eb7f4febb9353a2cb27)
set(JPEG_EXTRA_ARGS  -DWITH_JPEG8=ON  -DCMAKE_DEBUG_POSTFIX=d )

ExternalProject_Add(external_jpeg
  URL ${JPEG_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${JPEG_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/jpg
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/jpg ${DEFAULT_C_FLAGS} ${JPEG_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/jpg
)
add_dependencies(external_png external_zlib)
if (BUILD_MODE STREQUAL Debug)
ExternalProject_Add_Step(external_jpeg after_install
 COMMAND ${CMAKE_COMMAND} -E copy ${LIBDIR}/jpg/lib/jpegd.lib  ${LIBDIR}/jpg/lib/jpeg.lib
 DEPENDEES install
 )
endif (BUILD_MODE STREQUAL Debug)


if (MSVC12)
	set(VCVER 12)
	set(BOOST_COMPILER_STRING -vc120)
endif()
if (MSVC14)
	set(VCVER 14)
	set(BOOST_COMPILER_STRING -vc140)
endif()


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
                  --with-wave
				  --with-atomic
				  --with-serialization
				  --with-program_options
				  --with-python
				  toolset=msvc-${VCVER}.0)
string(TOLOWER ${BUILD_MODE} BOOST_BUILD_TYPE)

ExternalProject_Add(external_boost
  URL ${BOOST_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${BOOST_MD5}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/boost
  UPDATE_COMMAND  ""
  CONFIGURE_COMMAND bootstrap.bat
  BUILD_COMMAND bjam -j4 architecture=x86 address-model=64 variant=${BOOST_BUILD_TYPE} link=static runtime-link=static threading=multi ${BOOST_OPTIONS}  --prefix=${LIBDIR}/boost install
  BUILD_IN_SOURCE 1
  INSTALL_COMMAND ""
)

if (BUILD_MODE STREQUAL Release)
set(BLOSC_VERSION 1.7.1)
set(BLOSC_URI https://github.com/Blosc/c-blosc/archive/v${BLOSC_VERSION}.zip)
#set(BLOSC_HASH f9804884c1c41eb7f4febb9353a2cb27)
set(BLOSC_EXTRA_ARGS -DZLIB_INCLUDE_DIR=${LIBDIR}/zlib/include/
                     -DZLIB_LIBRARY=${LIBDIR}/zlib/lib/zlibstatic.lib
                     -DBUILD_TESTS=OFF
                     -DBUILD_BENCHMARKS=OFF
                     -DCMAKE_DEBUG_POSTFIX=_d
				  -DCMAKE_C_FLAGS_DEBUG=${BLEND_CMAKE_C_FLAGS_DEBUG}
 -DCMAKE_C_FLAGS_MINSIZEREL=${BLEND_C_FLAGS_MINSIZEREL}
 -DCMAKE_C_FLAGS_RELEASE=${BLEND_C_FLAGS_RELEASE}
 -DCMAKE_C_FLAGS_RELWITHDEBINFO=${BLEND_C_FLAGS_RELWITHDEBINFO}
)

ExternalProject_Add(external_blosc
  URL ${BLOSC_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  LIST_SEPARATOR ^^
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/blosc
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/blosc  ${DEFAULT_C_FLAGS}  ${DEFAULT_CXX_FLAGS}  ${BLOSC_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/blosc
)
add_dependencies(external_blosc external_zlib)
endif (BUILD_MODE STREQUAL Release)

if (BUILD_MODE STREQUAL Release)
set(PTHREADS_VERSION 2-9-1)
set(PTHREADS_URI ftp://sourceware.org/pub/pthreads-win32/pthreads-w32-${PTHREADS_VERSION}-release.tar.gz)
set(PTHREADS_SHA512 9c06e85310766834370c3dceb83faafd397da18a32411ca7645c8eb6b9495fea54ca2872f4a3e8d83cb5fdc5dea7f3f0464be5bb9af3222a6534574a184bd551 )
set(PTHREAD_XCFLAGS /MD )
if (MSVC14) #vs2015 has timespec
set(PTHREAD_CPPFLAGS "/I. /DHAVE_PTW32_CONFIG_H /D_TIMESPEC_DEFINED "  )
else (MSVC14) #everything before doesn't 
set(PTHREAD_CPPFLAGS "/I. /DHAVE_PTW32_CONFIG_H "  )
endif (MSVC14)
set(PTHREADS_BUILD cd ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/ && cd  && nmake VC /e CPPFLAGS=${PTHREAD_CPPFLAGS}  /e XCFLAGS=${PTHREAD_XCFLAGS} /e XLIBS=/NODEFAULTLIB:msvcr )

ExternalProject_Add(external_pthreads
  URL ${PTHREADS_URI} 
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH SHA512=${PTHREADS_SHA512}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads
  CONFIGURE_COMMAND echo .
  PATCH_COMMAND ${PATCH_CMD}  --verbose -p 0 -d ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads < ${CMAKE_CURRENT_SOURCE_DIR}/diffs/pthreads.diff 
  BUILD_COMMAND ${PTHREADS_BUILD}
  INSTALL_COMMAND COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/pthreadVC2.dll ${LIBDIR}/pthreads/lib/pthreadVC2.dll && 
                          ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/pthreadVC2.lib ${LIBDIR}/pthreads/lib/pthreadVC2.lib &&        
                          ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/pthread.h ${LIBDIR}/pthreads/inc/pthread.h             && 
                          ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/sched.h ${LIBDIR}/pthreads/inc/sched.h               &&
                          ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/semaphore.h ${LIBDIR}/pthreads/inc/semaphore.h         
  INSTALL_DIR ${LIBDIR}/pthreads
)
endif (BUILD_MODE STREQUAL Release)

set(ILMBASE_VERSION 2.2.0)
set(ILMBASE_URI http://download.savannah.nongnu.org/releases/openexr/ilmbase-${ILMBASE_VERSION}.tar.gz)
set(ILMBASE_HASH b540db502c5fa42078249f43d18a4652)
set(ILMBASE_CMAKE_CXX_STANDARD_LIBRARIES "kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib psapi.lib")
set(ILMBASE_CMAKE_CXX_FLAGS_DEBUG "/D_DEBUG /D PLATFORM_WINDOWS /MTd /Zi /Ob0 /Od /RTC1" )
set(ILMBASE_CMAKE_CXX_FLAGS_MINSIZEREL "/MT /O1 /Ob1 /D NDEBUG  /D PLATFORM_WINDOWS")
set(ILMBASE_CMAKE_CXX_FLAGS_RELEASE "/MT /O2 /Ob2 /D NDEBUG /D PLATFORM_WINDOWS" )
set(ILMBASE_CMAKE_CXX_FLAGS_RELWITHDEBINFO "/MT /Zi /O2 /Ob1 /D NDEBUG /D PLATFORM_WINDOWS" )
set(ILMBASE_EXTRA_ARGS
	-DBUILD_SHARED_LIBS=OFF 
	-DCMAKE_CXX_FLAGS_DEBUG=${ILMBASE_CMAKE_CXX_FLAGS_DEBUG}
	-DCMAKE_CXX_FLAGS_MINSIZEREL=${ILMBASE_CMAKE_CXX_FLAGS_MINSIZEREL}
	-DCMAKE_CXX_FLAGS_RELEASE=${ILMBASE_CMAKE_CXX_FLAGS_RELEASE}
	-DCMAKE_CXX_FLAGS_RELWITHDEBINFO=${ILMBASE_CMAKE_CXX_FLAGS_RELWITHDEBINFO}
	-DCMAKE_CXX_STANDARD_LIBRARIES=${ILMBASE_CMAKE_CXX_STANDARD_LIBRARIES}
)

ExternalProject_Add(external_ilmbase
  URL ${ILMBASE_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${ILMBASE_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/ilmbase
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/ilmbase ${DEFAULT_C_FLAGS} ${ILMBASE_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/openexr
)

set(OPENEXR_VERSION 2.2.0)
set(OPENEXR_URI http://download.savannah.nongnu.org/releases/openexr/openexr-2.2.0.tar.gz)
set(OPENEXR_HASH b64e931c82aa3790329c21418373db4e)
set(OPENEXR_CMAKE_CXX_STANDARD_LIBRARIES "kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib psapi.lib")
set(OPENEXR_CMAKE_CXX_FLAGS_DEBUG "/D_DEBUG /D PLATFORM_WINDOWS /MTd /Zi /Ob0 /Od /RTC1" )
set(OPENEXR_CMAKE_CXX_FLAGS_MINSIZEREL "/MT /O1 /Ob1 /D NDEBUG  /D PLATFORM_WINDOWS")
set(OPENEXR_CMAKE_CXX_FLAGS_RELEASE "/MT /O2 /Ob2 /D NDEBUG /D PLATFORM_WINDOWS" )
set(OPENEXR_CMAKE_CXX_FLAGS_RELWITHDEBINFO "/MT /Zi /O2 /Ob1 /D NDEBUG /D PLATFORM_WINDOWS" )

set(OPENEXR_EXTRA_ARGS 
    -DBUILD_SHARED_LIBS=OFF 
	-DCMAKE_CXX_FLAGS_DEBUG=${OPENEXR_CMAKE_CXX_FLAGS_DEBUG}
	-DCMAKE_CXX_FLAGS_MINSIZEREL=${OPENEXR_CMAKE_CXX_FLAGS_MINSIZEREL}
	-DCMAKE_CXX_FLAGS_RELEASE=${OPENEXR_CMAKE_CXX_FLAGS_RELEASE}
	-DCMAKE_CXX_FLAGS_RELWITHDEBINFO=${OPENEXR_CMAKE_CXX_FLAGS_RELWITHDEBINFO}
	-DCMAKE_CXX_STANDARD_LIBRARIES=${OPENEXR_CMAKE_CXX_STANDARD_LIBRARIES}
    -DZLIB_LIBRARY=${LIBDIR}/zlib/lib/zlibstatic.lib
    -DZLIB_INCLUDE_DIR=${LIBDIR}/zlib/include/
    -DILMBASE_PACKAGE_PREFIX=${LIBDIR}/ilmbase/
    )

ExternalProject_Add(external_openexr
  URL ${OPENEXR_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${OPENEXR_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/openexr
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/openexr ${DEFAULT_C_FLAGS} ${OPENEXR_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/openexr
)

add_dependencies(external_openexr external_zlib external_ilmbase)

set(FREETYPE_VERSION 263)
set(FREETYPE_URI http://download.savannah.gnu.org/releases/freetype/ft${FREETYPE_VERSION}.zip)
set(FREETYPE_HASH 0db2a43301572e5c2b4a0864f237aeeb)
set(FREETYPE_EXTRA_ARGS -DCMAKE_RELEASE_POSTFIX:STRING=2ST -DCMAKE_DEBUG_POSTFIX:STRING=2ST_d )

ExternalProject_Add(external_freetype
  URL ${FREETYPE_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${FREETYPE_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/freetype
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/freetype ${DEFAULT_C_FLAGS} ${FREETYPE_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/freetype
)

set(GLEW_VERSION 1.13.0)
set(GLEW_URI http://prdownloads.sourceforge.net/glew/glew/${GLEW_VERSION}/glew-${GLEW_VERSION}.tgz )
set(GLEW_HASH 7cbada3166d2aadfc4169c4283701066 ) 
set(GLEW_EXTRA_ARGS  
	-DBUILD_UTILS=Off
	-DBUILD_SHARED_LIBS=Off
)

ExternalProject_Add(external_glew
  URL ${GLEW_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${GLEW_HASH}
  PATCH_COMMAND COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/diffs/cmakelists_glew.txt  ${CMAKE_CURRENT_BINARY_DIR}/build/glew/src/external_glew/cmakelists.txt 
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/glew
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/glew ${DEFAULT_C_FLAGS} ${DEFAULT_CXX_FLAGS} ${GLEW_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/glew
)
if (BUILD_MODE STREQUAL Release)
set(FREEGLUT_VERSION 3.0.0)
set(FREEGLUT_URI http://pilotfiber.dl.sourceforge.net/project/freeglut/freeglut/${FREEGLUT_VERSION}/freeglut-${FREEGLUT_VERSION}.tar.gz )
set(FREEGLUT_HASH 90c3ca4dd9d51cf32276bc5344ec9754 ) 
set(FREEGLUT_EXTRA_ARGS  
	-DFREEGLUT_BUILD_SHARED_LIBS=Off
	-DFREEGLUT_BUILD_STATIC_LIBS=On
)

ExternalProject_Add(external_freeglut
  URL ${FREEGLUT_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${FREEGLUT_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/freeglut
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/freeglut ${DEFAULT_C_FLAGS} ${DEFAULT_CXX_FLAGS} ${GLEW_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/freeglut
)
endif (BUILD_MODE STREQUAL Release)

set(ALEMBIC_GIT_URI https://github.com/alembic/alembic.git )
set(ALEMBIC_GIT_UID 16f4ed6843f2b39d08c02338e0747f4dbcf8be20 ) 
set(ALEMBIC_EXTRA_ARGS  
 -DBUILDSTATIC=ON 
 -DLINKSTATIC=ON 
 -DBoost_COMPILER:STRING=${BOOST_COMPILER_STRING}
 -DBoost_USE_MULTITHREADED=ON 
 -DBoost_USE_STATIC_LIBS=ON 
 -DBoost_USE_STATIC_RUNTIME=ON 
 -DBOOST_ROOT=${LIBDIR}/boost 
 -DILMBASE_ROOT=${LIBDIR}/ilmbase 
 -DALEMBIC_ILMBASE_INCLUDE_DIRECTORY=${LIBDIR}/ilmbase/include/OpenEXR 
 -DALEMBIC_ILMBASE_HALF_LIB=${LIBDIR}/ilmbase/lib/Half.lib 
 -DALEMBIC_ILMBASE_IMATH_LIB=${LIBDIR}/ilmbase/lib/Imath-2_2.lib 
 -DALEMBIC_ILMBASE_ILMTHREAD_LIB=${LIBDIR}/ilmbase/lib/IlmThread-2_2.lib 
 -DALEMBIC_ILMBASE_IEX_LIB=${LIBDIR}/ilmbase/lib/Iex-2_2.lib 
 -DUSE_PYILMBASE=0 
 -DUSE_PYALEMBIC=0
 -DUSE_ARNOLD=0 
 -DUSE_MAYA=0
 -DUSE_PRMAN=0
 -DUSE_HDF5=Off
 -DUSE_TESTS=Off
 -DALEMBIC_NO_OPENGL=1 
 -DALEMBIC_ILMBASE_LINK_STATIC=On
 -DALEMBIC_SHARED_LIBS=OFF 
 -DGLUT_INCLUDE_DIR="" 
 -DZLIB_LIBRARY=${LIBDIR}/zlib/lib/zlibstatic.lib
 -DZLIB_INCLUDE_DIR=${LIBDIR}/zlib/include/
 )

ExternalProject_Add(external_alembic
  GIT_REPOSITORY ${ALEMBIC_GIT_URI}
  GIT_TAG ${ALEMBIC_GIT_UID}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/alembic
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/alembic -Wno-dev ${DEFAULT_C_FLAGS} ${DEFAULT_CXX_FLAGS} ${ALEMBIC_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/alembic
)

add_dependencies(external_alembic external_boost external_zlib external_ilmbase )

## hash is for 3.1.2 
set(GLFW_GIT_UID 30306e54705c3adae9fe082c816a3be71963485c)
set(GLFW_URI https://github.com/glfw/glfw/archive/${GLFW_GIT_UID}.zip )
set(GLFW_HASH 20cacb1613da7eeb092f3ac4f6b2b3d0 )
set(GLFW_EXTRA_ARGS )

ExternalProject_Add(external_glfw
  URL ${GLFW_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${GLFW_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/glfw
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/glfw -Wno-dev ${DEFAULT_C_FLAGS} ${DEFAULT_CXX_FLAGS} ${GLFW_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/glfw
)

#latest uid in git as of 2016-04-01
set(CLEW_GIT_UID 277db43f6cafe8b27c6f1055f69dc67da4aeb299)
set(CLEW_URI https://github.com/OpenCLWrangler/clew/archive/${CLEW_GIT_UID}.zip )
set(CLEW_HASH 2c699d10ed78362e71f56fae2a4c5f98 )
set(CLEW_EXTRA_ARGS )

ExternalProject_Add(external_clew
  URL ${CLEW_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${CLEW_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/clew
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/clew -Wno-dev ${DEFAULT_C_FLAGS} ${DEFAULT_CXX_FLAGS} ${CLEW_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/clew
)

#latest uid in git as of 2016-04-01
set(CUEW_GIT_UID 1744972026de9cf27c8a7dc39cf39cd83d5f922f)
set(CUEW_URI https://github.com/CudaWrangler/cuew/archive/${CUEW_GIT_UID}.zip )
set(CUEW_HASH 86760d62978ebfd96cd93f5aa1abaf4a )
set(CUEW_EXTRA_ARGS )

ExternalProject_Add(external_cuew
  URL ${CUEW_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${CUEW_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/cuew
  PATCH_COMMAND ${PATCH_CMD} --verbose -p 0 -d ${CMAKE_CURRENT_BINARY_DIR}/build/cuew/src/external_cuew < ${CMAKE_CURRENT_SOURCE_DIR}/diffs/cuew.diff 
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/cuew -Wno-dev ${DEFAULT_C_FLAGS} ${DEFAULT_CXX_FLAGS} ${CUEW_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/cuew
)

set(OPENSUBDIV_GIT_UID cf7135eb2a77d7907192fb3be4da7caa1e708f96 ) 
set(OPENSUBDIV_URI https://github.com/PixarAnimationStudios/OpenSubdiv/archive/${OPENSUBDIV_GIT_UID}.zip )
set(OPENSUBDIV_Hash 6715e7f80fecf6dae8243901afc5b8ac ) 
#no cuda support for vc15 yet
if (msvc15)
	set(OPENSUBDIV_CUDA Off)
else()
	set(OPENSUBDIV_CUDA On)
endif()
set(OPENSUBDIV_EXTRA_ARGS  
    -DNO_EXAMPLES=ON 
    -DNO_REGRESSION=ON 
    -DNO_PYTHON=ON 
    -DNO_MAYA=ON 
    -DNO_PTEX=ON 
    -DNO_DOC=ON 
    -DNO_CUDA=${OPENSUBDIV_CUDA}
    -DNO_OPENCL=Off 
    -DNO_TUTORIALS=ON 
	-DGLEW_INCLUDE_DIR=${LIBDIR}/glew/include
	-DGLEW_LIBRARY=${LIBDIR}/glew/lib/libglew.lib
	-DGLFW_INCLUDE_DIR=${LIBDIR}/glfw/include
	-DGLFW_LIBRARIES=${LIBDIR}/glfw/lib/glfw3.lib
    -DCLEW_INCLUDE_DIR=${LIBDIR}/clew/include/cl
    -DCLEW_LIBRARY=${LIBDIR}/clew/lib/clew.lib
    -DCUEW_INCLUDE_DIR=${LIBDIR}/cuew/include
    -DCUEW_LIBRARY=${LIBDIR}/cuew/lib/cuew.lib
	-DCMAKE_EXE_LINKER_FLAGS_RELEASE=libcmt.lib 
)

ExternalProject_Add(external_opensubdiv
  URL ${OPENSUBDIV_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${OPENSUBDIV_Hash}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/opensubdiv
  PATCH_COMMAND ${PATCH_CMD} --verbose -p 1 -d ${CMAKE_CURRENT_BINARY_DIR}/build/opensubdiv/src/external_opensubdiv < ${CMAKE_CURRENT_SOURCE_DIR}/diffs/opensubdiv.diff 
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/opensubdiv -Wno-dev ${DEFAULT_C_FLAGS} ${DEFAULT_CXX_FLAGS} ${OPENSUBDIV_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/opensubdiv
)

add_dependencies(external_opensubdiv external_glew external_glfw external_clew external_cuew)

#set(JACK_URI https://codeload.github.com/jackaudio/jack2/zip/ad5ddf6c2bbd64a254b4cc78de9114c10633da24?.zip)
#set(JACK_HASH 6a317d0df2bd95fc696b9fbca6608568 ) 
#set(JACK_EXTRA_ARGS  
#
#)

#ExternalProject_Add(external_jack
#  URL ${JACK_URI}
#  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
#  URL_HASH MD5=${JACK_HASH}
#  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/jack
#  PATCH_COMMAND COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/diffs/cmakelists_jack.txt  ${CMAKE_CURRENT_BINARY_DIR}/build/jack/src/external_jack/cmakelists.txt
#  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/jack ${DEFAULT_C_FLAGS} ${JACK_EXTRA_ARGS}
#  INSTALL_DIR ${LIBDIR}/jack
#)

set(SDL_VERSION 2.0.4)
set(SDL_URI https://www.libsdl.org/release/SDL2-${SDL_VERSION}.tar.gz)
set(SDL_HASH 44fc4a023349933e7f5d7a582f7b886e ) 
set(SDL_EXTRA_ARGS  
	-DSDL_STATIC=Off
)

ExternalProject_Add(external_sdl
  URL ${SDL_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${SDL_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/sdl
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/sdl ${DEFAULT_C_FLAGS} ${SDL_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/sdl
)

set(OPENCOLLADA_GIT_URI https://github.com/KhronosGroup/OpenCOLLADA.git)
set(OPENCOLLADA_GIT_UID 3335ac164e68b2512a40914b14c74db260e6ff7d ) 
set(OPENCOLLADA_EXTRA_ARGS  

)

ExternalProject_Add(external_opencollada
  GIT_REPOSITORY ${OPENCOLLADA_GIT_URI}
  GIT_TAG ${OPENCOLLADA_GIT_UID}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/opencollada
  PATCH_COMMAND ${PATCH_CMD} --verbose -p 1 -d ${CMAKE_CURRENT_BINARY_DIR}/build/opencollada/src/external_opencollada < ${CMAKE_CURRENT_SOURCE_DIR}/diffs/opencollada.diff 
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/opencollada ${DEFAULT_C_FLAGS} ${DEFAULT_CXX_FLAGS} ${OPENCOLLADA_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/opencollada
)

set(OPENCOLORIO_URI https://github.com/imageworks/OpenColorIO/archive/v1.0.8.zip)
set(OPENCOLORIO_HASH b31129f8dcb33fbfadb5a845f283c1eb ) 
set(OPENCOLORIO_EXTRA_ARGS  
 -DBoost_COMPILER:STRING=${BOOST_COMPILER_STRING}
 -DBoost_USE_MULTITHREADED=ON 
 -DBoost_USE_STATIC_LIBS=ON 
 -DBoost_USE_STATIC_RUNTIME=ON 
 -DBOOST_ROOT=${LIBDIR}/boost 
 -DBOOST_INCLUDEDIR=${LIBDIR}/boost/include/boost_1_60/boost
 -DBoost_DEBUG=ON
 -DBoost_MAJOR_VERSION=1
 -DBoost_MINOR_VERSION=60
 -DOCIO_USE_BOOST_PTR=ON 
 -DOCIO_BUILD_STATIC=OFF 
 -DOCIO_BUILD_SHARED=ON 
 -DOCIO_BUILD_APPS=OFF 
 -DOCIO_BUILD_PYGLUE=OFF 
 -DOCIO_BUILD_NUKE=OFF 
)

ExternalProject_Add(external_opencolorio
  URL ${OPENCOLORIO_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${OPENCOLORIO_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/opencolorio
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/opencolorio ${DEFAULT_C_FLAGS} ${OPENCOLORIO_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/opencolorio
)

add_dependencies(external_opencolorio external_boost)

set(LLVM_VERSION 3.4.2)
set(LLVM_URI http://llvm.org/releases/${LLVM_VERSION}/llvm-${LLVM_VERSION}.src.tar.gz)
set(LLVM_HASH a20669f75967440de949ac3b1bad439c)
set(LLVM_EXTRA_ARGS 
 -DLLVM_USE_CRT_RELEASE=MT 
 -DLLVM_USE_CRT_DEBUG=MTd
 -DLLVM_INCLUDE_TESTS=OFF 
 -DLLVM_TARGETS_TO_BUILD=X86
 -DLLVM_INCLUDE_EXAMPLES=OFF
   )

ExternalProject_Add(external_llvm
  URL ${LLVM_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${LLVM_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/llvm
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/llvm ${DEFAULT_C_FLAGS} ${LLVM_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/llvm
)

set(CLANG_URI http://llvm.org/releases/${LLVM_VERSION}/cfe-${LLVM_VERSION}.src.tar.gz)
set(CLANG_HASH 87945973b7c73038871c5f849a818588)
set(CLANG_EXTRA_ARGS 
   -DCLANG_PATH_TO_LLVM_SOURCE=${CMAKE_CURRENT_BINARY_DIR}/build/llvm/src/external_llvm
   -DCLANG_PATH_TO_LLVM_BUILD=${LIBDIR}/llvm
   -DLLVM_USE_CRT_RELEASE=MT
   -DLLVM_USE_CRT_DEBUG=MTd
   )
ExternalProject_Add(external_clang
  URL ${CLANG_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${CLANG_HASH}
  PATCH_COMMAND ${PATCH_CMD} -p 2 -R -d ${CMAKE_CURRENT_BINARY_DIR}/build/clang/src/external_clang < ${CMAKE_CURRENT_SOURCE_DIR}/diffs/clang.diff 
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/clang
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/llvm ${DEFAULT_C_FLAGS} ${CLANG_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/llvm
)
add_dependencies(external_clang external_llvm)

set(OPENIMAGEIO_VERSION 1.6.9)
set(OPENIMAGEIO_URI https://github.com/OpenImageIO/oiio/archive/Release-${OPENIMAGEIO_VERSION}.zip)
set(OPENIMAGEIO_HASH c0ec61c3e79ddc65a6239ea938ce2cda)
set(OPENIMAGEIO_CMAKE_CXX_FLAGS_DEBUG "/D_DEBUG /MTd /Zi /Ob0 /Od /DPSAPI_VERSION=1 /RTC1")
set(OPENIMAGEIO_CMAKE_CXX_FLAGS_MINSIZEREL "/MT /O1 /Ob1 /DPSAPI_VERSION=1 /D NDEBUG")
set(OPENIMAGEIO_CMAKE_CXX_FLAGS_RELEASE "/MT /O2 /Ob2 /DPSAPI_VERSION=1 /D NDEBUG")
set(OPENIMAGEIO_CMAKE_CXX_FLAGS_RELWITHDEBINFO "/MT /Zi /O2 /Ob1 /DPSAPI_VERSION=1 /D NDEBUG" )

set(OPENIMAGEIO_EXTRA_ARGS 
	-DBUILDSTATIC=ON 
	-DLINKSTATIC=ON 
	-DCMAKE_CXX_FLAGS_DEBUG=${OPENIMAGEIO_CMAKE_CXX_FLAGS_DEBUG}
	-DCMAKE_CXX_FLAGS_MINSIZEREL=${OPENIMAGEIO_CMAKE_CXX_FLAGS_MINSIZEREL}
	-DCMAKE_CXX_FLAGS_RELEASE=${OPENIMAGEIO_CMAKE_CXX_FLAGS_RELEASE}
	-DCMAKE_CXX_FLAGS_RELWITHDEBINFO=${OPENIMAGEIO_CMAKE_CXX_FLAGS_RELWITHDEBINFO}
    -DILMBASE_PACKAGE_PREFIX=${LIBDIR}/ilmbase/
	-DILMBASE_INCLUDE_DIR=${LIBDIR}/ilmbase/include/ 
    -DILMBASE_HALF_LIBRARIES=${LIBDIR}/ilmbase/lib/Half.lib 
    -DILMBASE_IMATH_LIBRARIES=${LIBDIR}/ilmbase/lib/Imath-2_2.lib 
    -DILMBASE_ILMTHREAD_LIBRARIES=${LIBDIR}/ilmbase/lib/IlmThread-2_2.lib 
    -DILMBASE_IEX_LIBRARIES=${LIBDIR}/ilmbase/lib/Iex-2_2.lib 
	-DOPENEXR_INCLUDE_DIR=${LIBDIR}/openexr/include/openexr/ 
	-DOPENEXR_ILMIMF_LIBRARIES=${LIBDIR}/openexr/lib/IlmImf-2_2.lib
	-DBoost_COMPILER:STRING=${BOOST_COMPILER_STRING}
	-DBoost_USE_MULTITHREADED=ON 
	-DBoost_USE_STATIC_LIBS=ON 
	-DBoost_USE_STATIC_RUNTIME=ON 
	-DBOOST_ROOT=${LIBDIR}/boost 
	-DBOOST_LIBRARYDIR=${LIBDIR}/boost/lib/
	-OIIO_BUILD_CPP11=ON 
	-DUSE_OPENGL=OFF 
	-DUSE_TBB=OFF 
	-DUSE_FIELD3D=OFF 
	-DUSE_QT=OFF 
	-DUSE_PYTHON=OFF 
	-DOIIO_BUILD_TOOLS=OFF 
	-DOIIO_BUILD_TESTS=OFF 
	-DBUILD_TESTING=OFF 
	-DZLIB_LIBRARY=${LIBDIR}/zlib/lib/zlib_static.lib 
	-DZLIB_INCLUDE_DIR=${LIBDIR}/zlib/include 
	-DPNG_LIBRARY=${LIBDIR}/png/lib/libpng.lib 
	-DPNG_PNG_INCLUDE_DIR=${LIBDIR}/png/include 
	-DTIFF_LIBRARY=${LIBDIR}/tiff/lib/tiff.lib 
	-DTIFF_INCLUDE_DIR=${LIBDIR}/tiff/include 
	-DJPEG_LIBRARY=${LIBDIR}/jpg/lib/libjpeg.lib 
	-DJPEG_INCLUDE_DIR=${LIBDIR}/jpg/include
	-DOCIO_PATH=${LIBDIR}/opencolorio/
	-DOPENEXR_HOME=${LIBDIR}/openexr/
	-DILMBASE_PACKAGE_PREFIX=${LIBDIR}/ilmbase/
	-DILMBASE_INCLUDE_DIR=${LIBDIR}/ilmbase/include/ 
    -DILMBASE_HALF_LIBRARIES=${LIBDIR}/ilmbase/lib/Half.lib 
    -DILMBASE_IMATH_LIBRARIES=${LIBDIR}/ilmbase/lib/Imath-2_2.lib 
    -DILMBASE_ILMTHREAD_LIBRARIES=${LIBDIR}/ilmbase/lib/IlmThread-2_2.lib 
    -DILMBASE_IEX_LIBRARIES=${LIBDIR}/ilmbase/lib/Iex-2_2.lib 
	-DOPENEXR_INCLUDE_DIR=${LIBDIR}/openexr/include/ 
	-DOPENEXR_ILMIMF_LIBRARIES=${LIBDIR}/openexr/lib/IlmImf-2_2.lib 
)

ExternalProject_Add(external_openimageio
  URL ${OPENIMAGEIO_URI}	
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${OPENIMAGEIO_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/openimageio
  PATCH_COMMAND ${PATCH_CMD} -p 0 -d ${CMAKE_CURRENT_BINARY_DIR}/build/openimageio/src/external_openimageio/src/include < ${CMAKE_CURRENT_SOURCE_DIR}/diffs/OpenImageIO_GDI.diff
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/openimageio ${DEFAULT_C_FLAGS} ${OPENIMAGEIO_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/openimageio
)
add_dependencies(external_openimageio external_png external_zlib external_ilmbase external_openexr external_jpeg external_boost external_tiff  )


set(TIFF_VERSION 4.0.6)
set(TIFF_URI http://download.osgeo.org/libtiff/tiff-${TIFF_VERSION}.tar.gz)
set(TIFF_HASH d1d2e940dea0b5ad435f21f03d96dd72)
set(TIFF_EXTRA_ARGS 
	 -DZLIB_LIBRARY=${LIBDIR}/zlib/lib/zlibstatic.lib 
	 -DZLIB_INCLUDE_DIR=${LIBDIR}/zlib/include 
	 -DPNG_STATIC=ON 
	 -DBUILD_SHARED_LIBS=OFF
   )

ExternalProject_Add(external_tiff
  URL ${TIFF_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${TIFF_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/tiff
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/tiff ${DEFAULT_C_FLAGS} ${TIFF_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/tiff
)

add_dependencies(external_tiff external_zlib )
if (BUILD_MODE STREQUAL Debug)
ExternalProject_Add_Step(external_tiff after_install
 COMMAND ${CMAKE_COMMAND} -E copy ${LIBDIR}/tiff/lib/tiffd.lib  ${LIBDIR}/tiff/lib/tiff.lib
 DEPENDEES install
 )
endif (BUILD_MODE STREQUAL Debug)



set(FLEXBISON_VERSION 2.5.5)
set(FLEXBISON_URI http://prdownloads.sourceforge.net/winflexbison//win_flex_bison-2.5.5.zip)
set(FLEXBISON_HASH d87a3938194520d904013abef3df10ce)
set(FLEXBISON_EXTRA_ARGS 
   )

ExternalProject_Add(external_flexbison
  URL ${FLEXBISON_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${FLEXBISON_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/flexbison
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/flexbison ${DEFAULT_C_FLAGS} ${FLEXBISON_EXTRA_ARGS}
  CONFIGURE_COMMAND echo .
  BUILD_COMMAND echo . 
  INSTALL_COMMAND COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_BINARY_DIR}/build/flexbison/src/external_flexbison/ ${LIBDIR}/flexbison/ 
  INSTALL_DIR ${LIBDIR}/flexbison
)



set(OSL_VERSION 1.7.1)
set(OSL_URI https://github.com/imageworks/OpenShadingLanguage/archive/Release-${OSL_VERSION}.zip)
set(OSL_HASH 0cd09f4d736f33baa4ec566f5ba527f0)
set(OSL_CMAKE_CXX_FLAGS_DEBUG "/D_DEBUG /MTd /Zi /Ob0 /Od /RTC1 /DOIIO_STATIC_BUILD /DTINYFORMAT_ALLOW_WCHAR_STRINGS")
set(OSL_CMAKE_CXX_FLAGS_MINSIZEREL "/MT /O1 /Ob1 /D NDEBUG /DOIIO_STATIC_BUILD /DTINYFORMAT_ALLOW_WCHAR_STRINGS")
set(OSL_CMAKE_CXX_FLAGS_RELEASE "/MT /O2 /Ob2 /D NDEBUG /DOIIO_STATIC_BUILD /DTINYFORMAT_ALLOW_WCHAR_STRINGS")
set(OSL_CMAKE_CXX_FLAGS_RELWITHDEBINFO "/MT /Zi /O2 /Ob1 /D NDEBUG /DOIIO_STATIC_BUILD /DTINYFORMAT_ALLOW_WCHAR_STRINGS")
set(OSL_CMAKE_CXX_STANDARD_LIBRARIES "kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib psapi.lib ${LIBDIR}/openimageio/lib/OpenImageIO_Util.lib ${LIBDIR}/png/lib/libpng16_static.lib ${LIBDIR}/jpg/lib/jpeg.lib ${LIBDIR}/tiff/lib/tiff.lib ${LIBDIR}/openexr/lib/IlmImf-2_2.lib")
set(OSL_ILMBASE_CUSTOM_LIBRARIES "${LIBDIR}/ilmbase/lib/Imath-2_2.lib^^${LIBDIR}/ilmbase/lib/Half.lib^^${LIBDIR}/ilmbase/lib/IlmThread-2_2.lib^^${LIBDIR}/ilmbase/lib/Iex-2_2.lib")
set(OSL_OPENIMAGEIO_LIBRARY "${LIBDIR}/openimageio/lib/OpenImageIO.lib^^${LIBDIR}/openimageio/lib/OpenImageIO_Util.lib^^${LIBDIR}/png/lib/libpng16.lib^^${LIBDIR}/jpg/lib/jpeg.lib^^${LIBDIR}/tiff/lib/tiff.lib^^${LIBDIR}/openexr/lib/IlmImf-2_2.lib")
set(OSL_LLVM_LIBRARY "${LIBDIR}/llvm/lib/LLVMAnalysis.lib^^${LIBDIR}/llvm/lib/LLVMAsmParser.lib^^${LIBDIR}/llvm/lib/LLVMAsmPrinter.lib^^${LIBDIR}/llvm/lib/LLVMBitReader.lib^^${LIBDIR}/llvm/lib/LLVMBitWriter.lib^^${LIBDIR}/llvm/lib/LLVMCodeGen.lib^^${LIBDIR}/llvm/lib/LLVMCore.lib^^${LIBDIR}/llvm/lib/LLVMDebugInfo.lib^^${LIBDIR}/llvm/lib/LLVMExecutionEngine.lib^^${LIBDIR}/llvm/lib/LLVMInstCombine.lib^^${LIBDIR}/llvm/lib/LLVMInstrumentation.lib^^${LIBDIR}/llvm/lib/LLVMInterpreter.lib^^${LIBDIR}/llvm/lib/LLVMJIT.lib^^${LIBDIR}/llvm/lib/LLVMLinker.lib^^${LIBDIR}/llvm/lib/LLVMMC.lib^^${LIBDIR}/llvm/lib/LLVMMCDisassembler.lib^^${LIBDIR}/llvm/lib/LLVMMCJIT.lib^^${LIBDIR}/llvm/lib/LLVMMCParser.lib^^${LIBDIR}/llvm/lib/LLVMObject.lib^^${LIBDIR}/llvm/lib/LLVMRuntimeDyld.lib^^${LIBDIR}/llvm/lib/LLVMScalarOpts.lib^^${LIBDIR}/llvm/lib/LLVMSelectionDAG.lib^^${LIBDIR}/llvm/lib/LLVMSupport.lib^^${LIBDIR}/llvm/lib/LLVMTableGen.lib^^${LIBDIR}/llvm/lib/LLVMTarget.lib^^${LIBDIR}/llvm/lib/LLVMTransformUtils.lib^^${LIBDIR}/llvm/lib/LLVMVectorize.lib^^${LIBDIR}/llvm/lib/LLVMX86AsmParser.lib^^${LIBDIR}/llvm/lib/LLVMX86AsmPrinter.lib^^${LIBDIR}/llvm/lib/LLVMX86CodeGen.lib^^${LIBDIR}/llvm/lib/LLVMX86Desc.lib^^${LIBDIR}/llvm/lib/LLVMX86Disassembler.lib^^${LIBDIR}/llvm/lib/LLVMX86Info.lib^^${LIBDIR}/llvm/lib/LLVMX86Utils.lib^^${LIBDIR}/llvm/lib/LLVMipa.lib^^${LIBDIR}/llvm/lib/LLVMipo.lib")
set(OSL_CMAKE_CXX_STANDARD_LIBRARIES "kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib psapi.lib ${LIBDIR}/ilmbase/lib/Imath-2_2.lib ${LIBDIR}/ilmbase/lib/Half.lib ${LIBDIR}/ilmbase/lib/IlmThread-2_2.lib ${LIBDIR}/ilmbase/lib/Iex-2_2.lib") 
set(OSL_EXTRA_ARGS 
	-DBoost_COMPILER:STRING=${BOOST_COMPILER_STRING}
	-DBoost_USE_MULTITHREADED=ON 
	-DBoost_USE_STATIC_LIBS=ON 
	-DBoost_USE_STATIC_RUNTIME=ON 
	-DBOOST_ROOT=${LIBDIR}/boost 
	-DBOOST_LIBRARYDIR=${LIBDIR}/boost/lib/
	-DOPENEXR_INCLUDE_DIR=${LIBDIR}/openexr/include/ 
	-DOPENEXR_ILMIMF_LIBRARIES=${LIBDIR}/openexr/lib/IlmImf-2_2.lib
	-DILMBASE_CUSTOM=ON
	-DILMBASE_CUSTOM_LIBRARIES=${OSL_ILMBASE_CUSTOM_LIBRARIES}
	-DILMBASE_CUSTOM_INCLUDE_DIR=${LIBDIR}/ilmbase/include 
	-DILMBASE_CUSTOM_LIB_DIR=${LIBDIR}/ilmbase/lib 
	-DLLVM_DIRECTORY=${LIBDIR}/llvm 
	-DLLVM_INCLUDES=${LIBDIR}/llvm/include 
	-DLLVM_LIB_DIR=${LIBDIR}/llvm/lib 
	-DLLVM_VERSION=3.4 
	-DLLVM_LIBRARY=${OSL_LLVM_LIBRARY} 
	-DILMBASE_HOME=${LIBDIR}/openexr 
	-DILMBASE_VERSION=2_2 
	-USE_SIMD=sse2  
	-DOSL_BUILD_TESTS=OFF 
    -DZLIB_LIBRARY=${LIBDIR}/zlib/lib/zlibstatic.lib
    -DZLIB_INCLUDE_DIR=${LIBDIR}/zlib/include/
    -DOPENIMAGEIOHOME=${LIBDIR}/OpenImageIO 
	-DOPENIMAGEIO_LIBRARY=${OSL_OPENIMAGEIO_LIBRARY}
    -DFLEX_EXECUTABLE=${LIBDIR}/flexbison/win_flex.exe 
	-DFLEX_EXTRA_OPTIONS=--wincompat
    -DBISON_EXECUTABLE=${LIBDIR}/flexbison/win_bison.exe 
    -DCMAKE_CXX_FLAGS_DEBUG=${OSL_CMAKE_CXX_FLAGS_DEBUG}
    -DCMAKE_CXX_FLAGS_MINSIZEREL=${OSL_CMAKE_CXX_FLAGS_MINSIZEREL}
    -DCMAKE_CXX_FLAGS_RELEASE=${OSL_CMAKE_CXX_FLAGS_RELEASE}
    -DCMAKE_CXX_FLAGS_RELWITHDEBINFO=${OSL_CMAKE_CXX_FLAGS_RELWITHDEBINFO} 
    -DCMAKE_CXX_STANDARD_LIBRARIES=${OSL_CMAKE_CXX_STANDARD_LIBRARIES}
	-DBUILDSTATIC=ON
	-DLINKSTATIC=ON
	-DOSL_BUILD_PLUGINS=Off 
)  

ExternalProject_Add(external_osl
  URL ${OSL_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  LIST_SEPARATOR ^^
  URL_HASH MD5=${OSL_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/osl
  PATCH_COMMAND ${PATCH_CMD} -p 3 -d ${CMAKE_CURRENT_BINARY_DIR}/build/osl/src/external_osl < ${CMAKE_CURRENT_SOURCE_DIR}/diffs/osl_171.diff 
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/osl -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} ${DEFAULT_C_FLAGS} ${OSL_EXTRA_ARGS} 
  INSTALL_DIR ${LIBDIR}/osl
)
add_dependencies(external_osl external_boost external_llvm external_clang external_ilmbase external_openexr external_zlib external_flexbison)


set(PYTHON_VERSION 3.5.1)
set(PYTHON_URI https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz)
set(PYTHON_HASH e9ea6f2623fffcdd871b7b19113fde80)
set(PYTHON_EXTRA_ARGS 
   )

#ExternalProject_Add(external_python
#  URL ${PYTHON_URI}
#  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
#  URL_HASH MD5=${PYTHON_HASH}
#  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/python
#  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/python ${DEFAULT_C_FLAGS} ${DEFAULT_CXX_FLAGS} ${PYTHON_EXTRA_ARGS}
#  INSTALL_DIR ${LIBDIR}/python
#)



set(TBB_VERSION 44_20160128)
set(TBB_URI https://www.threadingbuildingblocks.org/sites/default/files/software_releases/source/tbb${TBB_VERSION}oss_src_0.tgz )
set(TBB_HASH 9d8a4cdf43496f1b3f7c473a5248e5cc)
set(TBB_EXTRA_ARGS 
	-DTBB_BUILD_SHARED=Off
	-DTBB_BUILD_TBBMALLOC=Off
	-DTBB_BUILD_TBBMALLOC_PROXY=Off
	-DTBB_BUILD_STATIC=On
   )

#Cmake script for tbb from https://github.com/wjakob/tbb/blob/master/CMakeLists.txt
ExternalProject_Add(external_tbb
  URL ${TBB_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${TBB_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/tbb
  PATCH_COMMAND COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/diffs/cmakelists_tbb.txt  ${CMAKE_CURRENT_BINARY_DIR}/build/tbb/src/external_tbb/cmakelists.txt &&  
						${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/build/tbb/src/external_tbb/build/vs2010/version_string.ver ${CMAKE_CURRENT_BINARY_DIR}/build/tbb/src/external_tbb/src/tbb/version_string.ver
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/tbb ${DEFAULT_C_FLAGS} ${DEFAULT_CXX_FLAGS} ${TBB_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/tbb
)


set(OPENVDB_VERSION 3_1_0)
set(OPENVDB_URI http://www.openvdb.org/download/openvdb_${OPENVDB_VERSION}_library.zip )
set(OPENVDB_HASH 0e25a2e183c46963899ab3f77e3533ac)
set(OPENVDB_EXTRA_ARGS 
	-DOPENEXR_HOME=${LIBDIR}/openexr/
	-DILMBASE_INCLUDE_DIR=${LIBDIR}/ilmbase/include/
    -DILMBASE_HALF_LIBRARIES=${LIBDIR}/ilmbase/lib/Half.lib 
    -DILMBASE_IMATH_LIBRARIES=${LIBDIR}/ilmbase/lib/Imath-2_2.lib 
    -DILMBASE_ILMTHREAD_LIBRARIES=${LIBDIR}/ilmbase/lib/IlmThread-2_2.lib 
    -DILMBASE_IEX_LIBRARIES=${LIBDIR}/ilmbase/lib/Iex-2_2.lib 
	-DOPENEXR_INCLUDE_DIR=${LIBDIR}/openexr/include/ 
	-DOPENEXR_ILMIMF_LIBRARIES=${LIBDIR}/openexr/lib/IlmImf-2_2.lib 
	-DTBB_ROOT_DIR=${LIBDIR}/tbb/
	-DTBB_LIBRARY=${LIBDIR}/tbb/lib/tbb_static.lib
	-DBoost_COMPILER:STRING=${BOOST_COMPILER_STRING}
	-DBoost_USE_MULTITHREADED=ON 
	-DBoost_USE_STATIC_LIBS=ON 
	-DBoost_USE_STATIC_RUNTIME=ON 
	-DBOOST_ROOT=${LIBDIR}/boost 
    -DZLIB_LIBRARY=${LIBDIR}/zlib/lib/zlibstatic.lib
	-DZLIB_INCLUDE_DIR=${LIBDIR}/zlib/include/

   )

set(OPENVDB_CMAKE_CXX_FLAGS_DEBUG "/bigobj /D_DEBUG /D PLATFORM_WINDOWS /MTd /Zi /Ob0 /Od /RTC1" )
set(OPENVDB_CXX_FLAGS
 -DCMAKE_CXX_FLAGS_DEBUG=${OPENVDB_CMAKE_CXX_FLAGS_DEBUG}
 -DCMAKE_CXX_FLAGS_MINSIZEREL=${BLEND_CXX_FLAGS_MINSIZEREL}
 -DCMAKE_CXX_FLAGS_RELEASE=${BLEND_C_FLAGS_RELEASE}
 -DCMAKE_CXX_FLAGS_RELWITHDEBINFO=${BLEND_C_FLAGS_RELWITHDEBINFO}
 )

#cmake script for openvdb based on https://raw.githubusercontent.com/diekev/openvdb-cmake/master/CMakeLists.txt
#can't be in external_openvdb because of how the includes are setup. 


ExternalProject_Add(openvdb
  URL ${OPENVDB_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${OPENVDB_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/openvdb
  PATCH_COMMAND COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/diffs/cmakelists_openvdb.txt  ${CMAKE_CURRENT_BINARY_DIR}/build/openvdb/src/openvdb/cmakelists.txt &&
                        ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/diffs/cmake/  ${CMAKE_CURRENT_BINARY_DIR}/build/openvdb/src/openvdb/cmake/ &&
                        ${PATCH_CMD} --verbose -p 0 -d ${CMAKE_CURRENT_BINARY_DIR}/build/openvdb/src/openvdb < ${CMAKE_CURRENT_SOURCE_DIR}/diffs/openvdb_vc2013.diff 
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/openvdb ${DEFAULT_C_FLAGS} ${OPENVDB_CXX_FLAGS} ${OPENVDB_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/openvdb
)

add_dependencies(openvdb external_tbb external_boost external_ilmbase external_openexr external_zlib)


if (ENABLE_MINGW64)
####################################################################################################################
# Mingw64 Builds
####################################################################################################################
# This installs mingw64+msys to compile ffmpeg/iconv/libsndfile/lapack/fftw3
####################################################################################################################

message("LIBDIR = ${LIBDIR}")
macro(cmake_to_msys_path MsysPath ResultingPath)
  string(REPLACE ":" "" TmpPath "${MsysPath}" )
  string(SUBSTRING ${TmpPath} 0 1 Drive)
  string(SUBSTRING ${TmpPath} 1 255 PathPart)
  string(TOLOWER ${Drive} LowerDrive)
  string(CONCAT ${ResultingPath} "/" ${LowerDrive} ${PathPart} )
endmacro()
cmake_to_msys_path(${LIBDIR} mingw_LIBDIR)
message("mingw_LIBDIR = ${mingw_LIBDIR}")
Message("Checking for mingw64")
#download ming64
if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/x86_64-w64-mingw32-gcc-4.8.0-win64_rubenvb.7z")
	Message("Downloading mingw64")
	file(DOWNLOAD "http://heanet.dl.sourceforge.net/project/mingw-w64/Toolchains%20targetting%20Win64/Personal%20Builds/rubenvb/gcc-4.8-release/x86_64-w64-mingw32-gcc-4.8.0-win64_rubenvb.7z" "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/x86_64-w64-mingw32-gcc-4.8.0-win64_rubenvb.7z") 
endif()

#make mingw root directory
if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/mingw")
    EXECUTE_PROCESS(
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_SOURCE_DIR}/mingw
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif()

#extract mingw64
if ( (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/mingw64env.cmd") AND (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/x86_64-w64-mingw32-gcc-4.8.0-win64_rubenvb.7z") )
	Message("Extracting mingw64")
    EXECUTE_PROCESS(
        COMMAND ${CMAKE_COMMAND} -E tar jxf ${CMAKE_CURRENT_SOURCE_DIR}/Downloads/x86_64-w64-mingw32-gcc-4.8.0-win64_rubenvb.7z
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/mingw
    )
endif()

Message("Checking for pkg-config")
if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/pkg-config-lite-0.28-1_bin-win32.zip")
	Message("Downloading pkg-config")
    file(DOWNLOAD "http://heanet.dl.sourceforge.net/project/pkgconfiglite/0.28-1/pkg-config-lite-0.28-1_bin-win32.zip" "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/pkg-config-lite-0.28-1_bin-win32.zip")
endif()

#extract pkgconfig
if ( (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/pkg-config.exe") AND (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/pkg-config-lite-0.28-1_bin-win32.zip") )
    Message("Extracting pkg-config")
	EXECUTE_PROCESS(
        COMMAND ${CMAKE_COMMAND} -E tar jxf "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/pkg-config-lite-0.28-1_bin-win32.zip"
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
    )

	EXECUTE_PROCESS(
		COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/pkg-config-lite-0.28-1/bin/pkg-config.exe" "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/pkg-config.exe"
    )	

endif()




Message("Checking for nasm")
if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/nasm-2.12.01-win64.zip")
	Message("Downloading nasm")
    file(DOWNLOAD "http://www.nasm.us/pub/nasm/releasebuilds/2.12.01/win64/nasm-2.12.01-win64.zip" "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/nasm-2.12.01-win64.zip")
endif()

#extract nasm
if ( (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/nasm.exe") AND (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/nasm-2.12.01-win64.zip") )
    Message("Extracting nasm")
	EXECUTE_PROCESS(
        COMMAND ${CMAKE_COMMAND} -E tar jxf "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/nasm-2.12.01-win64.zip"
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
    )
	EXECUTE_PROCESS(
		COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/nasm-2.12.01/nasm.exe" "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/nasm.exe"
    )	

endif()



Message("Checking for mingwGet")
if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip")
	Message("Downloading mingw-get")
    file(DOWNLOAD "http://heanet.dl.sourceforge.net/project/mingw/Installer/mingw-get/mingw-get-0.6.2-beta-20131004-1/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip" "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip")
endif()
 
#extract mingw_get
if ( (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/mingw-get.exe") AND (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip") )
    Message("Extracting mingw-get")
	EXECUTE_PROCESS(
        COMMAND ${CMAKE_COMMAND} -E tar jxf "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip"
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/
    )
endif()

if ( (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/mingw-get.exe") AND (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/msys/1.0/bin/make.exe") )
	Message("Installing MSYS")
	EXECUTE_PROCESS(
        COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/mingw-get install msys msys-patch
        WORKING_DIRECTORY  ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/
    )
endif()

Message("Checking for CoreUtils")
#download old core_utils for pr.exe (ffmpeg needs it to build)
if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/coreutils-5.97-MSYS-1.0.11-snapshot.tar.bz2")
	Message("Downloading CoreUtils 5.97")
	file(DOWNLOAD "http://heanet.dl.sourceforge.net/project/mingw/MSYS/Base/msys-core/_obsolete/coreutils-5.97-MSYS-1.0.11-2/coreutils-5.97-MSYS-1.0.11-snapshot.tar.bz2" "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/coreutils-5.97-MSYS-1.0.11-snapshot.tar.bz2") 
endif()

if ( (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/coreutils-5.97-MSYS-1.0.11-snapshot.tar.bz2") AND (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/msys/1.0/bin/pr.exe") )
	Message("Installing pr from CoreUtils 5.97")
    EXECUTE_PROCESS(
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_SOURCE_DIR}/tmp_coreutils
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )

    EXECUTE_PROCESS(
        COMMAND ${CMAKE_COMMAND} -E tar jxf ${CMAKE_CURRENT_SOURCE_DIR}/Downloads/coreutils-5.97-MSYS-1.0.11-snapshot.tar.bz2
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/tmp_coreutils/
    )

    EXECUTE_PROCESS(
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/tmp_coreutils/coreutils-5.97/bin/pr.exe "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/msys/1.0/bin/pr.exe"
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/tmp_coreutils/
    )
endif()

if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/ming64sh.cmd") 
	Message("Installing ming64sh.cmd")
	EXECUTE_PROCESS(
		COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/diffs/ming64sh.cmd  ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/ming64sh.cmd 
    )
endif()

Message("Checking for perl")
#download perl for libvpx
if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/strawberry-perl-5.22.1.3-64bit-portable.zip")
	Message("Downloading perl")
	file(DOWNLOAD "http://strawberryperl.com/download/5.22.1.3/strawberry-perl-5.22.1.3-64bit-portable.zip" "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/strawberry-perl-5.22.1.3-64bit-portable.zip") 
endif()

#make perl root directory
if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/perl")
    EXECUTE_PROCESS(
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_SOURCE_DIR}/perl
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif()

#extract perl
if ( (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/perl/portable.perl") AND (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Downloads/strawberry-perl-5.22.1.3-64bit-portable.zip") )
	Message("Extracting perl")
    EXECUTE_PROCESS(
        COMMAND ${CMAKE_COMMAND} -E tar jxf ${CMAKE_CURRENT_SOURCE_DIR}/Downloads/strawberry-perl-5.22.1.3-64bit-portable.zip
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/perl
    )
endif()

#get yasm for vpx
if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/yasm.exe")
	Message("Downloading yasm")
	file(DOWNLOAD "http://www.tortall.net/projects/yasm/releases/yasm-1.3.0-win64.exe" "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/yasm.exe") 
endif()

Message("checking x86_64-w64-mingw32-strings.exe")
#copy strings.exe to x86_64-w64-mingw32-strings.exe for x264
if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/x86_64-w64-mingw32-strings.exe")
	Message("fixing x86_64-w64-mingw32-strings.exe")
	EXECUTE_PROCESS(
		COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/strings.exe" "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/x86_64-w64-mingw32-strings.exe"
    )	
endif()

Message("checking x86_64-w64-mingw32-ar.exe")
#copy ar.exe to x86_64-w64-mingw32-ar.exe for x264
if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/x86_64-w64-mingw32-ar.exe")
	Message("fixing x86_64-w64-mingw32-ar.exe")
	EXECUTE_PROCESS(
		COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/ar.exe" "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/x86_64-w64-mingw32-ar.exe"
    )	
endif()

Message("checking x86_64-w64-mingw32-strip.exe")
#copy strip.exe to x86_64-w64-mingw32-strip.exe for x264
if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/x86_64-w64-mingw32-strip.exe")
	Message("fixing x86_64-w64-mingw32-strip.exe")
	EXECUTE_PROCESS(
		COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/strip.exe" "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/x86_64-w64-mingw32-strip.exe"
    )	
endif()

Message("checking x86_64-w64-mingw32-ranlib.exe")
#copy ranlib.exe to x86_64-w64-mingw32-ranlib.exe for x264
if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/x86_64-w64-mingw32-ranlib.exe")
	Message("fixing x86_64-w64-mingw32-ranlib.exe")
	EXECUTE_PROCESS(
		COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/ranlib.exe" "${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/x86_64-w64-mingw32-ranlib.exe"
    )	
endif()


if (BUILD_MODE STREQUAL Release)
Message("CXX = ${CMAKE_CXX_COMPILER}")


set(LAME_VERSION 3.99.5)
set(LAME_URI http://downloads.sourceforge.net/project/lame/lame/3.99/lame-${LAME_VERSION}.tar.gz)
set(LAME_HASH 84835b313d4a8b68f5349816d33e07ce)
set(LAME_EXTRA_ARGS  )
ExternalProject_Add(external_lame
  URL ${LAME_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${LAME_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/lame
  CONFIGURE_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/lame/src/external_lame/ && set CFLAGS=-g && set LDFLAGS=-Wl,--as-needed -static-libgcc && sh ./configure --prefix=${LIBDIR}/lame --disable-shared --enable-static 
    --enable-export=full 
    --with-fileio=sndfile 
    --without-vorbis
    --with-pic 
    --disable-mp3x 
    --disable-mp3rtp 
    --disable-gtktest 
    --enable-export=full  
  BUILD_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/lame/src/external_lame/ && make 
  INSTALL_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/lame/src/external_lame/ && make install
  INSTALL_DIR ${LIBDIR}/lame
)

set(OGG_VERSION 1.3.2)
set(OGG_URI http://downloads.xiph.org/releases/ogg/libogg-${OGG_VERSION}.tar.gz)
set(OGG_HASH e19ee34711d7af328cb26287f4137e70630e7261b17cbe3cd41011d73a654692)
ExternalProject_Add(external_ogg
  URL ${OGG_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH SHA256=${OGG_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/ogg
  CONFIGURE_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/ogg/src/external_ogg/ && set CFLAGS=-g && set LDFLAGS=-Wl,--as-needed -static-libgcc && sh ./configure --prefix=${LIBDIR}/ogg --disable-shared --enable-static 
  BUILD_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/ogg/src/external_ogg/ && make 
  INSTALL_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/ogg/src/external_ogg/ && make install
  INSTALL_DIR ${LIBDIR}/ogg
)

set(VORBIS_VERSION 1.3.5)
set(VORBIS_URI http://downloads.xiph.org/releases/vorbis/libvorbis-${VORBIS_VERSION}.tar.gz)
set(VORBIS_HASH 6efbcecdd3e5dfbf090341b485da9d176eb250d893e3eb378c428a2db38301ce)
ExternalProject_Add(external_vorbis
  URL ${VORBIS_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH SHA256=${VORBIS_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/vorbis
  CONFIGURE_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/vorbis/src/external_vorbis/ && set CFLAGS=-g && set LDFLAGS=-Wl,--as-needed -static-libgcc && sh ./configure --prefix=${LIBDIR}/vorbis --disable-shared --enable-static 
    --with-pic 
    --with-ogg=${LIBDIR}/ogg
  BUILD_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/vorbis/src/external_vorbis/ && make 
  INSTALL_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/vorbis/src/external_vorbis/ && make install
  INSTALL_DIR ${LIBDIR}/vorbis
)
add_dependencies(external_vorbis external_ogg)

set(THEORA_VERSION 1.1.1)
set(THEORA_URI http://downloads.xiph.org/releases/theora/libtheora-${THEORA_VERSION}.tar.bz2)
set(THEORA_HASH b6ae1ee2fa3d42ac489287d3ec34c5885730b1296f0801ae577a35193d3affbc)
ExternalProject_Add(external_theora
  URL ${THEORA_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH SHA256=${THEORA_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/theora
  CONFIGURE_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/theora/src/external_theora/ && set CFLAGS=-g && set LDFLAGS=-Wl,--as-needed -static-libgcc && sh ./configure --prefix=${LIBDIR}/theora --disable-shared --enable-static 
    --with-pic 
    --with-ogg=${LIBDIR}/ogg
    --with-vorbis=${LIBDIR}/vorbis
  BUILD_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/theora/src/external_theora/ && make 
  INSTALL_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/theora/src/external_theora/ && make install
  INSTALL_DIR ${LIBDIR}/theora
)
add_dependencies(external_theora external_vorbis external_ogg)

set(VPX_VERSION 1.5.0)
set(VPX_URI http://storage.googleapis.com/downloads.webmproject.org/releases/webm/libvpx-${VPX_VERSION}.tar.bz2)
set(VPX_HASH 306d67908625675f8e188d37a81fbfafdf5068b09d9aa52702b6fbe601c76797)
ExternalProject_Add(external_vpx
  URL ${VPX_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH SHA256=${VPX_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/vpx
  CONFIGURE_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && 
	 call ming64sh.cmd && 
	 call ${CMAKE_CURRENT_SOURCE_DIR}/perl/portableshell.bat  &&
	 set path && 
	 cd ${CMAKE_CURRENT_BINARY_DIR}/build/vpx/src/external_vpx/ && 
	 sh ./configure --prefix=${LIBDIR}/vpx --disable-shared --enable-static 
    --disable-install-bins 
    --disable-install-srcs 
    --disable-sse4_1 
    --disable-sse3 
    --disable-ssse3 
    --disable-avx 
    --disable-avx2 
    --disable-unit-tests 
    --disable-examples  
	--target=x86_64-win64-gcc
  BUILD_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ${CMAKE_CURRENT_SOURCE_DIR}/perl/portableshell.bat  && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/vpx/src/external_vpx/ && make 
  INSTALL_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ${CMAKE_CURRENT_SOURCE_DIR}/perl/portableshell.bat && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/vpx/src/external_vpx/ && make install
  INSTALL_DIR ${LIBDIR}/vpx
)

set(ORC_VERSION 0.4.25)
set(ORC_URI https://gstreamer.freedesktop.org/src/orc/orc-${ORC_VERSION}.tar.xz)
set(ORC_HASH c1b1d54a58f26d483f0b3881538984789fe5d5460ab8fab74a1cacbd3d1c53d1)
ExternalProject_Add(external_orc
  URL ${ORC_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH SHA256=${ORC_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/orc
  CONFIGURE_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/orc/src/external_orc/ && set CFLAGS=-g  && set LDFLAGS=-Wl,--as-needed -static-libgcc && sh ./configure --prefix=${LIBDIR}/orc --disable-shared --enable-static 
  BUILD_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/orc/src/external_orc/ && make 
  INSTALL_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/orc/src/external_orc/ && make install
  INSTALL_DIR ${LIBDIR}/orc
)

set(SCHROEDINGER_VERSION 1.0.11)
set(SCHROEDINGER_URI http://diracvideo.org/download/schroedinger/schroedinger-${SCHROEDINGER_VERSION}.tar.gz)
set(SCHROEDINGER_HASH 1e572a0735b92aca5746c4528f9bebd35aa0ccf8619b22fa2756137a8cc9f912)
ExternalProject_Add(external_schroedinger
  URL ${SCHROEDINGER_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH SHA256=${SCHROEDINGER_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/schroedinger
  PATCH_COMMAND ${PATCH_CMD} --verbose -p 0 -d ${CMAKE_CURRENT_BINARY_DIR}/build/schroedinger/src/external_schroedinger < ${CMAKE_CURRENT_SOURCE_DIR}/diffs/schroedinger.diff  
  CONFIGURE_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && 
                    call ming64sh.cmd && 
					set path && 
					cd ${CMAKE_CURRENT_BINARY_DIR}/build/schroedinger/src/external_schroedinger/ && 
					set CFLAGS=-g -I./ -I${LIBDIR}/orc/include/orc-0.4 && set LDFLAGS=-Wl,--as-needed -static-libgcc -L${LIBDIR}/orc/lib &&  
					set ORC_CFLAGS=-I${LIBDIR}/orc/include/orc-0.4 && 
					set ORC_LDFLAGS=-L${LIBDIR}/orc/lib && 
					set ORC_LIBS=${LIBDIR}/orc/lib/liborc-0.4.a && set ORCC=${LIBDIR}/orc/bin/orcc.exe && sh ./configure --prefix=${LIBDIR}/schroedinger --disable-shared --enable-static 
  BUILD_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/schroedinger/src/external_schroedinger/ && make 
  INSTALL_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/schroedinger/src/external_schroedinger/ && make install
  INSTALL_DIR ${LIBDIR}/schroedinger
)
add_dependencies(external_schroedinger external_orc)

set(X264_URI http://download.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-20160401-2245-stable.tar.bz2)
set(X264_HASH 1e9a7b835e80313aade53a9b6ff353e099de3856bf5f30a4d8dfc91281f786f5)
ExternalProject_Add(external_x264
  URL ${X264_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH SHA256=${X264_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/x264
  CONFIGURE_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/x264/src/external_x264/ && set CFLAGS=-g && set LDFLAGS=-Wl,--as-needed -static-libgcc && sh ./configure --prefix=${LIBDIR}/x264 --enable-static --enable-win32thread --disable-lavf  --cross-prefix=x86_64-w64-mingw32- --host=x86_64-w64-mingw32
  BUILD_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/x264/src/external_x264/ && make 
  INSTALL_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/x264/src/external_x264/ && make install
  INSTALL_DIR ${LIBDIR}/x264
)


set(XVIDCORE_VERSION 1.3.4)
set(XVIDCORE_URI http://downloads.xvid.org/downloads/xvidcore-${XVIDCORE_VERSION}.tar.gz)
set(XVIDCORE_HASH 4e9fd62728885855bc5007fe1be58df42e5e274497591fec37249e1052ae316f)
ExternalProject_Add(external_xvidcore
  URL ${XVIDCORE_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH SHA256=${XVIDCORE_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/xvidcore
  CONFIGURE_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/xvidcore/src/external_xvidcore/build/generic && set CFLAGS=-g && set LDFLAGS=-Wl,--as-needed -static-libgcc && sh ./configure --prefix=${LIBDIR}/xvidcore --host=x86_64-w64-mingw32
  BUILD_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/xvidcore/src/external_xvidcore/build/generic && make 
  INSTALL_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/xvidcore/src/external_xvidcore/build/generic && make install
  INSTALL_DIR ${LIBDIR}/xvidcore
)
 ExternalProject_Add_Step(external_xvidcore after_install
 COMMAND ${CMAKE_COMMAND} -E rename ${LIBDIR}/xvidcore/lib/xvidcore.a  ${LIBDIR}/xvidcore/lib/libxvidcore.a
 COMMAND ${CMAKE_COMMAND} -E remove ${LIBDIR}/xvidcore/lib/xvidcore.dll.a
 DEPENDEES install
  )

#ffmpeg does not recognize 2.1 currently 
set(OPENJPEG_VERSION 2.0)
set(OPENJPEG_URI https://github.com/uclouvain/openjpeg/archive/version.${OPENJPEG_VERSION}.tar.gz)
set(OPENJPEG_HASH 5480f801a9f88af1a456145e41f3adede1dfae425bbac66a19c7eeeba94a1249)
set(OPENJPEG_EXTRA_ARGS 
	-DBUILD_SHARED_LIBS=Off
)
ExternalProject_Add(external_openjpeg
  URL ${OPENJPEG_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH SHA256=${OPENJPEG_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/openjpeg
  CONFIGURE_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/openjpeg/src/external_openjpeg-build && ${CMAKE_COMMAND} -G "MSYS Makefiles" -DCMAKE_INSTALL_PREFIX=${LIBDIR}/openjpeg -DBUILD_SHARED_LIBS=Off -DBUILD_THIRDPARTY=On ${CMAKE_CURRENT_BINARY_DIR}/build/openjpeg/src/external_openjpeg
  BUILD_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/openjpeg/src/external_openjpeg-build/ && make 
  INSTALL_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/openjpeg/src/external_openjpeg-build/ && make install
  INSTALL_DIR ${LIBDIR}/openjpeg
)


set(FAAD_VERSION 2-2.7)
set(FAAD_URI http://downloads.sourceforge.net/faac/faad${FAAD_VERSION}.tar.bz2)
set(FAAD_HASH 4c332fa23febc0e4648064685a3d4332)
set(FAAD_EXTRA_ARGS  )
ExternalProject_Add(external_faad
  URL ${FAAD_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${FAAD_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/faad
  PATCH_COMMAND ${PATCH_CMD} --verbose -p 0 -d ${CMAKE_CURRENT_BINARY_DIR}/build/faad/src/external_faad < ${CMAKE_CURRENT_SOURCE_DIR}/diffs/libfaad.diff 
  CONFIGURE_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/faad/src/external_faad/ && set CFLAGS=-g && set LDFLAGS=-Wl,--as-needed -static-libgcc && sh ./configure --disable-shared --enable-static --prefix=${LIBDIR}/faad
  BUILD_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/faad/src/external_faad/ && make 
  INSTALL_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/faad/src/external_faad/ && make install
  INSTALL_DIR ${LIBDIR}/faad
)

set(FFMPEG_VERSION 3.0)
set(FFMPEG_URI http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2)
set(FFMPEG_HASH 026859cc76dddffd809cad879db07658)
set(FFMPEG_EXTRA_ARGS  )

ExternalProject_Add(external_ffmpeg
  URL ${FFMPEG_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${FFMPEG_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/ffmpeg
  CONFIGURE_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && 
				    call ming64sh.cmd && 
					cd ${CMAKE_CURRENT_BINARY_DIR}/build/ffmpeg/src/external_ffmpeg/ && 
					set CFLAGS=-I${mingw_LIBDIR}/lame/include -I${mingw_LIBDIR}/openjpeg/include/ -I${mingw_LIBDIR}/ogg/include -I${mingw_LIBDIR}/vorbis/include -I${mingw_LIBDIR}/theora/include -I${mingw_LIBDIR}/vpx/include -I${mingw_LIBDIR}/x264/include -I${mingw_LIBDIR}/xvidcore/include -I${mingw_LIBDIR}/dirac/include/dirac -I${mingw_LIBDIR}/schroedinger/include/schroedinger-1.0 -I${mingw_LIBDIR}/zlib/include &&
					set LDFLAGS=-L${mingw_LIBDIR}/lame/lib -L${mingw_LIBDIR}/openjpeg/lib -L${mingw_LIBDIR}/ogg/lib -L${mingw_LIBDIR}/vorbis/lib -L${mingw_LIBDIR}/theora/lib -L${mingw_LIBDIR}/vpx/lib -L${mingw_LIBDIR}/x264/lib -L${mingw_LIBDIR}/xvidcore/lib -L${mingw_LIBDIR}/dirac/lib -L${mingw_LIBDIR}/schroedinger/lib -L${mingw_LIBDIR}/orc/lib -L${mingw_LIBDIR}/zlib/lib &&
					set PKG_CONFIG_PATH=${mingw_LIBDIR}/schroedinger/lib/pkgconfig:${mingw_LIBDIR}/orc/lib/pkgconfig:${mingw_LIBDIR} &&
		sh ./configure 
		--enable-shared 
		--disable-static 
		--disable-avfilter 
		--disable-vdpau  
		--disable-bzlib 
		--disable-libgsm 
		--disable-libspeex 
		--enable-libvpx 
		--prefix=${LIBDIR}/ffmpeg 
		--enable-libschroedinger 
		--enable-libtheora 
		--enable-libvorbis 
		--enable-zlib 
		--enable-stripping 
		--enable-runtime-cpudetect 
		--disable-vaapi 
		--enable-libopenjpeg 
		--disable-nonfree 
		--enable-gpl 
		--disable-postproc 
		--disable-x11grab 
		--enable-libmp3lame 
		--disable-librtmp 
		--enable-libx264 
		--enable-libxvid 
		--disable-libopencore-amrnb 
		--disable-libopencore-amrwb 
		--disable-libdc1394 
		--disable-version3 
		--disable-debug 
		--enable-optimizations 
		--disable-sse 
		--disable-ssse3 
		--enable-ffplay 
		--enable-w32threads 
		--disable-pthreads 
  PATCH_COMMAND ${PATCH_CMD} --verbose -p 0 -d ${CMAKE_CURRENT_BINARY_DIR}/build/ffmpeg/src/external_ffmpeg < ${CMAKE_CURRENT_SOURCE_DIR}/diffs/ffmpeg.diff 
  BUILD_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/ffmpeg/src/external_ffmpeg/ && make 
  INSTALL_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/ffmpeg/src/external_ffmpeg/ && make install
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/ffmpeg ${DEFAULT_C_FLAGS} ${FFMPEG_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/ffmpeg
)  

add_dependencies(external_ffmpeg external_faad external_openjpeg external_xvidcore external_x264 external_schroedinger external_vpx external_theora external_vorbis external_ogg external_lame)

set(FFTW_VERSION 3.3.4)
set(FFTW_URI http://www.fftw.org/fftw-${FFTW_VERSION}.tar.gz)
set(FFTW_HASH 2edab8c06b24feeb3b82bbb3ebf3e7b3)
set(FFTW_EXTRA_ARGS  )

ExternalProject_Add(external_fftw3
  URL ${FFTW_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${FFTW_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/fftw3
  CONFIGURE_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/fftw3/src/external_fftw3/ && set CFLAGS=-fno-stack-check -fno-stack-protector -mno-stack-arg-probe && sh ./configure --enable-static --prefix=${mingw_LIBDIR}/fftw3 
  PATCH_COMMAND ${PATCH_CMD} --verbose -p 0 -d ${CMAKE_CURRENT_BINARY_DIR}/build/fftw3/src/external_fftw3 < ${CMAKE_CURRENT_SOURCE_DIR}/diffs/fftw3.diff 
  BUILD_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/fftw3/src/external_fftw3/ && make 
  INSTALL_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/fftw3/src/external_fftw3/ && make install
  INSTALL_DIR ${LIBDIR}/fftw3
)

set(ICONV_VERSION 1.14)
set(ICONV_URI http://ftp.gnu.org/pub/gnu/libiconv/libiconv-${ICONV_VERSION}.tar.gz)
set(ICONV_HASH e34509b1623cec449dfeb73d7ce9c6c6 ) 
set(ICONV_EXTRA_ARGS  
 
)

ExternalProject_Add(external_iconv
  URL ${ICONV_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${ICONV_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/iconv
  CONFIGURE_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/iconv/src/external_iconv/ && sh ./configure --enable-static --prefix=${mingw_LIBDIR}/iconv
  BUILD_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/iconv/src/external_iconv/ && make 
  INSTALL_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/iconv/src/external_iconv/ && make install
  INSTALL_DIR ${LIBDIR}/iconv
)


set(LAPACK_VERSION 3.6.0)
set(LAPACK_URI http://www.netlib.org/lapack/lapack-${LAPACK_VERSION}.tgz)
set(LAPACK_HASH f2f6c67134e851fe189bb3ca1fbb5101 ) 
set(LAPACK_EXTRA_ARGS  
 
)

ExternalProject_Add(external_lapack
  URL ${LAPACK_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${LAPACK_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/lapack
  CONFIGURE_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/lapack/src/external_lapack/ && ${CMAKE_COMMAND} -G "MSYS Makefiles" -DCMAKE_Fortran_COMPILER=${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64/bin/gfortran.exe -DCMAKE_INSTALL_PREFIX=${LIBDIR}/lapack . 
  BUILD_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/lapack/src/external_lapack/ && make 
  INSTALL_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/lapack/src/external_lapack/ && make install

  INSTALL_DIR ${LIBDIR}/lapack
)

set(SNDFILE_VERSION 1.0.26)
set(SNDFILE_URI http://www.mega-nerd.com/libsndfile/files/libsndfile-${SNDFILE_VERSION}.tar.gz)
set(SNDFILE_HASH ec810a0c60c08772a8a5552704b63393)
set(SNDFILE_EXTRA_ARGS 
   )

ExternalProject_Add(external_sndfile
  URL ${SNDFILE_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${SNDFILE_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/sndfile
  CONFIGURE_COMMAND  cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/sndfile/src/external_sndfile/ && sh ./configure --enable-static --prefix=${mingw_LIBDIR}/sndfile
  BUILD_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/sndfile/src/external_sndfile/ && make 
  INSTALL_COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}/mingw/mingw64 && call ming64sh.cmd && set path && cd ${CMAKE_CURRENT_BINARY_DIR}/build/sndfile/src/external_sndfile/ && make install
  INSTALL_DIR ${LIBDIR}/sndfile
)
endif(BUILD_MODE STREQUAL Release)
endif(ENABLE_MINGW64)
########################################################################
# Copy all generated files to the proper strucure as blender prefers
########################################################################


if(NOT DEFINED HARVEST_TARGET)
set(HARVEST_TARGET ${CMAKE_CURRENT_SOURCE_DIR}/Harvest )
endif()
message("HARVEST_TARGET = ${HARVEST_TARGET}")

if (BUILD_MODE STREQUAL Release)
add_custom_target( Harvest_Release_Results  
#Zlib Rename the lib file and copy the include/bin folders
                        COMMAND ${CMAKE_COMMAND} -E copy ${LIBDIR}/zlib/lib/zlibstatic.lib ${HARVEST_TARGET}/zlib/lib/libz_st.lib &&
							    ${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/zlib/include/ ${HARVEST_TARGET}/zlib/include/ &&
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/zlib/bin/ ${HARVEST_TARGET}/zlib/bin/ &&
#Boost copy lib + rename boost_1_60 to boost 
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/boost/lib/ ${HARVEST_TARGET}/boost/lib/ &&
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/boost/include/boost-1_60/ ${HARVEST_TARGET}/boost/include/ &&
#jpeg rename libfile + copy include 
								${CMAKE_COMMAND} -E copy ${LIBDIR}/jpg/lib/jpeg-static.lib ${HARVEST_TARGET}/jpeg/lib/libjpeg.lib &&
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/jpg/include/ ${HARVEST_TARGET}/jpeg/include/ &&
#FreeType, straight up copy 
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/freetype ${HARVEST_TARGET}/freetype && 
#pthreads, rename include dir
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/pthreads/inc/ ${HARVEST_TARGET}/pthreads/include/ &&
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/pthreads/lib/ ${HARVEST_TARGET}/pthreads/lib &&
#ffmpeg copy include+bin
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/ffmpeg/include ${HARVEST_TARGET}/ffmpeg/include && 
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/ffmpeg/bin ${HARVEST_TARGET}/ffmpeg/lib && 
#sdl merge bin/lib folder, copy include
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/sdl/include/sdl2 ${HARVEST_TARGET}/sdl/include && 
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/sdl/lib ${HARVEST_TARGET}/sdl/lib &&
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/sdl/bin ${HARVEST_TARGET}/sdl/lib &&
#openal 
								${CMAKE_COMMAND} -E copy ${LIBDIR}/openal/lib/openal32.lib ${HARVEST_TARGET}/openal/lib/openal32.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/openal/bin/openal32.dll ${HARVEST_TARGET}/openal/lib/openal32.dll &&
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/openal/include/ ${HARVEST_TARGET}/openal/include/  &&
#OpenImageIO
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/OpenImageIO/include ${HARVEST_TARGET}/OpenImageIO/include && 
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/OpenImageIO/lib ${HARVEST_TARGET}/OpenImageIO/lib &&
#openEXR
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/ilmbase ${HARVEST_TARGET}/openexr &&
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/openexr/lib ${HARVEST_TARGET}/openexr/lib &&
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/openexr/include ${HARVEST_TARGET}/openexr/include && 
#png
								${CMAKE_COMMAND} -E copy ${LIBDIR}/png/lib/libpng16_static.lib ${HARVEST_TARGET}/png/lib/libpng.lib &&
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/png/include/ ${HARVEST_TARGET}/png/include/  &&
#fftw3
								${CMAKE_COMMAND} -E copy ${LIBDIR}/fftw3/lib/libfftw3.a ${HARVEST_TARGET}/fftw3/lib/libfftw.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/fftw3/include/fftw3.h ${HARVEST_TARGET}/fftw3/include/fftw3.h &&
#freeglut-> opengl
								${CMAKE_COMMAND} -E copy ${LIBDIR}/freeglut/lib/freeglut_static.lib ${HARVEST_TARGET}/opengl/lib/freeglut_static.lib &&
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/freeglut/include/ ${HARVEST_TARGET}/opengl/include/  &&
#glew-> opengl
								${CMAKE_COMMAND} -E copy ${LIBDIR}/glew/lib/libglew32.lib ${HARVEST_TARGET}/opengl/lib/glew.lib &&
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/glew/include/ ${HARVEST_TARGET}/opengl/include/ && 
#sndfile 
								${CMAKE_COMMAND} -E copy ${LIBDIR}/sndfile/lib/libsndfile.dll.a ${HARVEST_TARGET}/sndfile/lib/libsndfile-1.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/sndfile/bin/libsndfile-1.dll ${HARVEST_TARGET}/sndfile/lib/libsndfile-1.dll &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/sndfile/include/sndfile.h ${HARVEST_TARGET}/sndfile/include/sndfile.h &&
#tiff
								${CMAKE_COMMAND} -E copy ${LIBDIR}/tiff/lib/tiff.lib ${HARVEST_TARGET}/tiff/lib/libtiff.lib &&
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/tiff/include/ ${HARVEST_TARGET}/tiff/include/ &&
#iconv
								${CMAKE_COMMAND} -E copy ${LIBDIR}/iconv/lib/libiconv.a ${HARVEST_TARGET}/iconv/lib/iconv.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/iconv/include/iconv.h ${HARVEST_TARGET}/iconv/include/iconv.h &&
#opencolorIO 
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/opencolorio/ ${HARVEST_TARGET}/opencolorio &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/opencolorio/lib/OpenColorIO.dll ${HARVEST_TARGET}/opencolorio/bin/OpenColorIO.dll &&
#Osl
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/osl/ ${HARVEST_TARGET}/osl &&
#OpenVDB
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/openVDB/ ${HARVEST_TARGET}/openVDB &&
#blosc
								${CMAKE_COMMAND} -E copy ${LIBDIR}/blosc/lib/libblosc.lib ${HARVEST_TARGET}/blosc/lib/libblosc.lib &&
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/blosc/include/ ${HARVEST_TARGET}/blosc/include/  && 
#tbb
								${CMAKE_COMMAND} -E copy ${LIBDIR}/tbb/lib/tbb_static.lib ${HARVEST_TARGET}/tbb/lib/tbb.lib &&
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/tbb/include/ ${HARVEST_TARGET}/tbb/include/  &&
#llvm
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/llvm/ ${HARVEST_TARGET}/llvm/ &&
#opencollada
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/opencollada/ ${HARVEST_TARGET}/opencollada/ &&
#opensubdiv
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/opensubdiv ${HARVEST_TARGET}/opensubdiv

								DEPENDS )
endif (BUILD_MODE STREQUAL Release)

if (BUILD_MODE STREQUAL Debug)
add_custom_target( Harvest_Debug_Results  
#OpenImageIO
                        COMMAND ${CMAKE_COMMAND} -E copy ${LIBDIR}/openimageio/lib/OpenImageIO.lib ${HARVEST_TARGET}/openimageio/lib/OpenImageIO_d.lib &&
							    ${CMAKE_COMMAND} -E copy ${LIBDIR}/openimageio/lib/OpenImageIO_Util.lib ${HARVEST_TARGET}/openimageio/lib/OpenImageIO_Util_d.lib &&
#ilmbase+openexr
								${CMAKE_COMMAND} -E copy ${LIBDIR}/ilmbase/lib/Half.lib ${HARVEST_TARGET}/openexr/lib/Half_d.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/ilmbase/lib/Iex-2_2.lib ${HARVEST_TARGET}/openexr/lib/Iex-2_2_d.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/ilmbase/lib/IexMath-2_2.lib ${HARVEST_TARGET}/openexr/lib/IexMath-2_2_d.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/ilmbase/lib/IlmThread-2_2.lib ${HARVEST_TARGET}/openexr/lib/IlmThread-2_2_d.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/ilmbase/lib/Imath-2_2.lib ${HARVEST_TARGET}/openexr/lib/Imath-2_2_d.lib && 
								${CMAKE_COMMAND} -E copy ${LIBDIR}/openexr/lib/IlmImf-2_2.lib ${HARVEST_TARGET}/openexr/lib/IlmImf-2_2_d.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/openexr/lib/IlmImfUtil-2_2.lib ${HARVEST_TARGET}/openexr/lib/IlmImfUtil-2_2_d.lib.lib  &&
#opencollada
								${CMAKE_COMMAND} -E copy ${LIBDIR}/opencollada/lib/opencollada/buffer.lib  ${HARVEST_TARGET}/opencollada/lib/opencollada/buffer_d.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/opencollada/lib/opencollada/ftoa.lib ${HARVEST_TARGET}/opencollada/lib/opencollada/ftoa_d.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/opencollada/lib/opencollada/GeneratedSaxParser.lib ${HARVEST_TARGET}/opencollada/lib/opencollada/GeneratedSaxParser_d.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/opencollada/lib/opencollada/MathMLSolver.lib ${HARVEST_TARGET}/opencollada/lib/opencollada/MathMLSolver_d.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/opencollada/lib/opencollada/OpenCOLLADABaseUtils.lib ${HARVEST_TARGET}/opencollada/lib/opencollada/OpenCOLLADABaseUtils_d.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/opencollada/lib/opencollada/OpenCOLLADAFramework.lib ${HARVEST_TARGET}/opencollada/lib/opencollada/OpenCOLLADAFramework_d.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/opencollada/lib/opencollada/OpenCOLLADASaxFrameworkLoader.lib ${HARVEST_TARGET}/opencollada/lib/opencollada/OpenCOLLADASaxFrameworkLoader_d.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/opencollada/lib/opencollada/OpenCOLLADAStreamWriter.lib ${HARVEST_TARGET}/opencollada/lib/opencollada/OpenCOLLADAStreamWriter_d.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/opencollada/lib/opencollada/pcre.lib ${HARVEST_TARGET}/opencollada/lib/opencollada/pcre_d.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/opencollada/lib/opencollada/UTF.lib ${HARVEST_TARGET}/opencollada/lib/opencollada/UTF_d.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/opencollada/lib/opencollada/xml.lib ${HARVEST_TARGET}/opencollada/lib/opencollada/xml_d.lib && 
#boost 
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/boost/lib/ ${HARVEST_TARGET}/boost/lib/ &&  
#llvm
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/llvm/lib/ ${HARVEST_TARGET}/llvm/debug/lib/ &&
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/llvm/bin/ ${HARVEST_TARGET}/llvm/debug/bin/ &&
								${CMAKE_COMMAND} -E copy_directory ${LIBDIR}/llvm/include/ ${HARVEST_TARGET}/llvm/debug/include/ &&
#osl
								${CMAKE_COMMAND} -E copy ${LIBDIR}/osl/lib/oslcomp.lib ${HARVEST_TARGET}/osl/lib/oslcomp_d.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/osl/lib/oslexec.lib ${HARVEST_TARGET}/osl/lib/oslexec_d.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/osl/lib/oslquery.lib ${HARVEST_TARGET}/osl/lib/oslquery_d.lib &&
#opensubdiv
								${CMAKE_COMMAND} -E copy ${LIBDIR}/opensubdiv/lib/osdCPU.lib ${HARVEST_TARGET}/opensubdiv/lib/osdCPU_d.lib &&
								${CMAKE_COMMAND} -E copy ${LIBDIR}/opensubdiv/lib/osdGPU.lib ${HARVEST_TARGET}/opensubdiv/lib/osdGPU_d.lib &&
#tbb
								${CMAKE_COMMAND} -E copy ${LIBDIR}/tbb/lib/tbb_static.lib ${HARVEST_TARGET}/tbb/lib/tbb_debug.lib &&
#openvdb
								${CMAKE_COMMAND} -E copy ${LIBDIR}/openvdb/lib/openvdb.lib ${HARVEST_TARGET}/openvdb/lib/openvdb_d.lib 
							
)
endif (BUILD_MODE STREQUAL Debug)