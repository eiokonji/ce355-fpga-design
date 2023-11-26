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

    COMPONENT tankA IS
        PORT (
            clk, rst_n, start : IN STD_LOGIC;
            speed : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            pos_x, pos_y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    END COMPONENT tankA;

    CONSTANT PERIOD : TIME := 20 ns; --50 mhz clock

    SIGNAL clk_tb, rst_tb, game_tick_tb : STD_LOGIC;
    SIGNAL speed_tb : STD_LOGIC_VECTOR(3 DOWNTO 0) := (2 => '1', 1 => '1', others => '0');
    SIGNAL pos_x_tb : STD_LOGIC_VECTOR(9 DOWNTO 0) := (3 => '1', 4 => '1', 8 => '1', OTHERS => '0');
    SIGNAL pos_y_tb : STD_LOGIC_VECTOR(9 DOWNTO 0) := (3 => '1', 4 => '1', 8 => '1', OTHERS => '0');

BEGIN

    dut : tankA
    PORT MAP(
        clk => clk_tb,
        start => game_tick_tb,
        rst_n => rst_tb,
        speed => speed_tb,
        pos_x => pos_x_tb, 
        pos_y => pos_y_tb
    );

    clockCount : clock_counter
    GENERIC MAP(
        BITS => 20
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

    -- update_pos : PROCESS (clk_tb) IS
    -- BEGIN
    --     IF (rst_tb = '1') THEN
    --         pos_x_tb <= (3 => '1', 4 => '1', 8 => '1', OTHERS => '0');
    --     ELSIF (rising_edge(clk_tb)) THEN
    --         pos_x_tb <= updated_pos_x_tb;
    --     END IF;
    -- END PROCESS;

END ARCHITECTURE behavioral;