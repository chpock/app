package require starkit
starkit::startup

catch {
	switch $::tcl_platform(platform) {
		windows		{ encoding system cp1251 }
	}
}

if { [file exists [file join $::starkit::topdir app.tcl]] } {
  source [file join $::starkit::topdir app.tcl]
} {
  set ::starkit::console_active 1
}

if { [package provide Tk] ne "" } {
	namespace eval tkcon {}
	set tkcon::PRIV(showOnStartup) 0
	set tkcon::PRIV(root) .tkcon
	set tkcon::OPT(exec) ""
	set tkcon::OPT(cols) 120; # YMMV, change these to suit your
	set tkcon::OPT(rows) 40;  # screen resolution and taste.
	set tkcon::OPT(buffer) 2048; #The size of the console scroll buffer (in lines).
	set tkcon::OPT(history) 512; #The size of the history list to keep.
	set tkcon::OPT(calcmode) 1
	set tkcon::OPT(font) {{Courier} 9}
	set tkcon::OPT(maxlinelen) 512
	#set tkcon::OPT(showmenu) 0; #Show the menubar on startup (1 or 0, defaults to 1).

	source [file join $::starkit::topdir tkcon.tcl]
	# tkcon ignore prompt1
	after idle { set tkcon::OPT(prompt1) {\[[file nativename [pwd]]\] % } }

	# tkcon paste work only with clipboard
	proc ::tkcon::GetSelection { w } {
    if { ![catch {selection get -displayof $w -selection CLIPBOARD} txt] } {
        return $txt
    }
    return -code error "could not find clipboard text"
	}


	bind . <Control-F12> {
	  if { [info exists ::starkit::console_active] } {
	    unset ::starkit::console_active
	    tkcon hide
	  } {
	    set ::starkit::console_active 1
	    tkcon show
	    bind .tkcon <Control-F12> {
	      unset ::starkit::console_active
	      tkcon hide
	    }
	  }
	}
	if { [info exists ::starkit::console_active] } { tkcon show }
}