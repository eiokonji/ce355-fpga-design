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

    COMPONENT tank_pos IS
        PORT (
            clk, rst, start : IN STD_LOGIC;
            speed : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            pos_x : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            updated_pos_x : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    END COMPONENT tank_pos;

    CONSTANT PERIOD : TIME := 20 ns; --50 mhz clock

    SIGNAL clk_tb, rst_tb, game_tick_tb: std_logic;
    signal speed_tb : std_logic_vector(1 downto 0) := (1 => '1', 0=> '0');
    signal pos_x_tb : std_logic_vector(9 downto 0) := (3 => '1', 4 => '1', 8 => '1', OTHERS => '0');
    signal updated_pos_x_tb : std_logic_vector(9 downto 0) := (3 => '1', 4 => '1', 8 => '1', OTHERS => '0');

BEGIN

    dut : tank_pos
    PORT MAP(
        clk => clk_tb,
        start => game_tick_tb,
        rst => rst_tb,
        speed => speed_tb,
        pos_x => pos_x_tb,
        updated_pos_x => updated_pos_x_tb
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

    update_pos : process (clk_tb) is 
    begin 
        if (rst_tb = '1') then
            pos_x_tb <= (3 => '1', 4 => '1', 8 => '1', OTHERS => '0');
        elsif (rising_edge(clk_tb)) then 
            pos_x_tb <= updated_pos_x_tb;
        end if;
    end process;

END ARCHITECTURE behavioral;