@echo off
if "%1"=="" goto usage
build\tclkit tools\sdx.kit wrap %1.kit
del %1.bat
move /Y %1.kit build\
rmdir /S /Q %1.vfs
exit 0

:usage
echo Usage: wrap.bat kit_name
exit 1