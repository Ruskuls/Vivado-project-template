if { $argc != 4 } {
    puts "hw_export.tcl requires 4 arguments:"
    puts "  app name"
    puts "  sdk directory"
    puts "  hardware specification file location (.hdf)"
    puts "  processor name (usually microblaze_I, if only one)"
    exit
}
puts "INFO: HW export started"

set app_name [lindex $argv 0]
set sdk_dir  [lindex $argv 1]
set hwspec   [lindex $argv 2]
set proc     [lindex $argv 3]

puts $sdk_dir
puts $hwspec
puts $proc

setws $sdk_dir

puts "INFO: delete hidden files"
file delete -force $sdk_dir/.metadata
file delete -force $sdk_dir/.analytics
file delete -force $sdk_dir/top
file delete -force $sdk_dir/IDE.log

# create a hardware project using a hardware specification file
puts "INFO: create a hardware project using a hardware specification file"
platform create -name "top" -hw $hwspec -proc $proc -os standalone -out $sdk_dir
platform generate

puts "INFO: HW export finished"
