library IEEE;
use IEEE.STD_LOGIC_1164.all;
library UNISIM;
use UNISIM.VCOMPONENTS.all;
entity system is
    port
        (
            sys_clock      : in std_logic;
            sys_clk_locked : in std_logic;

            config_spi_io0_io : inout std_logic;
            config_spi_io1_io : inout std_logic;
            config_spi_ss_io  : inout std_logic_vector (0 to 0);

            -- HyperRAM device interface
            hyperram_resetn_o : out   std_logic;
            hyperram_csn_o    : out   std_logic;
            hyperram_ck_o     : out   std_logic;
            hyperram_rwds_io  : inout std_logic;
            hyperram_dq_io    : inout std_logic_vector(7 downto 0);

            uart_over_usb_rxd : in  std_logic;
            uart_over_usb_txd : out std_logic
            );
end system;

architecture STRUCTURE of system is

    signal config_spi_io0_i : std_logic;
    signal config_spi_io0_o : std_logic;
    signal config_spi_io0_t : std_logic;
    signal config_spi_io1_i : std_logic;
    signal config_spi_io1_o : std_logic;
    signal config_spi_io1_t : std_logic;
    signal config_spi_ss_i  : std_logic_vector (0 to 0);
    signal config_spi_ss_o  : std_logic_vector (0 to 0);
    signal config_spi_ss_t  : std_logic;

    -- Avalon Memory Mapped signals
    signal AVM_HYPERRAM_address            : std_logic_vector (31 downto 0);
    signal AVM_HYPERRAM_beginbursttransfer : std_logic;
    signal AVM_HYPERRAM_burstcount         : std_logic_vector (7 downto 0);
    signal AVM_HYPERRAM_byteenable         : std_logic_vector (3 downto 0);
    signal AVM_HYPERRAM_read               : std_logic;
    signal AVM_HYPERRAM_readdata           : std_logic_vector (31 downto 0);
    signal AVM_HYPERRAM_readdatavalid      : std_logic;
    signal AVM_HYPERRAM_response           : std_logic_vector (1 downto 0);
    signal AVM_HYPERRAM_waitrequest        : std_logic;
    signal AVM_HYPERRAM_write              : std_logic;
    signal AVM_HYPERRAM_writedata          : std_logic_vector (31 downto 0);
    signal AVM_HYPERRAM_writeresponsevalid : std_logic;

begin

    config_spi_io0_iobuf : IOBUF
        port map
        (
            I  => config_spi_io0_o,
            IO => config_spi_io0_io,
            O  => config_spi_io0_i,
            T  => config_spi_io0_t
            );

    config_spi_io1_iobuf : IOBUF
        port map
        (
            I  => config_spi_io1_o,
            IO => config_spi_io1_io,
            O  => config_spi_io1_i,
            T  => config_spi_io1_t
            );

    config_spi_ss_iobuf_0 : IOBUF
        port map
        (
            I  => config_spi_ss_o(0),
            IO => config_spi_ss_io(0),
            O  => config_spi_ss_i(0),
            T  => config_spi_ss_t
            );

    microblaze_system_i : entity work.microblaze_system
        port map
        (
            sys_clock => sys_clock,
            locked    => sys_clk_locked,

            AVM_HYPERRAM_address            => AVM_HYPERRAM_address,
            AVM_HYPERRAM_beginbursttransfer => AVM_HYPERRAM_beginbursttransfer,
            AVM_HYPERRAM_burstcount         => AVM_HYPERRAM_burstcount,
            AVM_HYPERRAM_byteenable         => AVM_HYPERRAM_byteenable,
            AVM_HYPERRAM_read               => AVM_HYPERRAM_read,
            AVM_HYPERRAM_readdata           => AVM_HYPERRAM_readdata,
            AVM_HYPERRAM_readdatavalid      => AVM_HYPERRAM_readdatavalid,
            AVM_HYPERRAM_response           => AVM_HYPERRAM_response,
            AVM_HYPERRAM_waitrequest        => AVM_HYPERRAM_waitrequest,
            AVM_HYPERRAM_write              => AVM_HYPERRAM_write,
            AVM_HYPERRAM_writedata          => AVM_HYPERRAM_writedata,
            AVM_HYPERRAM_writeresponsevalid => AVM_HYPERRAM_writeresponsevalid,

            config_spi_io0_i => config_spi_io0_i,
            config_spi_io0_o => config_spi_io0_o,
            config_spi_io0_t => config_spi_io0_t,
            config_spi_io1_i => config_spi_io1_i,
            config_spi_io1_o => config_spi_io1_o,
            config_spi_io1_t => config_spi_io1_t,
            config_spi_ss_i  => config_spi_ss_i,
            config_spi_ss_o  => config_spi_ss_o,
            config_spi_ss_t  => config_spi_ss_t,


            uart_over_usb_rxd => uart_over_usb_rxd,
            uart_over_usb_txd => uart_over_usb_txd
            );

    hyperram_wrapper_inst : entity work.hyperram_wrapper
        port map (
            clk     => sys_clock,
            reset_n => sys_clk_locked,

            AVM_HYPERRAM_address            => AVM_HYPERRAM_address,
            AVM_HYPERRAM_beginbursttransfer => AVM_HYPERRAM_beginbursttransfer,
            AVM_HYPERRAM_burstcount         => AVM_HYPERRAM_burstcount,
            AVM_HYPERRAM_byteenable         => AVM_HYPERRAM_byteenable,
            AVM_HYPERRAM_read               => AVM_HYPERRAM_read,
            AVM_HYPERRAM_readdata           => AVM_HYPERRAM_readdata,
            AVM_HYPERRAM_readdatavalid      => AVM_HYPERRAM_readdatavalid,
            AVM_HYPERRAM_response           => AVM_HYPERRAM_response,
            AVM_HYPERRAM_waitrequest        => AVM_HYPERRAM_waitrequest,
            AVM_HYPERRAM_write              => AVM_HYPERRAM_write,
            AVM_HYPERRAM_writedata          => AVM_HYPERRAM_writedata,
            AVM_HYPERRAM_writeresponsevalid => AVM_HYPERRAM_writeresponsevalid,

            hyperram_resetn  => hyperram_resetn_o,
            hyperram_csn     => hyperram_csn_o,
            hyperram_ck      => hyperram_ck_o,
            hyperram_rwds_io => hyperram_rwds_io,
            hyperram_dq_io   => hyperram_dq_io);

end STRUCTURE;
