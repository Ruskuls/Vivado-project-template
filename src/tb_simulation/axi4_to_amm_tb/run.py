import os
import os
from pathlib import Path
from vunit import VUnit
from subprocess import call
from contextlib import suppress

VU = VUnit.from_argv(compile_builtins=False)
VU.add_vhdl_builtins()
VU.add_verilog_builtins()
VU.add_osvvm()
VU.add_verification_components()

print(VU.get_simulator_name())

# Get working directory
DIR_PATH = Path(__file__).parent

# Get source directory
SRC_PATH = DIR_PATH / "../../hdl"

# Get HyperRam source directory
HYPERRAM_PATH = (DIR_PATH / "../../hdl/HyperRam/src/hyperram").resolve()

# Get testbench directory
TB_PATH = DIR_PATH

# Get Hyperram testbench files
HYPERRAM_TB_PATH = (DIR_PATH / "../../hdl/HyperRam/simulation-vunit/test").resolve()

# Get hyperram device simulation model
HYPERRAM_SIMULATION_MODEL_PATH = (DIR_PATH / "../../hdl/HyperRam/HyperRAM_Simulation_Model").resolve()

# Path(SRC_PATH) converts from string class to pathlib
lib = VU.add_library("src_lib")
lib.add_source_files(SRC_PATH / "axi4_to_avm.vhd")
lib.add_source_files(HYPERRAM_PATH / "*.vhd")

tb_lib = VU.add_library("tb_lib")
tb_lib.add_source_files(TB_PATH / "*.vhd")
tb_lib.add_source_files(HYPERRAM_TB_PATH / "*.vhd")
tb_lib.add_source_files(HYPERRAM_SIMULATION_MODEL_PATH / "s27kl0642.v")

VU.main()
