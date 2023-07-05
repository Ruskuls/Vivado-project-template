library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library src_lib;
library tb_lib;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.vc_context;
use vunit_lib.signal_checker_pkg.all;

use vunit_lib.check_pkg.all;

library osvvm;
context osvvm.OsvvmContext;
use osvvm.RandomPkg.all;
use osvvm.CoveragePkg.all;

entity axi4full_to_avmm_tb is
    --vunit
    generic (
        RUNNER_CFG : string
        );
end entity axi4full_to_avmm_tb;

architecture bench of axi4full_to_avmm_tb is

    constant AXIL_BUS : bus_master_t := new_bus(data_length => 32, address_length => 32);

    shared variable rnd_stimuli, rnd_expected : RandomPType;

    constant C_HYPERRAM_FREQ_MHZ : integer := 100;
    constant C_HYPERRAM_PHASE    : real    := 162.000;
    constant C_DELAY             : time    := 1 ns;
    constant G_DATA_SIZE         : integer := 16;

    signal clk_x1     : std_logic;
    signal clk_x2     : std_logic;
    signal clk_x2_del : std_logic;
    signal rst        : std_logic;

    signal tb_start : std_logic;

    signal sys_resetn   : std_logic;
    signal sys_csn      : std_logic;
    signal sys_ck       : std_logic;
    signal sys_rwds     : std_logic;
    signal sys_dq       : std_logic_vector(7 downto 0);
    signal sys_rwds_in  : std_logic;
    signal sys_dq_in    : std_logic_vector(7 downto 0);
    signal sys_rwds_out : std_logic;
    signal sys_dq_out   : std_logic_vector(7 downto 0);
    signal sys_rwds_oe  : std_logic;
    signal sys_dq_oe    : std_logic;

    -- HyperRAM simulation device interface
    signal hr_resetn : std_logic;
    signal hr_csn    : std_logic;
    signal hr_ck     : std_logic;
    signal hr_rwds   : std_logic;
    signal hr_dq     : std_logic_vector(7 downto 0);

    -- AXIlite signals
    signal s_axi_aresetn : std_logic;
    signal s_axi_awaddr  : std_logic_vector(31 downto 0);
    signal s_axi_awvalid : std_logic_vector(0 downto 0);
    signal s_axi_awready : std_logic_vector(0 downto 0);
    signal s_axi_wdata   : std_logic_vector(31 downto 0);
    signal s_axi_wstrb   : std_logic_vector(3 downto 0);
    signal s_axi_wvalid  : std_logic_vector(0 downto 0);
    signal s_axi_wready  : std_logic_vector(0 downto 0);
    signal s_axi_bresp   : std_logic_vector(1 downto 0);
    signal s_axi_bvalid  : std_logic_vector(0 downto 0);
    signal s_axi_bready  : std_logic_vector(0 downto 0);
    signal s_axi_araddr  : std_logic_vector(31 downto 0);
    signal s_axi_arvalid : std_logic_vector(0 downto 0);
    signal s_axi_arready : std_logic_vector(0 downto 0);
    signal s_axi_rdata   : std_logic_vector(31 downto 0);
    signal s_axi_rresp   : std_logic_vector(1 downto 0);
    signal s_axi_rvalid  : std_logic_vector(0 downto 0);
    signal s_axi_rready  : std_logic_vector(0 downto 0);

    -- Avalon memory mapped interface
    signal avm_write         : std_logic;
    signal avm_read          : std_logic;
    signal avm_address       : std_logic_vector(31 downto 0);
    signal avm_writedata     : std_logic_vector(15 downto 0);
    signal avm_byteenable    : std_logic_vector(1 downto 0);
    signal avm_burstcount    : std_logic_vector(7 downto 0);
    signal avm_readdata      : std_logic_vector(15 downto 0);
    signal avm_readdatavalid : std_logic;
    signal avm_waitrequest   : std_logic;


    -- HyperRAM tri-state control signals
    signal hr_rwds_in  : std_logic;
    signal hr_dq_in    : std_logic_vector(7 downto 0);
    signal hr_rwds_out : std_logic;
    signal hr_dq_out   : std_logic_vector(7 downto 0);
    signal hr_rwds_oe  : std_logic;
    signal hr_dq_oe    : std_logic;


    signal avm_rnd_addr : std_logic_vector(31 downto 0) := x"00000000";
    signal avm_rnd_data : std_logic_vector(G_DATA_SIZE-1 downto 0);

