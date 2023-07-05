# Vivado 2022.2 project template

Vivado project template repo. The main goal of this project is to provide working example - how to build Vivado projects in non GUI mode.
[Used hardware](https://shop.trenz-electronic.de/en/Products/Trenz-Electronic/TE0890-Spartan-7/)

Project tested on Linux Ubuntu 20.04 LTS and

# Development tools

- [Install Xilinx development tools]()https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2022-2.html

# Hardware development

Clone or download this repo, run:
- `git submodule init`
- `git submodule update`

Open terminal and run one of these commands:
- `env.sh clean` - cleans all untracked files
- `env.sh create` - create project
- `env.sh build` - create and build project
- `env.sh prog` - program fpga with bitstream
- `env.sh flash`- program fpga bitstream into external flash memory
- `env.sh erase`- erase fpga external flash memory

# Software development

- `env.sh sdk` - build sdk project

# Project description

## soft CPU subsystem

- microblaze soft CPU - cofigured with data and instruction cache
- local memory, necessary to store and un first stage bootloader
- external memory (for now it's BRAM, but later could be replaced with HyperRam)
- GPIO - in/out
- UART
- [HyperRam IP core](https://github.com/MJoergen/HyperRAM) - it's connected to the soft CPU as a peripheral

## SDK

Repo contains two sdk projects:
- `fsbl` first stage bootloader, that loads application project into external (different) memory
- `app (main)` project that contains application project, it prints `Hello World!` and runs simple `HyperRam` memory tests

## VHDL

For now only acts as a glue logic. But can be extended with custom user files.

## TCL

Lots of scripts to be able to compile Vivado project in non GUI mode :)

# Customization

## Processor subsystem (block diagram)
- Based on Your needs modify block diagram
- run validation
- open `tcl` terminal
- run `write_bd_tcl -f path_to_this_project/src/tcl/microblaze_system.tcl`
- modify `system.vhd` to match upated `block diagram`

## VHDL



