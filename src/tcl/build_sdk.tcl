puts "INFO: SDK build started"

set tcl_dir [file dirname [info script]]
source $tcl_dir/global.tcl

if { $argc != 2 } {
    puts "build_sdk.tcl requires 2 arguments:"
    puts "  sdk cmd - build, clean"
    puts "  app name"
    exit
}

set cmd [lindex $argv 0]
set app_name [lindex $argv 1]

puts "INFO: Import application projects"
setws $sdk_dir

importprojects $sdk_dir
platform active top
platform generate


if {[string match $app_name "main"] == 1} {
    puts "INFO: Build application sdk project"
    # Import app project, if it fails, create it
    # check if any aplication project exists
    catch {app list -dict} result
    puts $result

    if {[string match $result "No application exist"] == 1} {
        puts "No application project exists. Attempting to create it"
        source $tcl_dir/create_sdk_app_project.tcl
        exit
    } else {
        puts "Aplication project exists"
        puts "Check if specified application project exists"
        set imported_sdk_projects [app list -dict]
        set sdk_project_exists [dict exists $imported_sdk_projects $app_name]
        puts $sdk_project_exists
        if {$sdk_project_exists} {
            puts "INFO: project exsists"
            app $cmd -name $app_name
        } else {
            puts "INFO: specified project can't be found. Attempting to create it"
            source $tcl_dir/create_sdk_app_project.tcl
        }
        exit
    }
}


if {[string match $app_name "fsbl"] == 1} {
    puts "INFO: Build fsbl sdk project"
    # Import fsbl project, if it fails, create it
    # check if any aplication project exists
    catch {app list -dict} result
    puts $result

    if {[string match $result "No fsbl exist"] == 1} {
        puts "No fsbl project exists. Attempting to create it"
        source $tcl_dir/create_sdk_fsbl_project.tcl
        exit
    } else {
        puts "FSBL project exists"
        puts "Check if specified application project exists"
        set imported_sdk_projects [app list -dict]
        set sdk_project_exists [dict exists $imported_sdk_projects $app_name]
        puts $sdk_project_exists
        if {$sdk_project_exists} {
            puts "INFO: project exsists"
            app $cmd -name $app_name
        } else {
            puts "INFO: specified project can't be found. Attempting to create it"
            source $tcl_dir/create_sdk_fsbl_project.tcl
        }
        exit
    }
}

puts "INFO: SDK build finished"
