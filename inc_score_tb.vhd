LIBRARY STD;
LIBRARY IEEE;
--Additional standard or custom libraries go here
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END ENTITY testbench;

ARCHITECTURE behavioral OF testbench IS

    COMPONENT clock_counter is
    PORT (
        clk, rst : in std_logic;
        game_tick : out std_logic
    );
    END COMPONENT clock_counter;

    COMPONENT inc_scoreA IS
    PORT (
        clk, rst_n, start : IN STD_LOGIC;
        bulletA_x, bulletA_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        tankB_x, tankB_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        A_score : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        dead : OUT STD_LOGIC;

    );
    END COMPONENT inc_scoreA;

    COMPONENT bulletA IS
    PORT (
        clk, rst_n, start : IN STD_LOGIC;
        fired, dead : IN STD_LOGIC;
        tank_x, tank_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        pos_x, pos_y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
    END COMPONENT bulletA;

     --testbench signals
    SIGNAL clk_tb, rst_tb, game_tick_tb : STD_LOGIC;
    signal bulletA_x_tb : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(320, 10));
    signal bulletA_y_tb : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(452-27, 10));
    --initialize a stationary tank B
    signal tankB_x_tb : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(320, 10));
    signal tankB_y_tb : STD_LOGIC_VECTOR(9 DOWNTO 0) := std_logic_vector(to_unsigned(27, 10));
    SIGNAL A_score_tb : STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '0');
    SIGNAL fired_tb, dead_tb: STD_LOGIC;

    signal bullet_speed : integer := 25;

    CONSTANT PERIOD : TIME := 20 ns; --50 mhz clock

    begin
        clockCount : clock_counter
        GENERIC MAP(
            BITS => 3
        )
        PORT MAP(
            clk => clk_tb,
            rst => rst_tb,
            game_tick => game_tick_tb
        );

        bullet : bulletA
        PORT MAP(
            clk => clk_tb,
            rst_n => rst_tb,
            start => game_tick_tb,
            fired => fired_tb, 
            dead => dead_tb,
            tank_x => tankB_x_tb, 
            tank_y => tankB_y_tb,
            pos_x => bulletA_x_tb,
            pos_y => bulletA_y_tb
        );

        inc_score : inc_scoreA
        PORT MAP (
            clk => clk_tb,
            rst_n => rst_tb,
            start => game_tick_tb,
            bulletA_x => bulletA_x_tb, 
            bulletA_y => bulletA_y_tb,
            tankB_x => tankB_x_tb, 
            tankB_y => tankB_y_tb,
            A_score => A_score_tb,
            dead => dead_tb
        );

        --instantiate clock
        clk_generate : PROCESS IS
        BEGIN
            clk_tb <= '0';
            WAIT FOR (PERIOD/2);
            clk_tb <= '1';
            WAIT FOR (PERIOD/2);
        END PROCESS clk_generate;

        --instantiate reset
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

        -- increment_process : process is
        -- begin 
        --     wait for PERIOD;
        --     bulletA_y_tb <= std_logic_vector(unsigned(bulletA_y_tb) - bullet_speed);
        -- end process;
    
end architecture behavioral;