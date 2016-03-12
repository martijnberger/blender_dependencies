project("Blender External Dependencies")
cmake_minimum_required(VERSION 3.5)

include(ExternalProject)

####################################################################################################
#
# USAGE:
#   for now this is intended to be used with cmake and msbuild
#   cmake -G "Visual Studio 12 Win64" / 
#   cmake -G "Visual Studio 14 Win64" 
#   msbuild ALL_BUILD.vcxproj /p:Configuration=Release
#
# Requires patch.exe in the path (mingw's patch will do)
#
#   the builds should also inherit any platformtoolset you might give them
####################################################################################################
# Status code # Description                                                                        #
####################################################################################################
# Work        # Work started, not completed                                                        #
# Done        # Done, Compiles without errors, not tested with blender yet                         #
# Prob        # There's a problem                                                                  #
# ????        # No idea what to do with this                                                       #
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
#blosc                 # Work   # Work   # Keeps building with /MD even when you tell it you want /MT       #
#boost                 # Done   # Done   #	                                                                #
#ffmpeg                # Prob   #        # No nmake or cmake based build in the main distro                 #
#fftw3                 # Prob   #        # No nmake or cmake based build in the main distro                 #
#freetype              # Done   # Done   #                                                                  #
#iconv                 # Prob   #        # needs mingw to build                                             #
#jack                  # Prob   #        # Last Supported msvc is 6.0                                       #
#jpeg                  # Done   # Done   #                                                                  #
#lapack                # Prob   #        # Needs the intel compiler or mingw to build                       #
#llvm                  # Work   # Work   # Compiles, llvm patch patch not applied yet.                      #
#openal                # Done   # Done   # Uses openal-soft, unsure what the old libs were                  #
#opencollada           # Done   # Done   #                                                                  #
#OpenColorIO           # Done   # Done   # requires latest cmake because the findboost in older cmake's do not recognize 1.6.0                            #
#openexr               # Done   # Done   # Split into IlmBase & OpenExr                                     #
#opengl                # ????   #        # Contains freeglut & glew                                         #
#glew                  # Done   # Done   # dep of the opengl folder, and opensubdiv                         #
#OpenImageIO           # Done   # Done   #                                                                  #
#opensubdiv            # Work   # Work   # Done, but missing the opencl and cuda bits                       #
#openvdb               # Done   # Done   #                                                                  #
#osl                   # Done   # Done   #                                                                  #
#package               # ????   #        # Has a bunch of python stuff                                      #
#png                   # Done   # Done   #                                                                  #
#pthreads              # Done   # Done   #                                                                  #
#python                # ????   #        # Skip? Unsure why                                                 #
#release               # ????   #        # Installer scripts                                                # 
#sdl                   # Done   # Done   #                                                                  #
#sndfile               # Prob   #        # No nmake or cmake based build in the main distro                 #
#tbb                   # Done   # Done   #                                                                  #
#thumbhandler          # ????   # ????   # Not sure what this is                                            #
#tiff                  # Done   # Done   #                                                                  #
#wintab                # ????   #        # Just a bunch of header files, nothing to build                   #
#zlib                  # Done   # Done   # library file is named differently compared to what is in svn     #
#############################################################################################################

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
    message(STATUS "Build type not specified: defaulting to a release build.")
