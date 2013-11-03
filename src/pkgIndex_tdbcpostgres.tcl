# Package index file for tdbc::postgres

if {[catch {package require Tcl 8.6}]} {
    return
}
package ifneeded tdbc::postgres 1.0.0 [list apply {{dir} {
  if { $::tcl_platform(os) eq "Windows NT" &&
        ($::tcl_platform(machine) eq "intel" || $::tcl_platform(machine) eq "amd64") } {
    package require twapi
    set _ [file dirname [lindex [lsearch -inline -index 1 -glob [twapi::get_process_modules [twapi::get_current_process_id] -path] {*/twapi_base*.dll}] 1]]
    if { $_ eq "." } { error "couldn't find temp folder name for tdbc::postgres support library" }
    foreach fn [glob -types f -tails -directory $dir "*.dll"] {
      if { [string match -nocase "tdbcpostgres*" $fn] } continue
      file copy -force [file join $dir $fn] [file join $_ $fn]
    }
  } {
    set _ [pwd]
  }
  source [file join $dir tdbcpostgres.tcl]
  set tpwd [pwd]
  cd $_
  catch { load [file join $dir tdbcpostgres100.dll] tdbcpostgres } r o
  cd $tpwd
  return -options $o $r
}} $dir]
