#!/usr/bin/env tclsh

# Tcl/Tk script to create a simple GUI with a button

# Create the main window
set root [tk::toplevel .]
wm title $root "Tcl/Tk Button Example"
wm geometry $root "300x150"

# Create a label
set label [tk::label $root.label -text "Click the button below:" -font {Helvetica 12}]
pack $label -pady 10

# Create a button with a command
set button [tk::button $root.button -text "Click Me!" -command {on_button_click} -bg "lightblue" -fg "black" -padx 20 -pady 10]
pack $button -pady 10

# Create a quit button
set quit_button [tk::button $root.quit -text "Quit" -command {exit} -bg "lightcoral" -padx 20 -pady 10]
pack $quit_button -pady 10

# Define the button click handler
proc on_button_click {} {
    tk_messageBox -type ok -title "Button Clicked" -message "You clicked the button!"
}

# Start the main event loop
tk::mainloop
