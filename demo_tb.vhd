LIBRARY STD;
LIBRARY IEEE;
--Additional standard or custom libraries go here
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END ENTITY testbench;

ARCHITECTURE behavioral OF testbench IS

    COMPONENT game IS
    PORT (
        CLOCK_50 : IN STD_LOGIC;
        RESET : IN STD_LOGIC;

        TANKA_SPEED, TANKB_SPEED : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        BULLETA_FIRED, BULLETB_FIRED : IN STD_LOGIC;

        TANKA_X, TANKA_Y, TANKB_X, TANKB_Y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        BULLETA_X, BULLETA_Y, BULLETB_X, BULLETB_Y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        BULLETA_DEAD, BULLETB_DEAD : out std_logic;

        WINNER : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        GAME_TICKS : OUT std_logic;

        A_SCORE, B_SCORE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    );
    END COMPONENT game;

    --TESTBENCH SIGNALS
    CONSTANT PERIOD : TIME := 20 ns; --50 mhz clock

    --control signals
    SIGNAL clk_tb, GAME_TICKS : STD_LOGIC;
    SIGNAL RESET : STD_LOGIC := '1';
    SIGNAL RESET_N : STD_LOGIC := '0';

    --tank signals
    SIGNAL TANKA_X, TANKA_Y, TANKB_X, TANKB_Y : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL TANKA_SPEED, TANKB_SPEED : STD_LOGIC_VECTOR(3 DOWNTO 0) := (0 => '1', OTHERS => '0');
    CONSTANT SPEED0 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    CONSTANT SPEED1 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
    CONSTANT SPEED5 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
    CONSTANT SPEED10 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1010";

    --bullet signals
    SIGNAL BULLETA_X, BULLETA_Y, BULLETB_X, BULLETB_Y : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL BULLETA_FIRED, BULLETB_FIRED, BULLETA_DEAD, BULLETB_DEAD : STD_LOGIC;

    --score and game state
    SIGNAL A_SCORE, B_SCORE : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL WINNER : STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN
    RESET_N <= NOT RESET;

    ------------------------------------------------------------
    game_inst : game
    PORT MAP(
        CLOCK_50 => clk_tb,
        RESET => RESET,

        TANKA_SPEED => TANKA_SPEED, 
        TANKB_SPEED => TANKB_SPEED,
        BULLETA_FIRED => BULLETA_FIRED, 
        BULLETB_FIRED => BULLETB_FIRED,

        TANKA_X => TANKA_X, 
        TANKA_Y =>TANKA_Y, 
        TANKB_X => TANKB_X, 
        TANKB_Y => TANKB_Y,
        BULLETA_X => BULLETA_X, 
        BULLETA_Y => BULLETA_Y, 
        BULLETB_X => BULLETB_X, 
        BULLETB_Y => BULLETB_Y,
        BULLETA_DEAD => BULLETA_DEAD, 
        BULLETB_DEAD => BULLETB_DEAD,

        WINNER => WINNER,
        GAME_TICKS => GAME_TICKS,

        A_SCORE => A_SCORE, 
        B_SCORE => B_SCORE
    );

    --instantiate clock
    clk_generate : PROCESS IS
    BEGIN
        clk_tb <= '0';
        WAIT FOR (PERIOD/2);
        clk_tb <= '1';
        WAIT FOR (PERIOD/2);
    END PROCESS clk_generate;

    --THESE PROCESSES SIMULATE PLAY BY SYSTEMATICALLY CHANGING SIGNALS
    --keyboard inputs (speed, shoot)
    --1) tanks moving back and forth
    --2) switch speed of tank A
    --3) set speed of tank B to 0 (stationary)
    --4) tank A shoots while moving and misses (bullet goes off screen, preserves x pos)
    --5) set both tanks to stationary
    --6) tank A shoots and hits tank B
    --7) tank B shoots and hits tank A
    --8) tank B shoots until score increments to 3
    --9) reset game

    update_process : PROCESS IS
    BEGIN
        --1) tanks moving back and forth
        WAIT FOR (GAME_TICKS = '1');
        WAIT FOR (GAME_TICKS = '0');
        WAIT FOR (GAME_TICKS = '1');
        WAIT FOR (GAME_TICKS = '0');
        WAIT FOR (GAME_TICKS = '1');
        WAIT FOR (GAME_TICKS = '0');
        WAIT FOR (GAME_TICKS = '1');
        WAIT FOR (GAME_TICKS = '0');
        --2) switch speed of tank A
        --change speed of tank A and observe position
        TANKA_SPEED <= SPEED5;
        WAIT FOR (GAME_TICKS = '0');
        WAIT FOR (GAME_TICKS = '1');
        WAIT FOR (GAME_TICKS = '0');
        WAIT FOR (GAME_TICKS = '1');
        WAIT FOR (GAME_TICKS = '0');
        WAIT FOR (GAME_TICKS = '1');
        WAIT FOR (GAME_TICKS = '0');
        WAIT FOR (GAME_TICKS = '1');
        --wait for tank to collide with wall and switch direction
        TANKA_SPEED <= SPEED10;
        WAIT FOR (TANKA_X = std_logic_vector(to_unsigned(200,10))); 
        WAIT FOR (GAME_TICKS = '0');
        WAIT FOR (GAME_TICKS = '1');
        WAIT FOR (TANKA_X = std_logic_vector(to_unsigned(200,10))); --checking when it reaching this x pos twice
        TANKA_SPEED <= SPEED1;
        WAIT FOR (GAME_TICKS = '0');
        WAIT FOR (GAME_TICKS = '1');
        WAIT FOR (GAME_TICKS = '0');
        WAIT FOR (GAME_TICKS = '1');
        WAIT FOR (GAME_TICKS = '0');
        WAIT FOR (GAME_TICKS = '1');
        WAIT FOR (GAME_TICKS = '0');
        WAIT FOR (GAME_TICKS = '1');
        --3) set speed of tank B to 0 (stationary)
        TANKB_SPEED <= SPEED0;
       --4) tank A shoots while moving and misses (bullet goes off screen, preserves x pos)
        BULLETA_FIRED <= '1';
        --observe bullet x pos same while y pos changes
        --observe behavior when bullet goes off screen
        wait for (BULLETA_DEAD = '0');
        wait for (BULLETA_DEAD = '1');
        wait for (BULLETA_DEAD = '0');
        wait for (BULLETA_DEAD = '1');
        BULLETA_FIRED <= '0';
        WAIT FOR (GAME_TICKS = '0');
        WAIT FOR (GAME_TICKS = '1');
        WAIT FOR (GAME_TICKS = '0');
        WAIT FOR (GAME_TICKS = '1');
        WAIT FOR (GAME_TICKS = '0');
        WAIT FOR (GAME_TICKS = '1');
        
         --5) set both tanks to stationary and align them
        WAIT FOR (TANKA_X = std_logic_vector(to_unsigned(320, 10)));
        TANKA_SPEED <= SPEED0;
        WAIT FOR (TANKB_X = std_logic_vector(to_unsigned(320, 10)));
        TANKB_SPEED <= SPEED0;

        --6) tank A shoots and hits tank B
        BULLETA_FIRED <= '1';
        WAIT FOR (GAME_TICKS = '0');
        WAIT FOR (GAME_TICKS = '1');
        BULLETA_FIRED <= '0';
        WAIT FOR (A_SCORE = "0001");
        --7) tank B shoots and hits tank A
        BULLETB_FIRED <= '1';
        --8) tank B shoots until score increments to 3
        WAIT FOR (B_SCORE = "0011");
        WAIT FOR (GAME_TICKS = '0');
        WAIT FOR (GAME_TICKS = '1');
        --9) reset game
        RESET <= '0';
        WAIT FOR (GAME_TICKS = '0');
        WAIT FOR (GAME_TICKS = '1');
        RESET <= '1';

        WAIT;

    END PROCESS;

END ARCHITECTURE behavioral;