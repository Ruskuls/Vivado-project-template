
puts "INFO: SDK build started"

set tcl_dir [file dirname [info script]]
source $tcl_dir/global.tcl

setws $sdk_dir

set proc [getprocessors $hwspec]

# create a platform project using xsa file
platform create -name {top} -hw $hwspec -proc $proc -os {standalone} -out $sdk_dir

puts "INFO: Set active hardware platform"
platform list
platform active top
platform generate
