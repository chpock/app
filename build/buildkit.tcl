package require starkit
starkit::startup
package require vfs::zip

set tools_dir $::starkit::topdir
set cache_dir [file join $tools_dir .cache]
set src_dir [file join [file dirname $tools_dir] src]
set lib_dir [file join $src_dir lib]
set svn_exe [file join $tools_dir svn svn.exe]
set tcl_ver "8.6.1"
set kit_platform "win32"
set executable_ext ".exe"

source [file join $tools_dir tls-win.kit]
package require tls
package require http
tls::init -tls1 1
http::register https 443 ::tls::socket

proc err { msg } {
  puts stderr $msg
  exit 1
}

if { ![file exists $cache_dir] } {
  file mkdir $cache_dir
}

puts -nonewline "Reading packages.list ... "; flush stdout
set pkgs [dict create Tk [dict create repository internal require "" directory "" archive ""]]
foreach pkgfn [glob -nocomplain -directory $tools_dir *.pkglist] {
	set fd [open $pkgfn r]
	set cur_pkg ""
	set linenum 0
	while { [gets $fd line] >= 0 } {
	  incr linenum
	  if { [set line [string trim $line]] eq "" || [string index $line 0] eq "#" } continue
	  set line [split $line :]
	  set key [string trim [lindex $line 0]]
	  set val [string trim [join [lrange $line 1 end] :]]
	  if { [string equal -nocase "package" $key] } {
	    if { $cur_pkg ne "" } {
	      if { [dict get $pkgs $cur_pkg repository] eq "" && [dict get $pkgs $cur_pkg archive] eq ""} {
	        err "Error in [file tail ${pkgfn}] file, package '${cur_pkg}' don't have repository"
	      }
	    }
	    set cur_pkg $val
	    dict set pkgs $cur_pkg [dict create \
	      repository "" \
	      require [list] \
	      directory $cur_pkg \
	      archive ""]
	    continue
	  }
	  if { $cur_pkg eq "" } {
			close $fd
			err "Error at line ${linenum}, package name not defined."
	  }
	  switch -nocase -exact -- $key {
	    repository - directory - archive {
	      dict set pkgs $cur_pkg [string tolower $key] $val
	    }
	    require {
	      dict set pkgs $cur_pkg require [lappend [dict get $pkgs $cur_pkg require] $val]
	    }
	    default {
	      close $fd
	      err "Error at line ${linenum}, package key '${key}' not known."
	    }
	  }
	}
	close $fd
}
puts "ok."

array set ext_temp [list]

proc add_require { pkg } {
  if { [info exists ::ext_temp($pkg)] } return
  if { ![dict exists $::pkgs $pkg] } {
    err "package <${pkg}> not defined."
  }
  set ::ext_temp($pkg) [dict get $::pkgs $pkg repository]
  foreach req_name [dict get $::pkgs $pkg require] {
    add_require $req_name
  }
}

puts -nonewline "Reading external.pkglist ... "; flush stdout 
set fd [open [file join $src_dir external.pkglist] r]
set linenum 0
while { [gets $fd line] >= 0 } {
  incr linenum
  if { [set line [string trim $line]] eq "" || [string index $line 0] eq "#" } continue
  if { [catch [list add_require $line] m] } {
    close $fd
    err "Error at line ${linenum}: $m"
  }
}
close $fd
puts "ok."

if { [info exists ext_temp(Tk)] } {
  set useTk 1
  unset ext_temp(Tk)
} {
  set useTk 0
}

array set archive_pkg [list]

foreach { pkg } [array names ext_temp] {
  if { [dict get $pkgs $pkg archive] ne "" } {
    set fn [lindex [split [dict get $pkgs $pkg archive] /] end]
    if { ![file exists [file join $cache_dir $fn]] } {
      puts -nonewline "Fetch module '${pkg}' ... "; flush stdout
      set fd [open [file join $cache_dir $fn] w]
			fconfigure $fd -encoding binary -eofchar {} -translation binary
			try {
			  set token [http::geturl [dict get $pkgs $pkg archive] -binary 1 -channel $fd]
			  if { [http::status $token] ne "ok" } {
			    set m [http::error $token]
			    http::cleanup $token
			    error "Http error: $m"
			  }
			  http::cleanup $token
			} on error { r o } {
			  close $fd
			  file delete [file join $cache_dir $fn]
			  err "Error:\n$r"
			}
      close $fd
      puts "ok."
    }
    set archive_pkg($pkg) [file join $cache_dir $fn]
    unset ext_temp($pkg)
  }  
}

puts -nonewline "Checking svn:externals ... "; flush stdout
array set ext_save [array get ext_temp]
if { [catch {exec $svn_exe propget svn:externals [file nativename $lib_dir]} m] } {
  if { ![array size ext_temp] } {
    puts "ignore error."
    set m [list]
  } {
  	err "Error, svn propget failed:\n$m"
  }
} {
  puts "ok."
}

set odd_pkgs [list]

