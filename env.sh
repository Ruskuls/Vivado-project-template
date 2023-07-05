#!/bin/bash
set -eo pipefail

CMD=$1
ARGS=${@:2}

echo "CMD: $CMD"
echo "ARGS: $ARGS"

# TODO: maybe these declarations are not necessary!? At least part of them!
proj_dir="vivado"
proj_name="template"
sdk_dir="src/software"
hwspec="$proj_dir/$proj_name.sdk/top.xsa"
impl="$proj_dir/$proj_name.runs/impl_1"
sdk_elf="$sdk_dir/main/Release/main.elf"
sdk_name="main"

if [ $CMD = "clean" ]; then
    git clean -f -dx

elif [[ $CMD =~ ^(create|build)$  ]]; then
    echo "Create Project"
    vivado -mode tcl -source src/tcl/create_project.tcl
    [ $CMD = create ] && exit

    echo "Build project"
    vivado -mode tcl -source src/tcl/build_project.tcl
    [ $CMD = build ] && exit

elif [ $CMD = "sdk" ]; then
    if [[ $ARGS =~ ^(build|clean)$ ]]; then
        xsct src/tcl/build_sdk.tcl $ARGS $sdk_name
    elif [[ $ARGS = "run" ]]; then
        xsct src/tcl/upload_app.tcl
    else
        echo Unexpected arguments: \"$ARGS\"
        echo Valid arguments for sdk command is:
        echo   - build
        echo   - clean
        exit 1
    fi
elif [[ $CMD =~ ^(prog|flash|erase)$ ]]; then
    vivado -mode tcl -source src/tcl/programming_tools.tcl -tclargs $CMD $impl/download.bit

elif [ $CMD = "upload_app" ]; then
    xsct src/tcl/upload_app.tcl $impl $bootloader $mcs_proc $sdk_elf
else
    echo Unexpected command: \"$CMD\"
    echo Valid CMDs:
    echo   - clean  - removes all untracked files
    echo   - create - creates project
    echo   - build  - build entire project
    echo   - sdk    - build / clean sdk project
    echo   - prog   - program FPGA with compiled *.bit file; non persistent
    echo   - flash  - program FPGA Flash with compiled *.bin file; persistent
    echo   - erase  - erase entire FPGA Flash device
    exit 1
fi
