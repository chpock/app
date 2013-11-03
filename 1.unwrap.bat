@echo off
if "%2"=="" goto usage
move %1 %2.exe
build\tclkit tools\sdx.kit unwrap %2.exe
build\tclkit tools\sdx.kit mksplit %2.exe
del %2.exe
move /Y %2.head build\
del %2.tail
echo %2
exit 0

:usage
echo Usage: unwrap.bat original_kit_name dest_kit_name
exit 1