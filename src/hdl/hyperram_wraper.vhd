library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity hyperram_wrapper is
  port
    (
      clk     : in std_logic;
      reset_n : in std_logic;

      -- Avalon Memory Mapped interface    AVM_HYPERRAM_address : out STD_LOGIC_VECTOR ( 31 downto 0 );
      AVM_HYPERRAM_address            : in  std_logic_vector (31 downto 0);
      AVM_HYPERRAM_beginbursttransfer : in  std_logic;
      AVM_HYPERRAM_burstcount         : in  std_logic_vector (7 downto 0);
      AVM_HYPERRAM_byteenable         : in  std_logic_vector (3 downto 0);
      AVM_HYPERRAM_read               : in  std_logic;
      AVM_HYPERRAM_readdata           : out std_logic_vector (31 downto 0);
      AVM_HYPERRAM_readdatavalid      : out std_logic;
      AVM_HYPERRAM_response           : out std_logic_vector (1 downto 0);
      AVM_HYPERRAM_waitrequest        : out std_logic;
      AVM_HYPERRAM_write              : in  std_logic;
      AVM_HYPERRAM_writedata          : in  std_logic_vector (31 downto 0);
      AVM_HYPERRAM_writeresponsevalid : out std_logic;

      -- HyperRAM device interface
      hyperram_resetn  : out   std_logic;
      hyperram_csn     : out   std_logic;
      hyperram_ck      : out   std_logic;
      hyperram_rwds_io : inout std_logic;
      hyperram_dq_io   : inout std_logic_vector(7 downto 0)

      );
end hyperram_wrapper;

architecture rtl of hyperram_wrapper is

  constant C_HYPERRAM_FREQ_MHZ : integer := 100;
  constant C_HYPERRAM_PHASE    : real    := 162.000;

  -- Clock signals used by HyperRam
  signal clk_x1     : std_logic;
  signal clk_x2     : std_logic;
  signal clk_x2_del : std_logic;

  signal rst : std_logic;

  signal avm_address : std_logic_vector(31 downto 0) := (others => '0');

  signal AVM_HYPERRAM_waitrequest_next : std_logic;
  signal AVM_HYPERRAM_waitrequest_reg  : std_logic;

  signal m_avm_write         : std_logic;
  signal m_avm_read          : std_logic;
  signal m_avm_address       : std_logic_vector(31 downto 0);
  signal m_avm_writedata     : std_logic_vector(15 downto 0);
  signal m_avm_byteenable    : std_logic_vector(1 downto 0);
  signal m_avm_burstcount    : std_logic_vector(7 downto 0);
  signal m_avm_readdata      : std_logic_vector(15 downto 0);
  signal m_avm_readdatavalid : std_logic;
  signal m_avm_waitrequest   : std_logic;

  -- HyperRAM tri-state control signals
  signal hyperram_rwds_in  : std_logic;
  signal hyperram_dq_in    : std_logic_vector(7 downto 0);
  signal hyperram_rwds_out : std_logic;
  signal hyperram_dq_out   : std_logic_vector(7 downto 0);
  signal hyperram_rwds_oe  : std_logic;
  signal hyperram_dq_oe    : std_logic;

