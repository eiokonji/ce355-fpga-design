LIBRARY STD;
LIBRARY IEEE;
--Additional standard or custom libraries go here
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END ENTITY testbench;

ARCHITECTURE behavioral OF testbench IS
    COMPONENT clock_counter IS
        PORT (
            clk, rst_n : IN STD_LOGIC;
            game_tick : OUT STD_LOGIC
        );
    END COMPONENT clock_counter;

    SIGNAL clk_tb : STD_LOGIC;
    SIGNAL rst_n_tb : STD_LOGIC;
    SIGNAL game_tick_tb : STD_LOGIC := '0';

    CONSTANT PERIOD : TIME := 20 ns; --50 mhz clock

BEGIN
    dut : clock_counter
    PORT MAP(
        clk => clk_tb,
        rst_n => rst_n_tb,
        game_tick => game_tick_tb
    );

    --instantiate clock
    clk_generate : PROCESS IS
    BEGIN
        clk_tb <= '0';
        WAIT FOR (PERIOD/2);
        clk_tb <= '1';
        WAIT FOR (PERIOD/2);
    END PROCESS clk_generate;

    -- process is
    --     begin
    --     -- rst_n_tb <= '0';

    -- end process;



END ARCHITECTURE behavioral;