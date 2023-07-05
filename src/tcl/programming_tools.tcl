set CMD [lindex $argv 0]
set bit_path [lindex $argv 1]

set tcl_dir [file dirname [info script]]
source $tcl_dir/global.tcl

open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target

# process if received CMD is to programm fpga directly, than exit
if {[string match $CMD "prog"] == 1} {
    puts "INFO: programming FPGA"
    set_property PROBES.FILE {} [get_hw_devices xc7s25_0]
    set_property FULL_PROBES.FILE {} [get_hw_devices xc7s25_0]
    set_property PROGRAM.FILE [list "$bit_path"] [get_hw_devices xc7s25_0]
    program_hw_devices [get_hw_devices xc7s25_0]
    exit
}

# If flash related command is received this code is executed

# Add external flash memory, it depends on used FPGA board
set hw_device [lindex [get_hw_devices xc7s25_0] 0]
set flash_device [lindex [get_cfgmem_parts $flash] 0]
create_hw_cfgmem -hw_device $hw_device $flash_device
set cfgmem [get_property PROGRAM.HW_CFGMEM $hw_device ]

# set up common flash cofiguration settings
set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} $cfgmem
set_property PROGRAM.BLANK_CHECK 0 $cfgmem
set_property PROGRAM.ERASE  1 $cfgmem
set_property PROGRAM.CFG_PROGRAM 1 $cfgmem
set_property PROGRAM.VERIFY 1 $cfgmem
set_property PROGRAM.CHECKSUM  0 $cfgmem

if { [string match $CMD "flash"] == 1} {
    puts "INFO: flash FPGA configuration memory"
    puts "INFO: Step 1. Create download bit that contains fsbl.elf"
    exec updatemem -force -meminfo $impl/top.mmi -bit $impl/top.bit -data $sdk_fsbl_elf_dir/fsbl.elf -proc system_inst/microblaze_system_i/$sdk_proc -out $impl/download.bit
    puts "INFO: Step 2. Write generated bit file into external flash memory"
    set prog_log [exec program_flash -f $impl/download.bit -offset 0x0 -flash_type n25q64-3.3v-spi-x1_x2_x4 -verify -url TCP:127.0.0.1:3121]
    puts $prog_log

    puts "INFO: write application elf to external flash memory"
    puts "INFO: create srec"
    set prog_log [exec mb-objcopy -O srec $sdk_app_elf_dir/main.elf $sdk_dir/flash/main.elf.srec]
    puts $prog_log
    set prog_log [exec bootgen -arch fpga -image $sdk_dir/flash/bootimage.bif -w -o $sdk_dir/flash/BOOT.bin -interface spi]
    puts $prog_log
    set $prog_log [exec program_flash -f $sdk_dir/flash/BOOT.bin -offset 0x00130000 -flash_type n25q64-3.3v-spi-x1_x2_x4 -verify -url TCP:127.0.0.1:3121]
    puts $prog_log

} elseif { [string match $CMD "erase"] == 1} {
    puts "INFO: erasing external flash memory"
    set_property PROGRAM.ADDRESS_RANGE  {entire_device} $cfgmem
} else {
    puts "INFO: valid cmd options:"
    puts "    - flash - to programm compiled bistream into external FPGA flash memory"
    puts "    - prog - to program FPGA"
    puts "    - erase - to erase entire FPGA configuration flash memory"
}

#set started_at [clock seconds]
#puts "Started at [clock format $started_at -format %T]"

#if {![string equal [get_property PROGRAM.HW_CFGMEM_TYPE $hw_device] [get_property MEM_TYPE [get_property CFGMEM_PART $cfgmem]]]} {
#    create_hw_bitstream -hw_device $hw_device [get_property PROGRAM.HW_CFGMEM_BITFILE $hw_device];
#    program_hw_devices $hw_device;
#};
#program_hw_cfgmem -hw_cfgmem $cfgmem

#set ended_at [clock seconds]
#puts "Ended in [clock format [expr $ended_at - $started_at] -gmt 1 -format %T]"

exit
