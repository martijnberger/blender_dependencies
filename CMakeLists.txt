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
# Status code # Description                                                                        #
####################################################################################################
# Work        # Work started, not completed                                                        #
# Done        # Done, Compiles without errors, not tested with blender yet                         #
# Prob        # There's a problem                                                                  #
# ????        # No idea what to do with this                                                       #
# Tested      # Linked against blender and working                                                 #
####################################################################################################
#Dependency            # Status # Notes                                                            #
####################################################################################################
#alembic               # Work   # Build issues with finding libs, needs work                       #
#blosc                 # Done   #                                                                  #
#boost                 # Done   #                                                                  #
#ffmpeg                # Prob   # No nmake or cmake based build in the main distro                 #
#fftw3                 # Prob   # No nmake or cmake based build in the main distro                 #
#freetype              # Done   #                                                                  #
#hdf5                  # Work   # Dependency for alembic, might need /NODEFAULTLIB:library         #
#iconv                 # Prob   # needs mingw to build                                             #
#jack                  # Prob   # Last Supported msvc is 6.0                                       #
#jpeg                  # Done   #                                                                  #
#lapack                # Prob   # Needs the intel compiler or mingw to build                       #
#llvm                  # Work   #                                                                  #
#openal                # Prob   # Download is a creepy .exe file, swap out with openal-soft?       #
#opencollada           # Work   # Compiles, need to check old build procedure for cmake defs and patches #
#OpenColorIO           # Done   # Requires patch.exe to be in the path, also requires latest cmake because the findboost in older cmake's do not recognize 1.6.0                            #
#openexr               # Done   # Split into IlmBase & OpenExr                                     #
#opengl                #        # Contains freeglut & glew                                         #
#OpenImageIO           #        #                                                                  #
#opensubdiv            #        #                                                                  #
#openvdb               #        #                                                                  #
#osl                   #        #                                                                  #
#package               # ????   # Has a bunch of python stuff                                      #
#png                   # Done   #                                                                  #
#pthreads              # Done   #                                                                  #
#python                #        #                                                                  #
#release               # ????   # Installer scripts                                                # 
#sdl                   # Done   #                                                                  #
#sndfile               # Prob   # No nmake or cmake based build in the main distro                 #
#tbb                   #        #                                                                  #
#thumbhandler          #        #                                                                  #
#tiff                  #        #                                                                  #
#wintab                # ????   # Just a bunch of header files, nothing to build                   #
#zlib                  # Done   # library file is named differently compared to what is in svn     #
####################################################################################################

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
                     -DZLIB_LIBRARY=${LIBDIR}/zlib/lib/zlibstatic.lib
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
                          ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/pthread.h ${LIBDIR}/pthreads/inc/pthread.h             && 
                          ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/sched.h ${LIBDIR}/pthreads/inc/sched.h               &&
                          ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/build/pthreads/src/external_pthreads/semaphore.h ${LIBDIR}/pthreads/inc/semaphore.h         
  INSTALL_DIR ${LIBDIR}/pthreads
)

