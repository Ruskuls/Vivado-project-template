#configuration clock setup
#set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
#set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
#set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR No [current_design]
#set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 1 [current_design]

## Clock pinout
set_property IOSTANDARD LVCMOS33 [get_ports clk_in]
set_property PACKAGE_PIN L5 [get_ports clk_in]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_cpu_inst/inst/clk_in1_clk_wiz_1]

## UART pinout
# D2
set_property PACKAGE_PIN M2 [get_ports UART_Rx]
set_property IOSTANDARD LVCMOS33 [get_ports UART_Rx]

# D3
set_property PACKAGE_PIN M4 [get_ports UART_Tx]
set_property IOSTANDARD LVCMOS33 [get_ports UART_Tx]
###################################################################
#Bootloader pinout
set_property PACKAGE_PIN B11 [get_ports config_spi_io0_io]
set_property IOSTANDARD LVCMOS33 [get_ports config_spi_io0_io]

set_property PACKAGE_PIN B12 [get_ports config_spi_io1_io]
set_property IOSTANDARD LVCMOS33 [get_ports config_spi_io1_io]

set_property PACKAGE_PIN C11 [get_ports config_spi_ss_io]
set_property IOSTANDARD LVCMOS33 [get_ports config_spi_ss_io]

#set_property PACKAGE_PIN D14 [get_ports LED1]
#set_property IOSTANDARD LVCMOS33 [get_ports LED1]

#set_property PACKAGE_PIN C14 [get_ports LED2]
#set_property IOSTANDARD LVCMOS33 [get_ports LED2]

## HyperRAM (connected to IS66WVH8M8BLL-100B1LI, 64 Mbit, 100 MHz, 3.0 V, single-ended clock).
## SLEW and DRIVE set to maximum performance to reduce rise and fall times, and therefore
## give better timing margins.
set_property -dict {PACKAGE_PIN P3  IOSTANDARD LVCMOS33  PULLUP FALSE}                      [get_ports {hyperram_resetn_o}]
set_property -dict {PACKAGE_PIN P2  IOSTANDARD LVCMOS33  PULLUP FALSE}                      [get_ports {hyperram_csn_o}]
set_property -dict {PACKAGE_PIN N1  IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hyperram_ck_o}]
set_property -dict {PACKAGE_PIN P4  IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hyperram_rwds_io}]
set_property -dict {PACKAGE_PIN P11 IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hyperram_dq_io[0]}]
set_property -dict {PACKAGE_PIN P12 IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hyperram_dq_io[1]}]
set_property -dict {PACKAGE_PIN N4  IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hyperram_dq_io[2]}]
set_property -dict {PACKAGE_PIN P10 IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hyperram_dq_io[3]}]
set_property -dict {PACKAGE_PIN P5  IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hyperram_dq_io[4]}]
set_property -dict {PACKAGE_PIN N10 IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hyperram_dq_io[5]}]
set_property -dict {PACKAGE_PIN N11 IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hyperram_dq_io[6]}]
set_property -dict {PACKAGE_PIN P13 IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hyperram_dq_io[7]}]
