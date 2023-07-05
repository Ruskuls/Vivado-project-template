
set tcl_dir [file dirname [info script]]
source $tcl_dir/global.tcl

#if { $argc != 1 } {
#    puts "upload_app.tcl requires 1 arguments:"
#    puts "  path to app elf file"
#    exit
#}

#set impl [lindex $argv 0]

connect -url tcp:127.0.0.1:3121
fpga -file $proj_dir/$proj_name.runs/impl_1/top.bit
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw $hwspec -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow $sdk_elf_dir/main.elf
exit

# TODO: this should be updated when many elf files and bit files should be combined together into one file
puts "INFO: upload application"

set sdk_log [exec program_flash -f $app_elf -offset 0x00130000 -flash_type n25q64-3.3v-spi-x1_x2_x4 -verify -cable type xilinx_tcf url TCP:127.0.0.1:3121]
puts $sdk_log
