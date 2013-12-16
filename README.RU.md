app
===

Как построить это все дело:

1. Идем http://www.rkeene.org/devel/kitcreator/kitbuild/nightly/ и скачиваем билд для windows32
   tk и notk версию.
2. Запускаем "1.unwrap.bat tclkit-8.6.1-win32-i586-notk-xcompile tclkit-8.6.1-win32-notk"
3. Запускаем "1.unwrap.bat tclkit-8.6.1-win32-i586-xcompile tclkit-8.6.1-win32"
4. Переносим из *.vfs каталогов библиотеки itcl, tdbc*, thread в modules/core/ 
   (в tk версии удалить так же *.sh и .o)
5. Добавляем из "src" в корень *.vfs файлы main.tcl и tkcon.tcl
6, Заменить в *.vfs/lib/tcl8.6/msgs файл uk.msg на файл из "src"
7. Запускаем "2.wrap.bat tclkit-8.6.1-win32-notk"
8. Запускаем "2.wrap.bat tclkit-8.6.1-win32"

9. В модулях удаляем всякие *.sh и *.o файлы
10. Переименовываем каталоги модулей, удаляем версию
11. Добавляем из "src" файлы pkgIndex* для tdbc::mysql и tdbc::postgres
12. Добавляем из "tools\*.zip" архивов дополнительные dll для tdbc::mysql и tdbc::postgres

13. Все ОК 