foreach line [split $m \n] {
  if { [set line [string trim $line]] eq "" } continue
  set line [split $line { }]
  set repo [join [lrange $line 0 end-1] { }]
  set dir [lindex $line end]
  set foundpkg 0
  foreach pkg [array names ext_temp] {
    if { $dir eq [dict get $pkgs $pkg directory] } {
      if { $repo eq $ext_temp($pkg) } {
        unset ext_temp($pkg)
      }
      set foundpkg 1
      break
    }
  }
  if { !$foundpkg } {
    lappend odd_pkgs $dir
  }
}

if { ![array size ext_temp] && ![llength $odd_pkgs] } {
  puts "External libs up to date."
} {
  puts -nonewline "Updating external libs props ... "; flush stdout
  if { [array size ext_save] } {
	  set tmpfile [file join $lib_dir externals.tmp]
	  set fd [open $tmpfile w]
	  fconfigure $fd -translation lf
	  foreach {pkg repo} [array get ext_save] {
	    puts $fd "$repo [dict get $pkgs $pkg directory]"
	  }
	  puts $fd ""
	  close $fd
	  if { [catch {exec $svn_exe propset svn:externals [file nativename $lib_dir] -F [file nativename $tmpfile]} m] } {
	    file delete -- $tmpfile
	    err "Error, svn propset failed:\n$m"
	  }
	  file delete -- $tmpfile
	} {
	  if { [catch {exec $svn_exe propdel svn:externals [file nativename $lib_dir]} m] } {
	    file delete -- $tmpfile
	    err "Error, svn propdel failed:\n$m"
	  }
	}
  puts "ok."

  puts -nonewline "Update external lib directory ... "; flush stdout
  if { [catch {exec $svn_exe up [file nativename $lib_dir]} m] } {
    err "Error, svn update failed:\n$m"
  }
  puts "ok."

  puts -nonewline "Commit external libs pops change  ... "; flush stdout
  if { [catch {exec $svn_exe ci [file nativename $lib_dir] -m "Update external libs"} m] } {
    err "Error, svn commit failed:\n$m"
  }
  puts "ok."

}

set head [list "tclkit" $tcl_ver $kit_platform]
if { !$useTk } { lappend head "notk" }
set head [file join $tools_dir [join $head -]]
set dest [file join [file dirname $tools_dir] [file tail [file dirname $tools_dir]]$executable_ext]
puts -nonewline "Init starpack \([file tail $dest]\)... "; flush stdout
if { [catch {file copy -force -- ${head}.head $dest} m] } {
  err "Error:\n$m"
}
# TODO: copy only vfs from kit-file (no header)
try {
	set fdi [open [file join $tools_dir [join $head -].kit] r]
	fconfigure $fdi -encoding binary -eofchar {} -translation binary
	set fdo [open $dest a+]
	fconfigure $fdo -encoding binary -eofchar {} -translation binary
	set data [read $fdi]
	puts -nonewline $fdo $data
	close $fdo
	close $fdi
	unset data
} on error { r o } {
  catch { close $fdo }
  catch { close $fdi }
  err "Error:\n$r"
}
puts "ok."

proc rcopy { basedir path dest } {
  set copy_dirs 0
  set copy_files 0
  foreach dir [glob -directory [file join $basedir $path] -nocomplain -types d -tails -- *] {
    lassign [rcopy $basedir [file join $path $dir] $dest] tmp_dirs tmp_files
    incr copy_dirs
    incr copy_dirs $tmp_dirs
    incr copy_files $tmp_files
  }
  foreach fn [glob -directory [file join $basedir $path] -nocomplain -types f -tails -- *] {
    incr copy_files
    if { ![file isdirectory [file join $dest $path]] } {
      file mkdir [file join $dest $path]
    }
    file copy -force [file join $basedir $path $fn] [file join $dest $path $fn]
  }
  return [list $copy_dirs $copy_files]
}

vfs::mk4::Mount $dest $dest

if { [array size archive_pkg] } {
  puts -nonewline "Copy lib files to starpack ... "; flush stdout
  set d 0
  set f 0
  set l 0
  foreach { pkg fn } [array get archive_pkg] {
  	try {
	    vfs::zip::Mount $fn $fn
	    lassign [rcopy $fn {} [file join $dest lib [dict get $pkgs $pkg directory]]] dd df
	    incr d $dd
	    incr f $df
	    incr l
	  } on error { r o } {
	    catch { vfs::unmount $fn }
	    vfs::unmount $dest
	    err "Error:\n$r"
	  }
	  vfs::unmount $fn
  }
  puts "ok, added $l lib\(s\): $f file\(s\), $d dir\(s\)."
}

puts -nonewline "Copy files to starpack ... "; flush stdout
try {
	lassign [rcopy $src_dir {} $dest] d f
	puts "ok: added $f file\(s\), $d dir\(s\)."
} on error { r o } {
  catch { vfs::unmount $dest }
  err "Error:\n$r"
}
vfs::unmount $dest

if { [set startcmd [lindex $argv 0]] eq "-runwait" || $startcmd eq "-run" } {
  puts -nonewline "Runing starpack ... "; flush stdout
  if { $startcmd eq "-runwait" && !$useTk } {
    set cmdline {exec {*}[auto_execok start] "" cmd /K $dest &}
  } {
    set cmdline {exec {*}[auto_execok start] "" [file nativename $dest] &}
  }
  if { [catch $cmdline m] } {
    err "Error:\n$m"
  }
  puts "ok."
}

exit 0
