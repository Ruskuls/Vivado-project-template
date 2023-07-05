set tcl_dir [file dirname [info script]]
source $tcl_dir/global.tcl

# open fpga project
open_project $proj_dir/$proj_name.xpr

puts "INFO: Generate IP's'"

puts "INFO: Run synthesis"
launch_runs synth_1 -jobs 8
wait_on_run synth_1

puts "INFO: Export hardware definition"
write_hw_platform -fixed -force -file $hwspec

set hw_export_log [catch {exec xsct $tcl_dir/hw_export.tcl $sdk_app_name $sdk_dir $hwspec $sdk_proc}]
puts $hw_export_log

puts "INFO: Launch SDK and build bsp"
set bsp_build_log [catch {exec xsct $tcl_dir/build_bsp.tcl}]
puts $bsp_build_log

puts "INFO: Launch SDK and build *.elf"
set sdk_build_log [catch {exec xsct $tcl_dir/build_sdk.tcl build $sdk_app_name}]
set sdk_build_log [catch {exec xsct $tcl_dir/build_sdk.tcl build $sdk_fsbl_name}]
puts $sdk_build_log

puts "INFO: Assign elf files to be included in generated bit file"
add_files -norecurse $sdk_fsbl_elf_dir/$sdk_fsbl_name.elf
update_compile_order -fileset sources_1

set path_to_elf [get_files -all -of_objects [get_fileset sources_1] $sdk_fsbl_name.elf]

set_property SCOPED_TO_REF microblaze_system $path_to_elf
set_property SCOPED_TO_CELLS $sdk_proc $path_to_elf

puts "INFO: Run implementation"
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1
exit
