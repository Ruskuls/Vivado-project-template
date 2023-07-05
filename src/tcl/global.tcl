set proj_name "Bootloader"
set part "xc7s25ftgb196-1"
set flash "n25q64-3.3v-spi-x1_x2_x4"

# all paths are relative to env.sh
set proj_dir vivado
set impl $proj_dir/$proj_name.runs/impl_1
set src_dir  src
set lib_dir  $src_dir/library
set tcl_dir  $src_dir/tcl

# hardware definition location
set hwspec $proj_dir/$proj_name.sdk/top.xsa

# Microblaze sdk global variables
set sdk_app_name  main
set sdk_fsbl_name fsbl
set sdk_dir       $src_dir/software
set sdk_app_elf_dir   $sdk_dir/$sdk_app_name/Release
set sdk_fsbl_elf_dir   $sdk_dir/$sdk_fsbl_name/Release
set sdk_proc      microblaze_0
