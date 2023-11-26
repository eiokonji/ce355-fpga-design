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
            clk, rst : IN STD_LOGIC;
            game_tick : OUT STD_LOGIC
        );
    END COMPONENT clock_counter;

    COMPONENT game_state IS
        PORT (
            clk, rst_n, start : IN STD_LOGIC;
            A_score, B_score : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            game_over, winner : OUT STD_LOGIC
        );
    END COMPONENT game_state;

    --testbench signals
    SIGNAL clk_tb, rst_tb, game_tick_tb : STD_LOGIC;
    SIGNAL A_score_tb, B_score_tb : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL game_over_tb, winner_tb : STD_LOGIC;

    CONSTANT PERIOD : TIME := 20 ns; --50 mhz clock

BEGIN

    dut : game_state
    PORT MAP(
        clk => clk_tb,
        start => game_tick_tb,
        rst => rst_tb,
        A_score => A_score_tb,
        B_score => B_score_tb,
        game_over => game_over_tb,
        winner => winner_tb
    );

    clockCount : clock_counter
    GENERIC MAP(
        BITS => 3
    )
    PORT MAP(
        clk => clk_tb,
        rst => rst_tb,
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

    reset_process : PROCESS IS
    BEGIN
        rst_tb <= '0';
        WAIT UNTIL (clk_tb = '0');
        WAIT UNTIL (clk_tb = '1');
        rst_tb <= '1';
        WAIT UNTIL (clk_tb = '0');
        WAIT UNTIL (clk_tb = '1');
        rst_tb <= '0';
        WAIT;
    END PROCESS reset_process;

    score_generate : process IS
    begin
        --ah
    end process;

END ARCHITECTURE behavioral;