begin

    axi4full_to_avm_1 : entity src_lib.axi4full_to_avm
        generic map (
            data_width => 32)
        port map (
            s_axi_aclk          => clk_x1,
            s_axi_aresetn       => s_axi_aresetn,
            s_axi_awaddr        => s_axi_awaddr,
            s_axi_awvalid       => s_axi_awvalid,
            s_axi_awready       => s_axi_awready,
            s_axi_wdata         => s_axi_wdata,
            s_axi_wstrb         => s_axi_wstrb,
            s_axi_wvalid        => s_axi_wvalid,
            s_axi_wready        => s_axi_wready,
            s_axi_bresp         => s_axi_bresp,
            s_axi_bvalid        => s_axi_bvalid,
            s_axi_bready        => s_axi_bready,
            s_axi_araddr        => s_axi_araddr,
            s_axi_arvalid       => s_axi_arvalid,
            s_axi_arready       => s_axi_arready,
            s_axi_rdata         => s_axi_rdata,
            s_axi_rresp         => s_axi_rresp,
            s_axi_rvalid        => s_axi_rvalid,
            s_axi_rready        => s_axi_rready,
            avm_write_o         => avm_write,
            avm_read_o          => avm_read,
            avm_address_o       => avm_address,
            avm_writedata_o     => avm_writedata,
            avm_byteenable_o    => avm_byteenable,
            avm_burstcount_o    => avm_burstcount,
            avm_readdata_i      => avm_readdata,
            avm_readdatavalid_i => avm_readdatavalid,
            avm_waitrequest_i   => avm_waitrequest);

    axi_lite_master_inst : entity vunit_lib.axi_lite_master
        generic map (
            BUS_HANDLE => AXIL_BUS
            )
        port map (
            aclk    => clk_x1,
            arready => s_axi_arready(0),
            arvalid => s_axi_arvalid(0),
            araddr  => s_axi_araddr,
            rready  => s_axi_rready(0),
            rvalid  => s_axi_rvalid(0),
            rdata   => s_axi_rdata,
            rresp   => s_axi_rresp,
            awready => s_axi_awready(0),
            awvalid => s_axi_awvalid(0),
            awaddr  => s_axi_awaddr,
            wready  => s_axi_wready(0),
            wvalid  => s_axi_wvalid(0),
            wdata   => s_axi_wdata,
            wstrb   => s_axi_wstrb,
            bvalid  => s_axi_bvalid(0),
            bready  => s_axi_bready(0),
            bresp   => s_axi_bresp
            );

    ---------------------------------------------------------
    -- Generate clock and reset
    ---------------------------------------------------------

    i_clk : entity tb_lib.clk
        generic map (
            G_HYPERRAM_FREQ_MHZ => C_HYPERRAM_FREQ_MHZ,
            G_HYPERRAM_PHASE    => C_HYPERRAM_PHASE
            )
        port map (
            clk_x1_o     => clk_x1,
            clk_x2_o     => clk_x2,
            clk_x2_del_o => clk_x2_del,
            rst_o        => rst
            );                          -- i_clk

    --------------------------------------------------------
    -- Instantiate HyperRAM interface
    --------------------------------------------------------

    i_hyperram : entity src_lib.hyperram
        port map (
            clk_x1_i            => clk_x1,
            clk_x2_i            => clk_x2,
            clk_x2_del_i        => clk_x2_del,
            rst_i               => rst,
            avm_write_i         => avm_write,
            avm_read_i          => avm_read,
            avm_address_i       => avm_address,
            avm_writedata_i     => avm_writedata,
            avm_byteenable_i    => avm_byteenable,
            avm_burstcount_i    => avm_burstcount,
            avm_readdata_o      => avm_readdata,
            avm_readdatavalid_o => avm_readdatavalid,
            avm_waitrequest_o   => avm_waitrequest,
            hr_resetn_o         => sys_resetn,
            hr_csn_o            => sys_csn,
            hr_ck_o             => sys_ck,
            hr_rwds_in_i        => sys_rwds_in,
            hr_dq_in_i          => sys_dq_in,
            hr_rwds_out_o       => sys_rwds_out,
            hr_dq_out_o         => sys_dq_out,
            hr_rwds_oe_o        => sys_rwds_oe,
            hr_dq_oe_o          => sys_dq_oe
            );                          -- i_hyperram


    ----------------------------------
    -- Tri-state buffers for HyperRAM
    ----------------------------------

    sys_rwds    <= sys_rwds_out when sys_rwds_oe = '1' else 'Z';
    sys_dq      <= sys_dq_out   when sys_dq_oe = '1'   else (others => 'Z');
    sys_rwds_in <= sys_rwds;
    sys_dq_in   <= sys_dq;

    ---------------------------------------------------------
    -- Connect controller to device (with delay)
    ---------------------------------------------------------

    hr_resetn <= sys_resetn after C_DELAY;
    hr_csn    <= sys_csn    after C_DELAY;
    hr_ck     <= sys_ck     after C_DELAY;

    i_wiredelay2_rwds : entity tb_lib.wiredelay2
        generic map (
            G_DELAY => C_DELAY
            )
        port map (
            A => sys_rwds,
            B => hr_rwds
            );

    gen_dq_delay : for i in 0 to 7 generate
        i_wiredelay2_rwds : entity tb_lib.wiredelay2
            generic map (
                G_DELAY => C_DELAY
                )
            port map (
                A => sys_dq(i),
                B => hr_dq(i)
                );
    end generate gen_dq_delay;


    ---------------------------------------------------------
    -- Instantiate HyperRAM simulation model
    ---------------------------------------------------------

    i_s27kl0642 : entity tb_lib.s27kl0642
        port map (
            DQ7      => hr_dq(7),
            DQ6      => hr_dq(6),
            DQ5      => hr_dq(5),
            DQ4      => hr_dq(4),
            DQ3      => hr_dq(3),
            DQ2      => hr_dq(2),
            DQ1      => hr_dq(1),
            DQ0      => hr_dq(0),
            RWDS     => hr_rwds,
            CSNeg    => hr_csn,
            CK       => hr_ck,
            CKn      => not hr_ck,
            RESETNeg => hr_resetn
            );                          -- i_s27kl0642


    ---------------------------------------------------------
    -- Main test process
    ---------------------------------------------------------

    main : process is
        variable read_bus_d : std_logic_vector(G_DATA_SIZE-1 downto 0);  -- ncycles counts how many vectors were applied
        variable ncycles    : natural;
    begin

        test_runner_setup(runner, RUNNER_CFG);

        -- Initialize to same seed to get same sequence
        rnd_stimuli.InitSeed(rnd_stimuli'instance_name);
        rnd_expected.InitSeed(rnd_stimuli'instance_name);

        while test_suite loop
            if (run("bulk_write_bulk_read_operation")) then
                wait for 1 us;
                for write_count in 0 to 1023 loop
                    avm_rnd_addr <= (rnd_stimuli.RandSlv(0, 2**23, avm_rnd_addr'length));
                    avm_rnd_data <= (rnd_stimuli.RandSlv(0, 2**15, avm_rnd_data'length));
                    wait for 10 ns;
                    write_bus(net, AXIL_BUS, avm_rnd_addr, avm_rnd_data);
                    wait for 300 ns;
                end loop;

                for read_count in 0 to 1023 loop
                    avm_rnd_addr <= (rnd_expected.RandSlv(0, 2**23, avm_rnd_addr'length));
                    avm_rnd_data <= (rnd_expected.RandSlv(0, 2**15, avm_rnd_data'length));
                    wait for 10 ns;
                    read_bus(net, AXIL_BUS, avm_rnd_addr, read_bus_d);
                    check_equal(read_bus_d, avm_rnd_data);
                    wait for 50 ns;
                end loop;
                test_runner_cleanup(runner);
            end if;

            if (run("seq_write_read_operation")) then
                wait for 1 us;
                for i in 0 to 8191 loop
                    avm_rnd_addr <= (rnd_stimuli.RandSlv(0, 2**23, avm_rnd_addr'length));
                    avm_rnd_data <= (rnd_stimuli.RandSlv(0, 2**15, avm_rnd_data'length));
                    wait for 10 ns;
                    write_bus(net, AXIL_BUS, avm_rnd_addr, avm_rnd_data);
                    wait for 10 ns;
                    read_bus(net, AXIL_BUS, avm_rnd_addr, read_bus_d);
                    check_equal(read_bus_d, avm_rnd_data);
                    wait for 200 ns;
                    nCycles      := nCycles + 1;
                end loop;
                info ("All tests are completed");
                test_runner_cleanup(runner);
            end if;
        end loop;
    end process;

end architecture bench;
