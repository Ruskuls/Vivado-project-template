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

# Each file is added because I don't know how to exclude files from build via xsct terminal
importsources -name $app_name -path $sdk_dir/app/drivers -target-path src/drivers
importsources -name $app_name -path $sdk_dir/app/tinyprintf/tinyprintf.c -target-path src/tinyprintf
importsources -name $app_name -path $sdk_dir/app/tinyprintf/tinyprintf.h -target-path src/tinyprintf

importsources -name $app_name -path $sdk_dir/app/main.c -target-path src
importsources -name $app_name -path $sdk_dir/app/platform.h -target-path src
importsources -name $app_name -path $sdk_dir/app/platform.c -target-path src
importsources -name $app_name -path $sdk_dir/app/platform_config.h -target-path src


app config -name $app_name -add include-path \"\${workspace_loc:/$\{ProjName}/src/drivers}"
app config -name $app_name -add include-path \"\${workspace_loc:/$\{ProjName}/src/tinyprintf}"

# build selected sdk project
app $cmd -name $app_name

puts "INFO: SDK build finished"
