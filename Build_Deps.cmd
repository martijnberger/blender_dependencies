@echo off
if NOT "%1" == "" (
	if "%1" == "2013" (
    echo "Building for VS2013"
    set VSVER=12.0
    set VSVER_SHORT=12
    set CMAKE_BUILDER=Visual Studio 12 Win64
    set BuildDir=Build2013
    goto par2
  )
	if "%1" == "2015" (
    echo "Building for VS2015"
    set CMAKE_BUILDER=Visual Studio 14 Win64
    set VSVER=14.0
    set VSVER_SHORT=14
    set BuildDir=Build2015
    goto par2
  )
)
Echo Usage build_deps 2013/2015
goto exit

:par2

setlocal ENABLEEXTENSIONS
set BLENDER_DIR=%~dp0
set BUILD_DIR=%BLENDER_DIR%..\build_windows
set BUILD_TYPE=Release
set BUILD_CMAKE_ARGS=

REM Detect MSVC Installation
if DEFINED VisualStudioVersion goto msvc_detect_finally
set VALUE_NAME=ProductDir
REM Check 64 bits
set KEY_NAME="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\%VSVER%\Setup\VC"
for /F "usebackq skip=2 tokens=1-2*" %%A IN (`REG QUERY %KEY_NAME% /v %VALUE_NAME% 2^>nul`) DO set MSVC_VC_DIR=%%C
if DEFINED MSVC_VC_DIR goto msvc_detect_finally
REM Check 32 bits
set KEY_NAME="HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\%VSVER%\Setup\VC"
for /F "usebackq skip=2 tokens=1-2*" %%A IN (`REG QUERY %KEY_NAME% /v %VALUE_NAME% 2^>nul`) DO set MSVC_VC_DIR=%%C
if DEFINED MSVC_VC_DIR goto msvc_detect_finally
:msvc_detect_finally
if DEFINED MSVC_VC_DIR call "%MSVC_VC_DIR%\vcvarsall.bat"


REM Sanity Checks
where /Q msbuild
if %ERRORLEVEL% NEQ 0 (
	echo Error: "MSBuild" command not in the PATH.
	echo You must have MSVC installed and run this from the "Developer Command Prompt"
	echo ^(available from Visual Studio's Start menu entry^), aborting!
	goto EOF
)
where /Q cmake
if %ERRORLEVEL% NEQ 0 (
	echo Error: "CMake" command not in the PATH.
	echo You must have CMake installed and added to your PATH, aborting!
	goto EOF
)


set path=%BLENDER_DIR%\mingw\mingw64\msys\1.0\bin\;%path%
mkdir %BuildDir%_Release
cd %BuildDir%_Release
cmake -G "%CMAKE_BUILDER%" .. -DBUILD_MODE=Release -DHARVEST_TARGET=%BLENDER_DIR%/Win64_vc%VSVER_SHORT%/
msbuild /m "Blender External Dependencies.sln" /p:Configuration=Release /fl /flp:logfile=BlenderDeps.log
rem osl fails to build the first time, don't have the time to figure out why so just build twice
msbuild /m "Blender External Dependencies.sln" /p:Configuration=Release /fl /flp:logfile=BlenderDepsOsl.log
cmake --build . --target Harvest_Release_Results
cd ..
mkdir %BuildDir%_Debug
cd %BuildDir%_Debug
cmake -G "%CMAKE_BUILDER%" .. -DCMAKE_BUILD_TYPE=Debug -DBUILD_MODE=Debug -DHARVEST_TARGET=%BLENDER_DIR%/Win64_vc%VSVER_SHORT%/
msbuild /m "Blender External Dependencies.sln" /p:Configuration=Debug /fl /flp:logfile=BlenderDeps.log
rem osl fails to build the first time, don't have the time to figure out why so just build twice
msbuild /m "Blender External Dependencies.sln" /p:Configuration=Debug /fl /flp:logfile=BlenderDepsOsl.log
cmake --build . --target Harvest_Debug_Results
cd ..

:exit
Echo .
