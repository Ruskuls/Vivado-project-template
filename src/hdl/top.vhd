library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity top is
    port (
        clk_in               : in    std_logic;

        -- HyperRAM device interface
        hyperram_resetn_o  : out   std_logic;
        hyperram_csn_o     : out   std_logic;
        hyperram_ck_o      : out   std_logic;
        hyperram_rwds_io   : inout std_logic;
        hyperram_dq_io     : inout std_logic_vector(7 downto 0);

        UART_Rx              : in    std_logic;
        UART_Tx              : out   std_logic;

        config_spi_io0_io     : inout std_logic;
        config_spi_io1_io     : inout std_logic;
        config_spi_ss_io      : inout std_logic_vector(0 to 0)
        );
end entity top;

architecture behavioral of top is

    signal clk_cpu        : std_logic;
    signal clk_cpu_locked : std_logic;

begin

  clk_cpu_inst : entity work.clk_wiz_1
    port map (
      clk_in1  => clk_in,
      clk_out1 => clk_cpu,
      locked   => clk_cpu_locked
    );
    
    
    system_inst : entity work.system
        port map (
            sys_clock      => clk_cpu,
            sys_clk_locked => clk_cpu_locked,

            -- Control panel
            -- SPI FLASH interface
            config_spi_io0_io => config_spi_io0_io,
            config_spi_io1_io => config_spi_io1_io,
            config_spi_ss_io  => config_spi_ss_io,

            -- HyperRAM device interface
            hyperram_resetn_o  => hyperram_resetn_o,
            hyperram_csn_o     => hyperram_csn_o,
            hyperram_ck_o      => hyperram_ck_o,
            hyperram_rwds_io   => hyperram_rwds_io,
            hyperram_dq_io     => hyperram_dq_io,

            -- UART interface
            uart_over_usb_rxd => UART_Rx,
            uart_over_usb_txd => UART_Tx
            );


end architecture behavioral;
