set tcl_dir [file dirname [info script]]
source $tcl_dir/global.tcl

puts "INFO: Create project"
create_project -force $proj_name $proj_dir

# set project properties
set proj [current_project]
set_property "default_lib" "xil_defaultlib" $proj
set_property "part" $part $proj
set_property "simulator_language" "Mixed" $proj
set_property "target_language" "VHDL" $proj

# add HDL sources
add_files -fileset sources_1 -quiet [glob -nocomplain $src_dir/hdl/*.vhd]
add_files -fileset sources_1 -quiet [glob -nocomplain $src_dir/hdl/HyperRam/src/hyperram/*.vhd]

# set HDL 2008
set_property file_type {VHDL 2008} [get_files *.vhd]

# add IP
add_files -fileset sources_1 -quiet [glob -nocomplain $src_dir/ip/*/*.xci]

update_ip_catalog

# Generate block diagram from tcl files.
# If block diagram was changed locally, tcl file must be updated
set origin_dir_loc $proj_dir/block_designs
file delete -force $origin_dir_loc
source $tcl_dir/microblaze_system.tcl

update_compile_order -fileset sources_1
open_bd_design {$proj_dir/block_designs/microblaze_system/microblaze_system.bd}

# add constraints
add_files -fileset constrs_1 $src_dir/constraints

set_property top top [get_filesets sources_1]

puts "INFO: Project $proj_name created"
exit
