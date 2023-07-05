set tcl_dir [file dirname [info script]]
source $tcl_dir/global.tcl

puts $app_name

setws $sdk_dir

importprojects $sdk_dir
platform active top

app create -platform top -name $app_name -lang C -template "Empty Application(C)"

# Configure sdk project
app config -name $app_name -set build-config release
app config -name $app_name -set compiler-optimization "None (-O0)"
app config -name $app_name -set compiler-misc {-c -fmessage-length=0 -MT"$@" $(ADDITIONAL_FLAGS)}


importsources -name $app_name -path $sdk_dir/fsbl/lscript.ld -target-path src
#importsources -name $app_name -path $sdk_dir/fsbl/elf32.h -target-path src
#importsources -name $app_name -path $sdk_dir/fsbl/elf-bootloader.c -target-path src
#importsources -name $app_name -path $sdk_dir/fsbl/platform.h -target-path src
#importsources -name $app_name -path $sdk_dir/fsbl/platform.c -target-path src
#importsources -name $app_name -path $sdk_dir/app/platform_config.h -target-path src
#importsources -name $app_name -path $sdk_dir/app/makefile.defs -target-path /


# build selected sdk project
app $cmd -name $app_name

puts "INFO: SDK build finished"