begin

  ----------------------------------------------------
  -- Clock generator, used by HyperRam controller
  ----------------------------------------------------
  i_clk : entity work.clk
    generic map
    (
      G_HYPERRAM_FREQ_MHZ => C_HYPERRAM_FREQ_MHZ,
      G_HYPERRAM_PHASE    => C_HYPERRAM_PHASE
      )
    port map
    (
      sys_clk_i    => clk,
      sys_rstn_i   => reset_n,
      clk_x1_o     => clk_x1,
      clk_x2_o     => clk_x2,
      clk_x2_del_o => clk_x2_del,
      rst_o        => rst
      );                                -- i_clk


  -- modify address to contain only 19bits of it
  avm_address(18 downto 0)  <= AVM_HYPERRAM_address(18 downto 0);
  avm_address(31 downto 19) <= (others => '0');

  --------------------------------------------------------
  -- AVM Data width converter from 2bti to 16bit
  --------------------------------------------------------

  avm_decrease_1 : entity work.avm_decrease
    generic map (
      G_SLAVE_ADDRESS_SIZE  => 32,
      G_SLAVE_DATA_SIZE     => 32,
      G_MASTER_ADDRESS_SIZE => 32,
      G_MASTER_DATA_SIZE    => 16)
    port map (
      clk_i                 => clk,
      rst_i                 => not reset_n,
      s_avm_write_i         => AVM_HYPERRAM_write,
      s_avm_read_i          => AVM_HYPERRAM_read,
      s_avm_address_i       => avm_address,  --AVM_HYPERRAM_address,
      s_avm_writedata_i     => AVM_HYPERRAM_writedata,
      s_avm_byteenable_i    => AVM_HYPERRAM_byteenable,
      s_avm_burstcount_i    => AVM_HYPERRAM_burstcount,
      s_avm_readdata_o      => AVM_HYPERRAM_readdata,
      s_avm_readdatavalid_o => AVM_HYPERRAM_readdatavalid,
      s_avm_waitrequest_o   => AVM_HYPERRAM_waitrequest_next,

      m_avm_write_o         => m_avm_write,
      m_avm_read_o          => m_avm_read,
      m_avm_address_o       => m_avm_address,
      m_avm_writedata_o     => m_avm_writedata,
      m_avm_byteenable_o    => m_avm_byteenable,
      m_avm_burstcount_o    => m_avm_burstcount,
      m_avm_readdata_i      => m_avm_readdata,
      m_avm_readdatavalid_i => m_avm_readdatavalid,
      m_avm_waitrequest_i   => m_avm_waitrequest);

  --------------------------------------------------------
  -- Instantiate HyperRAM interface
  --------------------------------------------------------

  hyperram_inst : entity work.hyperram
    port map (
      clk_x1_i     => clk_x1,
      clk_x2_i     => clk_x2,
      clk_x2_del_i => clk_x2_del,
      rst_i        => rst,

      -- Avalon Memory Mapped interface
      avm_write_i         => m_avm_write,
      avm_read_i          => m_avm_read,
      avm_address_i       => avm_address,
      avm_writedata_i     => m_avm_writedata,
      avm_byteenable_i    => m_avm_byteenable,
      avm_burstcount_i    => m_avm_burstcount,
      avm_readdata_o      => m_avm_readdata,
      avm_readdatavalid_o => m_avm_readdatavalid,
      avm_waitrequest_o   => m_avm_waitrequest,

      -- Physical HyperRam IC interface
      hr_resetn_o   => hyperram_resetn,
      hr_csn_o      => hyperram_csn,
      hr_ck_o       => hyperram_ck,
      hr_rwds_in_i  => hyperram_rwds_in,
      hr_dq_in_i    => hyperram_dq_in,
      hr_rwds_out_o => hyperram_rwds_out,
      hr_dq_out_o   => hyperram_dq_out,
      hr_rwds_oe_o  => hyperram_rwds_oe,
      hr_dq_oe_o    => hyperram_dq_oe
      );                                -- hyperram_inst

  -- generate AVM write AVM_HYPERRAM_writeresponsevalid signal
  -- It should be active for one clock cycle if waitrequest had a rising edge

  process(clk)
  begin
    if rising_edge(clk) then
      AVM_HYPERRAM_waitrequest_reg <= AVM_HYPERRAM_waitrequest_next;
    end if;
  end process;

  AVM_HYPERRAM_writeresponsevalid <= '1' when (AVM_HYPERRAM_waitrequest_next = '1') and (AVM_HYPERRAM_waitrequest_reg = '0') else
                                     '0';

  -- assign
  AVM_HYPERRAM_waitrequest <= AVM_HYPERRAM_waitrequest_next;

  ----------------------------------
  -- Tri-state buffers for HyperRAM
  ----------------------------------

  hyperram_rwds_io <= hyperram_rwds_out when hyperram_rwds_oe = '1' else 'Z';
  hyperram_dq_io   <= hyperram_dq_out   when hyperram_dq_oe = '1'   else (others => 'Z');
  hyperram_rwds_in <= hyperram_rwds_io;
  hyperram_dq_in   <= hyperram_dq_io;


  --debug
  avmm_debug_ila : entity work.avmm_debug
    port map
    (
      clk       => clk,
      probe0(0) => AVM_HYPERRAM_write,
      probe1(0) => AVM_HYPERRAM_read,
      probe2(0) => AVM_HYPERRAM_waitrequest,
      probe3(0) => AVM_HYPERRAM_readdatavalid,
      probe4    => AVM_HYPERRAM_address,
      probe5    => AVM_HYPERRAM_writedata(15 downto 0),
      probe6    => AVM_HYPERRAM_readdata(15 downto 0),
      probe7    => AVM_HYPERRAM_byteenable,
      probe8    => AVM_HYPERRAM_burstcount,
      probe9(0) => AVM_HYPERRAM_writeresponsevalid
      );

end rtl;
