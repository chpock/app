tcllib
====

Based on release 1.18
Homepage: http://core.tcl.tk/tcllib/home

Модуль struct::tree поломан, там нужно указывать -key для каждого вызова структуры, что ломает все апи к структурам.
Был выгрезен и сделан отдельный модуль struct::tree_tcl, для него сделан pkgIndex.tcl и в tree_tcl.tcl в конец
добавлена строка "package provide struct::tree_tcl 1.2.2"