set(ILMBASE_VERSION 2.2.0)
set(ILMBASE_URI http://download.savannah.nongnu.org/releases/openexr/ilmbase-${ILMBASE_VERSION}.tar.gz)
set(ILMBASE_HASH b540db502c5fa42078249f43d18a4652)
set(ILMBASE_EXTRA_ARGS -DBUILD_SHARED_LIBS=OFF )

ExternalProject_Add(external_ilmbase
  URL ${ILMBASE_URI}
  URL_HASH MD5=${ILMBASE_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/ilmbase
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/ilmbase ${DEFAULT_C_FLAGS} ${ILMBASE_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/ilmbase
)

set(OPENEXR_VERSION 2.2.0)
set(OPENEXR_URI http://download.savannah.nongnu.org/releases/openexr/openexr-2.2.0.tar.gz)
set(OPENEXR_HASH b64e931c82aa3790329c21418373db4e)
set(OPENEXR_EXTRA_ARGS 
    -DBUILD_SHARED_LIBS=OFF 
    -DZLIB_LIBRARY=${LIBDIR}/zlib/lib/zlibstatic.lib
    -DZLIB_INCLUDE_DIR=${LIBDIR}/zlib/include/
    -DILMBASE_PACKAGE_PREFIX=${LIBDIR}/ilmbase/
    )

ExternalProject_Add(external_openexr
  URL ${OPENEXR_URI}
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
#  URL_HASH MD5=${FFMPEG_HASH}
#  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/ffmpeg
#  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/ffmpeg ${DEFAULT_C_FLAGS} ${FFMPEG_EXTRA_ARGS}
#  INSTALL_DIR ${LIBDIR}/ffmpeg
#)

set(HDF_VERSION 1.8.16)
set(HDF_URI http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-${HDF_VERSION}.tar.bz2)
set(HDF_HASH 79c1593573ebddf734eee8d43ecfe483 ) 
set(HDF_EXTRA_ARGS  
 -DZLIB_LIBRARY=${LIBDIR}/zlib/lib/zlibstatic.lib
 -DZLIB_INCLUDE_DIR=${LIBDIR}/zlib/include/
)

ExternalProject_Add(external_hdf5
  URL ${HDF_URI}
  URL_HASH MD5=${HDF_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/hdf5
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/hdf5 ${DEFAULT_C_FLAGS} ${HDF_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/hdf5
)



set(ALEMBIC_VERSION 1_05_08)
set(ALEMBIC_URI http://alembic.googlecode.com/archive/${ALEMBIC_VERSION}.tar.gz)
set(ALEMBIC_HASH 87708a0cc5ff9d2c5683be80c4e93ff5) # file is different between every download.... creepy...
set(ALEMBIC_EXTRA_ARGS  
 -DBUILDSTATIC=ON 
 -DLINKSTATIC=ON 
 -DBoost_COMPILER:STRING=-vc120
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
 -DHDF5_ROOT=${LIBDIR}/hdf5
 -DHDF5_INCLUDE_DIR=${LIBDIR}/include
 -DHDF_INCLUDE_DIR=${LIBDIR}/include
 -DUSE_ARNOLD=0 
 -DBUILD_EXAMPLES=0 
 -DALEMBIC_NO_OPENGL=1 
 -DBUILD_SHARED_LIBS=OFF 
 -DGLUT_INCLUDE_DIR="" 
   )

#ExternalProject_Add(external_alembic
#  URL ${ALEMBIC_URI}
#  #URL_HASH MD5=${ALEMBIC_HASH}
#  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/alembic
#  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/alembic ${DEFAULT_C_FLAGS} ${ALEMBIC_EXTRA_ARGS}
#  INSTALL_DIR ${LIBDIR}/alembic
#)

set(ICONV_VERSION 1.14)
set(ICONV_URI http://ftp.gnu.org/pub/gnu/libiconv/libiconv-${ICONV_VERSION}.tar.gz)
set(ICONV_HASH e34509b1623cec449dfeb73d7ce9c6c6 ) 
set(ICONV_EXTRA_ARGS  
 
)

#ExternalProject_Add(external_iconv
#  URL ${ICONV_URI}
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
#  URL_HASH MD5=${LAPACK_HASH}
#  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/lapack
#  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/lapack ${DEFAULT_C_FLAGS} ${LAPACK_EXTRA_ARGS}
#  INSTALL_DIR ${LIBDIR}/lapack
#)

set(SDL_VERSION 2.0.4)
set(SDL_URI https://www.libsdl.org/release/SDL2-${SDL_VERSION}.tar.gz)
set(SDL_HASH 44fc4a023349933e7f5d7a582f7b886e ) 
set(SDL_EXTRA_ARGS  

)

ExternalProject_Add(external_sdl
  URL ${SDL_URI}
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
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/opencollada ${DEFAULT_C_FLAGS} ${OPENCOLLADA_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/opencollada
)

set(OPENCOLORIO_URI https://github.com/imageworks/OpenColorIO/archive/v1.0.8.zip)
set(OPENCOLORIO_HASH b31129f8dcb33fbfadb5a845f283c1eb ) 
set(OPENCOLORIO_EXTRA_ARGS  
 -DBoost_COMPILER:STRING=-vc120
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
  URL_HASH MD5=${OPENCOLORIO_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/opencolorio
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/opencolorio ${DEFAULT_C_FLAGS} ${OPENCOLORIO_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/opencolorio
)

set(LLVM_VERSION 3.4.2)
set(LLVM_URI http://llvm.org/releases/${LLVM_VERSION}/llvm-${LLVM_VERSION}.src.tar.gz)
set(LLVM_HASH xxx)
set(LLVM_EXTRA_ARGS 
   )

ExternalProject_Add(external_llvm
  URL ${LLVM_URI}
#  URL_HASH MD5=${LLVM_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/llvm
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/llvm ${DEFAULT_C_FLAGS} ${LLVM_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/llvm
)

set(CLANG_URI http://llvm.org/releases/${LLVM_VERSION}/cfe-${LLVM_VERSION}.src.tar.gz)
set(CLANG_HASH xxx)
set(CLANG_EXTRA_ARGS 
   )
ExternalProject_Add(external_clang
  URL ${CLANG_URI}
#  URL_HASH MD5=${CLANG_HASH}
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build/llvm
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LIBDIR}/llvm ${DEFAULT_C_FLAGS} ${CLANG_EXTRA_ARGS}
  INSTALL_DIR ${LIBDIR}/llvm
)




