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

    COMPONENT bulletA IS
        PORT (
            clk, rst_n, start : IN STD_LOGIC;
            fired, dead : IN STD_LOGIC;
            tank_x, tank_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            pos_x, pos_y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    END COMPONENT bulletA;

    CONSTANT PERIOD : TIME := 20 ns; --50 mhz clock

    --testbench signals
    SIGNAL clk_tb, rst_tb, game_tick_tb : STD_LOGIC;
    SIGNAL speed_tb : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tank_pos_x_tb : STD_LOGIC_VECTOR(9 DOWNTO 0) := (3 => '1', 4 => '1', 8 => '1', OTHERS => '0');
    SIGNAL tank_pos_y_tb : STD_LOGIC_VECTOR(9 DOWNTO 0) := (3 => '1', 4 => '1', 8 => '1', OTHERS => '0');
    SIGNAL bullet_pos_x_tb, bullet_pos_y_tb : STD_LOGIC_VECTOR(9 DOWNTO 0) := (others=> '0');

    signal fired_tb, dead_tb : std_logic;

BEGIN
    dut : bulletA
    PORT MAP (
        clk => clk_tb,
        start => game_tick_tb,
        rst_n => rst_tb,
        fired => fired_tb,
        dead => dead_tb,
        tank_x => tank_pos_x_tb,
        tank_y => tank_pos_y_tb,
        pos_x => bullet_pos_x_tb,
        pos_y => bullet_pos_y_tb
    );

    tank : tankA
    PORT MAP(
        clk => clk_tb,
        start => game_tick_tb,
        rst_n => rst_tb,
        speed => speed_tb,
        pos_x => tank_pos_x_tb,
        pos_y => tank_pos_y_tb
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

    fire_process : process is 
    begin 
        fired_tb <= '0';
        dead_tb <= '0';
        WAIT UNTIL (clk_tb = '0');
        WAIT UNTIL (clk_tb = '1');
        fired_tb <= '1';
        WAIT UNTIL (dead_tb = '1');
        fired_tb <= '0';
        WAIT UNTIL (clk_tb = '0');
        WAIT UNTIL (clk_tb = '1');
        fired_tb <= '1';

        WAIT;
    end process;

    tank_process : process (dead_tb) is 
    begin 
        wait until (dead_tb = '1');
        --move tank to different position so that bullet goes off screen
        tank_pos_x_tb <= (others => '0');
        -- wait until (dead_tb = '1');
        -- tank_pos_x_tb <=
        wait;
    end process;




END ARCHITECTURE behavioral;