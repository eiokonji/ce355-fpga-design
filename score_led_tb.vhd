LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY testbench IS
END ENTITY testbench;

ARCHITECTURE behavioral OF testbench IS
    COMPONENT score_led IS
        PORT (
            clock_50MHz, reset : IN STD_LOGIC;
            scoreA, scoreB : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
            A_segments, B_segments : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
        );
    END COMPONENT score_led;

    CONSTANT PERIOD : TIME := 20 ns; --50 mhz clock

    SIGNAL clk_tb, rst_tb : STD_LOGIC;
    SIGNAL scoreA_tb, scoreB_tb : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL A_segments_tb, B_segments_tb : STD_LOGIC_VECTOR (6 DOWNTO 0);

BEGIN

    dut : score_led
    PORT MAP(
        clock_50MHz => clk_tb,
        reset => rst_tb,
        scoreA => scoreA_tb,
        scoreB => scoreB_tb,
        A_segments => A_segments_tb,
        B_segments => B_segments_tb
    );

    --instantiate clock
    clk_generate : PROCESS IS
    BEGIN
        clk_tb <= '0';
        WAIT FOR (PERIOD/2);
        clk_tb <= '1';
        WAIT FOR (PERIOD/2);
    END PROCESS clk_generate;

    sA_generate : PROCESS IS
    BEGIN
        scoreA_tb <= "00";
        scoreB_tb <= "00";
        WAIT FOR (PERIOD);
        scoreA_tb <= "01";
        scoreB_tb <= "01";
        WAIT FOR (PERIOD);
        scoreA_tb <= "10";
        scoreB_tb <= "10";
        WAIT FOR (PERIOD);
        scoreA_tb <= "11";
        scoreB_tb <= "11";
        WAIT FOR (PERIOD);
    END PROCESS sA_generate;


END ARCHITECTURE behavioral;