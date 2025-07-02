-------------------------------------------------------------------------------
-- Testbench para o periférico de 4 registradores de 4 bits
-------------------------------------------------------------------------------

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Std_Logic_unsigned.all;
use work.p_MIPS_S.all;

entity tb_Inst_Perif is
end tb_Inst_Perif;

architecture sim of tb_Inst_Perif is

    -- Component declaration
    component Inst_Perif
        port(
            clock, reset: in std_logic;
            ce_CPU: in std_logic;
            rw_CPU: in std_logic;
            bw_CPU: in std_logic;
            d_address_CPU: in std_logic_vector(31 downto 0);
            data_out_CPU: in std_logic_vector(31 downto 0);
            data_out_Per: out std_logic_vector(31 downto 0);
            display_sel: out std_logic_vector(3 downto 0);
            display_seg: out std_logic_vector(6 downto 0)
        );
    end component;

    -- Signals
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    signal ce      : std_logic := '0';
    signal rw      : std_logic := '0';
    signal bw      : std_logic := '0';
    signal addr    : std_logic_vector(31 downto 0) := (others => '0');
    signal data_wr : std_logic_vector(31 downto 0) := (others => '0');
    signal data_rd : std_logic_vector(31 downto 0);
    signal seg     : std_logic_vector(6 downto 0);
    signal sel     : std_logic_vector(3 downto 0);

    -- Clock generation
    constant clk_period : time := 20 ns;

begin
    -- Instantiate the DUT
    uut: Inst_Perif
        port map (
            clock => clk,
            reset => rst,
            ce_CPU => ce,
            rw_CPU => rw,
            bw_CPU => bw,
            d_address_CPU => addr,
            data_out_CPU => data_wr,
            data_out_Per => data_rd,
            display_sel => sel,
            display_seg => seg
        );

    -- Clock process
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        rst <= '1'; wait for 40 ns;
        rst <= '0'; wait for 40 ns;

        -- Write reg0 (0x10008000)
        ce <= '1'; rw <= '0'; bw <= '0';
        addr <= x"10008000";
        data_wr <= x"00000005"; -- valor = 5
        wait for clk_period;

        -- Write reg1 (0x10008004)
        addr <= x"10008004";
        data_wr <= x"0000000A"; -- valor = 10
        wait for clk_period;

        -- Write reg2 (0x10008008)
        addr <= x"10008008";
        data_wr <= x"00000003";
        wait for clk_period;

        -- Write reg3 (0x1000800C)
        addr <= x"1000800C";
        data_wr <= x"0000000F";
        wait for clk_period;

        -- Read reg0
        rw <= '1';
        addr <= x"10008000";
        wait for clk_period;

        -- Read reg1
        addr <= x"10008004";
        wait for clk_period;

        -- Read reg2
        addr <= x"10008008";
        wait for clk_period;

        -- Read reg3
        addr <= x"1000800C";
        wait for clk_period;

        ce <= '0';
        wait;
    end process;

end sim;
