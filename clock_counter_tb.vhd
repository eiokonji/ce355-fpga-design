LIBRARY STD;
LIBRARY IEEE;
--Additional standard or custom libraries go here
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END ENTITY testbench;

ARCHITECTURE behavioral OF testbench IS
    COMPONENT clock_counter IS
        GENERIC (
            BITS : INTEGER := 3
        );
        PORT (
            clk, rst : IN STD_LOGIC;
            game_tick : OUT STD_LOGIC
        );
    END COMPONENT clock_counter;

    SIGNAL clk_tb : STD_LOGIC;
    SIGNAL rst_n_tb : STD_LOGIC;
    SIGNAL game_tick_tb : STD_LOGIC := '0';

    CONSTANT PERIOD : TIME := 20 ns; --50 mhz clock

BEGIN
    dut : clock_counter
    GENERIC MAP(
        BITS => 3
    )
    PORT MAP(
        clk => clk_tb,
        rst => rst_n_tb,
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

    -- reset generate
    rst_generate : PROCESS IS
    BEGIN
        rst_n_tb <= '0';
        WAIT UNTIL (clk_tb = '0');
        WAIT UNTIL (clk_tb = '1');
        rst_n_tb <= '1';
        WAIT UNTIL (clk_tb = '0');
        WAIT UNTIL (clk_tb = '1');
        rst_n_tb <= '0';
        WAIT;
    END PROCESS rst_generate;

END ARCHITECTURE behavioral;