endif()

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(LIBDIR ${CMAKE_CURRENT_BINARY_DIR}/Debug)
ELSE(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(LIBDIR ${CMAKE_CURRENT_BINARY_DIR}/Release)
ENDIF(CMAKE_BUILD_TYPE STREQUAL "Debug")

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
 
ExternalProject_Add(external_zlib
  URL ${ZLIB_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/zlib
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/zlib ${DEFAULT_C_FLAGS}
  INSTALL_DIR ${LIBDIR}/zlib
)

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
string(TOLOWER ${CMAKE_BUILD_TYPE} BOOST_BUILD_TYPE)

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
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/blosc ${BLOSC_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/blosc
)
add_dependencies(external_blosc external_zlib)

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
  BUILD_COMMAND ${PTHREADS_BUILD}
  INSTALL_COMMAND COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/pthreadVC2.dll ${LIBDIR}/pthreads/lib/pthreadVC2.dll && 
                          ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/pthreadVC2.lib ${LIBDIR}/pthreads/lib/pthreadVC2.lib &&        
                          ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/pthread.h ${LIBDIR}/pthreads/inc/pthread.h             && 
                          ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/sched.h ${LIBDIR}/pthreads/inc/sched.h               &&
                          ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/semaphore.h ${LIBDIR}/pthreads/inc/semaphore.h         
  INSTALL_DIR ${LIBDIR}/pthreads
)

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

set(FFTW_VERSION 3.3.4)
set(FFTW_URI http://www.fftw.org/fftw-${FFTW_VERSION}.tar.gz)
set(FFTW_HASH 2edab8c06b24feeb3b82bbb3ebf3e7b3)
set(FFTW_EXTRA_ARGS  )

#ExternalProject_Add(external_fftw3
#  URL ${FFTW_URI}
#  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
#  URL_HASH MD5=${FFTW_HASH}
#  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/fftw3
#  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/fftw3 ${DEFAULT_C_FLAGS} ${FFTW_EXTRA_ARGS}
#  INSTALL_DIR ${LIBDIR}/fftw3
#)

set(FFMPEG_VERSION 3.0)
set(FFMPEG_URI http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2)
set(FFMPEG_HASH 026859cc76dddffd809cad879db07658)
set(FFMPEG_EXTRA_ARGS  )

#ExternalProject_Add(external_ffmpeg
#  URL ${FFMPEG_URI}
#  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
#  URL_HASH MD5=${FFMPEG_HASH}
#  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/ffmpeg
#  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/ffmpeg ${DEFAULT_C_FLAGS} ${FFMPEG_EXTRA_ARGS}
#  INSTALL_DIR ${LIBDIR}/ffmpeg
#)

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

set(OPENSUBDIV_GIT_URI https://github.com/PixarAnimationStudios/OpenSubdiv.git )
set(OPENSUBDIV_GIT_UID cf7135eb2a77d7907192fb3be4da7caa1e708f96 ) 
set(OPENSUBDIV_EXTRA_ARGS  
    -DNO_EXAMPLES=ON 
    -DNO_REGRESSION=ON 
    -DNO_PYTHON=ON 
    -DNO_MAYA=ON 
    -DNO_PTEX=ON 
    -DNO_DOC=ON 
    -DNO_CUDA=ON 
    -DNO_OPENCL=ON 
    -DNO_TUTORIALS=ON 
	-DGLEW_INCLUDE_DIR=${LIBDIR}/glew/include
	-DGLEW_LIBRARY=${LIBDIR}/glew/lib/libglew.lib
	-DCMAKE_EXE_LINKER_FLAGS_RELEASE=libcmt.lib 
)

ExternalProject_Add(external_opensubdiv
  GIT_REPOSITORY ${OPENSUBDIV_GIT_URI}
  GIT_TAG ${OPENSUBDIV_GIT_UID}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/opensubdiv
  PATCH_COMMAND patch --verbose -p 1 -d ${CMAKE_CURRENT_BINARY_DIR}/build/opensubdiv/src/external_opensubdiv < ${CMAKE_CURRENT_SOURCE_DIR}/diffs/opensubdiv.diff 
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/opensubdiv -Wno-dev ${DEFAULT_C_FLAGS} ${DEFAULT_CXX_FLAGS} ${OPENSUBDIV_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/opensubdiv
)


set(ICONV_VERSION 1.14)
set(ICONV_URI http://ftp.gnu.org/pub/gnu/libiconv/libiconv-${ICONV_VERSION}.tar.gz)
set(ICONV_HASH e34509b1623cec449dfeb73d7ce9c6c6 ) 
set(ICONV_EXTRA_ARGS  
 
)

#ExternalProject_Add(external_iconv
#  URL ${ICONV_URI}
#  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
#  URL_HASH MD5=${ICONV_HASH}
#  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/iconv
#  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/iconv ${DEFAULT_C_FLAGS} ${ICONV_EXTRA_ARGS}
#  INSTALL_DIR ${LIBDIR}/iconv
#)



set(JACK_URI https://dl.dropboxusercontent.com/u/28869550/jack-1.9.10.tar.bz2)
set(JACK_HASH 4aeb91d7ae0cabce98355436ed4f217a ) 
set(JACK_EXTRA_ARGS  
 
)

#ExternalProject_Add(external_jack
#  URL ${JACK_URI}
#  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
#  URL_HASH MD5=${JACK_HASH}
#  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/jack
#  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/jack ${DEFAULT_C_FLAGS} ${ICONV_EXTRA_ARGS}
#  INSTALL_DIR ${LIBDIR}/jack
#)

set(LAPACK_VERSION 3.6.0)
set(LAPACK_URI http://www.netlib.org/lapack/lapack-${LAPACK_VERSION}.tgz)
set(LAPACK_HASH f2f6c67134e851fe189bb3ca1fbb5101 ) 
set(LAPACK_EXTRA_ARGS  
 
)

#ExternalProject_Add(external_lapack
#  URL ${LAPACK_URI}
#  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
#  URL_HASH MD5=${LAPACK_HASH}
#  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/lapack
#  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/lapack ${DEFAULT_C_FLAGS} ${LAPACK_EXTRA_ARGS}
#  INSTALL_DIR ${LIBDIR}/lapack
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
  PATCH_COMMAND patch --verbose -p 1 -d ${CMAKE_CURRENT_BINARY_DIR}/build/opencollada/src/external_opencollada < ${CMAKE_CURRENT_SOURCE_DIR}/diffs/opencollada.diff 
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
   )
ExternalProject_Add(external_clang
  URL ${CLANG_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${CLANG_HASH}
  PATCH_COMMAND patch -p 2 -R -d ${CMAKE_CURRENT_BINARY_DIR}/build/clang/src/external_clang < ${CMAKE_CURRENT_SOURCE_DIR}/diffs/clang.diff 
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
set(OSL_CMAKE_CXX_STANDARD_LIBRARIES "kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib psapi.lib ${LIBDIR}/openimageio/lib/OpenImageIO_Util.lib ${LIBDIR}/png/lib/libpng16.lib ${LIBDIR}/jpg/lib/jpeg.lib ${LIBDIR}/tiff/lib/tiff.lib ${LIBDIR}/openexr/lib/IlmImf-2_2.lib")
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
	-OSL_BUILD_TESTS=OFF 
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
  PATCH_COMMAND patch -p 3 -d ${CMAKE_CURRENT_BINARY_DIR}/build/osl/src/external_osl < ${CMAKE_CURRENT_SOURCE_DIR}/diffs/osl_171.diff 
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/osl ${DEFAULT_C_FLAGS} ${OSL_EXTRA_ARGS} 
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

set(SNDFILE_VERSION 1.0.26)
set(SNDFILE_URI http://www.mega-nerd.com/libsndfile/files/libsndfile-${SNDFILE_VERSION}.tar.gz)
set(SNDFILE_HASH ec810a0c60c08772a8a5552704b63393)
set(SNDFILE_EXTRA_ARGS 
   )

#ExternalProject_Add(external_sndfile
#  URL ${SNDFILE_URI}
#  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
#  URL_HASH MD5=${SNDFILE_HASH}
#  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/sndfile
#  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/sndfile ${DEFAULT_C_FLAGS} ${DEFAULT_CXX_FLAGS} ${SNDFILE_EXTRA_ARGS}
#  INSTALL_DIR ${LIBDIR}/sndfile
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

#cmake script for openvdb based on https://raw.githubusercontent.com/diekev/openvdb-cmake/master/CMakeLists.txt
#can't be in external_openvdb because of how the includes are setup. 
ExternalProject_Add(openvdb
  URL ${OPENVDB_URI}
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Downloads
  URL_HASH MD5=${OPENVDB_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/openvdb
  PATCH_COMMAND COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/diffs/cmakelists_openvdb.txt  ${CMAKE_CURRENT_BINARY_DIR}/build/openvdb/src/openvdb/cmakelists.txt &&
						${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/diffs/cmake/  ${CMAKE_CURRENT_BINARY_DIR}/build/openvdb/src/openvdb/cmake/
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/openvdb ${DEFAULT_C_FLAGS} ${DEFAULT_CXX_FLAGS} ${OPENVDB_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/openvdb
)


