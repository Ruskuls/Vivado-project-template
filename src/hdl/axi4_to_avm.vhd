library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity axi4_to_avm is
  generic (
    data_width : integer := 16
    );
  port (
    -- Slave AXI memory mapped interface
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;
    s_axi_awaddr  : in  std_logic_vector(31 downto 0);
    s_axi_awvalid : in  std_logic_vector(0 downto 0);
    s_axi_awready : out std_logic_vector(0 downto 0);
    s_axi_wdata   : in  std_logic_vector(31 downto 0);
    s_axi_wstrb   : in  std_logic_vector(3 downto 0);
    s_axi_wvalid  : in  std_logic_vector(0 downto 0);
    s_axi_wready  : out std_logic_vector(0 downto 0);
    s_axi_bresp   : out std_logic_vector(1 downto 0);
    s_axi_bvalid  : out std_logic_vector(0 downto 0);
    s_axi_bready  : in  std_logic_vector(0 downto 0);
    s_axi_araddr  : in  std_logic_vector(31 downto 0);
    s_axi_arvalid : in  std_logic_vector(0 downto 0);
    s_axi_arready : out std_logic_vector(0 downto 0);
    s_axi_rdata   : out std_logic_vector(31 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic_vector(0 downto 0);
    s_axi_rready  : in  std_logic_vector(0 downto 0);

    -- Avalon Memory Map
    avm_write_o         : out std_logic;
    avm_read_o          : out std_logic;
    avm_address_o       : out std_logic_vector(31 downto 0);
    avm_writedata_o     : out std_logic_vector(15 downto 0);
    avm_byteenable_o    : out std_logic_vector(1 downto 0);
    avm_burstcount_o    : out std_logic_vector(7 downto 0);
    avm_readdata_i      : in  std_logic_vector(15 downto 0);
    avm_readdatavalid_i : in  std_logic;
    avm_waitrequest_i   : in  std_logic
    );
end entity axi4_to_avm;

architecture behavioral of axi4_to_avm is

  -- FSM type
  type state_type is (idle_s, write_s, read_s, read_valid_s);

  signal state_next : state_type;
  signal state_reg  : state_type := idle_s;

  signal avm_waitrequest_reg                                               : std_logic;
  signal avm_waitrequest_rising_edge_reg, avm_waitrequest_rising_edge_next : std_logic;

begin

  process (s_axi_aclk) is
  begin

    if (s_axi_aclk'event and s_axi_aclk = '1') then
      state_reg                       <= state_next;
      avm_waitrequest_reg             <= avm_waitrequest_i;
      avm_waitrequest_rising_edge_reg <= avm_waitrequest_rising_edge_next;
    end if;

  end process;

  -- detect rising edge of avm_waitrequest_i signal
  avm_waitrequest_rising_edge_next <= '1' when ((avm_waitrequest_i = '1') and (avm_waitrequest_reg = '0')) else
                                      '0';

  -- Async logic
  process(all) is
  begin

    -- deault signal values
    state_next    <= state_reg;
    s_axi_awready <= (others => '0');
    s_axi_arready <= (others => '0');
    s_axi_rvalid  <= (others => '0');
    avm_write_o   <= '0';
    avm_read_o    <= '0';

    case state_reg is
      when idle_s =>

        if (s_axi_awvalid = "1") then
          avm_writedata_o <= s_axi_wdata(15 downto 0);
          avm_address_o(15 downto 0)   <= s_axi_awaddr(15 downto 0);
          avm_address_o(31 downto 16)  <= (others => '0');
          avm_write_o     <= '1';
          state_next      <= write_s;
        elsif (s_axi_arvalid = "1") then
          avm_address_o(15 downto 0)   <= s_axi_awaddr(15 downto 0);
          avm_address_o(31 downto 16)  <= (others => '0');
          s_axi_arready <= (others => '1');
          avm_read_o    <= '1';
          state_next    <= read_s;
        end if;

      when write_s =>

        if (avm_waitrequest_rising_edge_next = '1') then
          avm_write_o   <= '0';
          s_axi_awready <= (others => '1');
          state_next    <= idle_s;
        else
          avm_write_o <= '1';
        end if;

      when read_s =>

        if (avm_waitrequest_rising_edge_next = '1') then
          avm_read_o <= '0';
          state_next <= read_valid_s;
        else
          avm_read_o <= '1';
        end if;

      when read_valid_s =>

        if (avm_readdatavalid_i) then
          s_axi_rvalid <= (others => '1');
          state_next   <= idle_s;
        end if;

      when others =>

        state_next <= idle_s;

    end case;

  end process;
  -- slave AXI memory mapped interface feedback
  s_axi_rresp  <= (others => '0');
  s_axi_bresp  <= (others => '0');
  s_axi_wready <= s_axi_wvalid;
  s_axi_bvalid <= s_axi_bready;
  s_axi_rdata(15 downto 0)  <= avm_readdata_i;
  s_axi_rdata(31 downto 16) <= (others => '0');

  -- Avalon memory mapped interface
  avm_byteenable_o          <= "11";
  avm_burstcount_o          <= X"01";
end architecture behavioral;
