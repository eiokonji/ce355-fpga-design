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

    COMPONENT tank IS
        PORT (
            clk, rst_n, start : IN STD_LOGIC;
            A_or_B : IN STD_LOGIC;
            speed : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            winner : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            pos_x, pos_y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    END COMPONENT tank;

    COMPONENT bullet IS
        PORT (
            clk, rst_n, start : IN STD_LOGIC;
            A_or_B : IN STD_LOGIC;
            fired, dead : IN STD_LOGIC;
            tank_x, tank_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            pos_x, pos_y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    END COMPONENT bullet;

    COMPONENT inc_score IS
        PORT (
            clk, rst_n, start : IN STD_LOGIC;
            A_or_B : IN STD_LOGIC;
            bullet_x, bullet_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            tank_x, tank_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            score : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            dead : OUT STD_LOGIC
        );
    END COMPONENT inc_score;

    COMPONENT game_state IS
        PORT (
            clk, rst_n, start : IN STD_LOGIC;
            A_score, B_score : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            game_over : OUT STD_LOGIC;
            winner : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
        );
    END COMPONENT game_state;

    --TESTBENCH SIGNALS
    CONSTANT PERIOD : TIME := 20 ns; --50 mhz clock
    CONSTANT A : std_logic := '0';
    CONSTANT B : std_logic := '1';

    --control signals
    SIGNAL clk_tb, RESET, RESET_N, game_ticks : STD_LOGIC;

    --tank signals
    SIGNAL TANKA_X, TANKA_Y, TANKB_X, TANKB_Y : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL TANKA_SPEED, TANKB_SPEED : STD_LOGIC_VECTOR(3 DOWNTO 0) := (0 => '1', OTHERS => '0');

    --bullet signals
    SIGNAL BULLETA_X, BULLETA_Y, BULLETB_X, BULLETB_Y : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL BULLETA_FIRED, BULLETB_FIRED : STD_LOGIC;
    SIGNAL A_DEAD, B_DEAD : STD_LOGIC;

    --score and game state
    SIGNAL A_SCORE, B_SCORE : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL WINNER : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL GAME_OVER : std_logic;

begin
    RESET_N <= not RESET;

    ------------------------------------------------------------
    --component instantiation
    clockCount : clock_counter
    GENERIC MAP(
        BITS => 20
    )
    PORT MAP(
        clk => clk_tb,
        rst => RESET_N,
        game_tick => game_ticks
    );

    tankAModule : tank
    PORT MAP(
        clk => clk_tb,
        rst_n => RESET_N,
        start => game_ticks,
        A_or_B => A,
        winner => WINNER,
        speed => TANKA_SPEED,
        pos_x => TANKA_X,
        pos_y => TANKA_Y
    );

    tankBModule : tank
    PORT MAP(
        clk => clk_tb,
        rst_n => RESET_N,
        start => game_ticks,
        A_or_B => B,
        winner => WINNER,
        speed => TANKB_SPEED,
        pos_x => TANKB_X,
        pos_y => TANKB_Y
    );

    bulletAModule : bullet
    PORT MAP(
        clk => clk_tb,
        start => game_ticks,
        rst_n => RESET_N,
        A_or_B => A,
        fired => BULLETA_FIRED,
        dead => A_DEAD,
        tank_x => TANKA_X,
        tank_y => TANKA_Y,
        pos_x => BULLETA_X,
        pos_y => BULLETA_Y
    );

    bulletBModule : bullet
    PORT MAP(
        clk => clk_tb,
        start => game_ticks,
        rst_n => RESET_N,
        A_or_B => B,
        fired => BULLETB_FIRED,
        dead => B_DEAD,
        tank_x => TANKB_X,
        tank_y => TANKB_Y,
        pos_x => BULLETB_X,
        pos_y => BULLETB_Y
    );

    scoreA : inc_score
    PORT MAP(
        clk => clk_tb,
        start => game_ticks,
        rst_n => RESET_N,
        A_or_B => A,
        bullet_x => BULLETA_X,
        bullet_y => BULLETA_Y,
        tank_x => TANKB_X,
        tank_y => TANKB_Y,
        score => A_SCORE,
        dead => A_DEAD
    );

    scoreB : inc_score
    PORT MAP(
        clk => clk_tb,
        start => game_ticks,
        rst_n => RESET_N,
        A_or_B => B,
        bullet_x => BULLETB_X,
        bullet_y => BULLETB_Y,
        tank_x => TANKA_X,
        tank_y => TANKA_Y,
        score => B_SCORE,
        dead => B_DEAD
    );

    gameState : game_state
    PORT MAP(
        clk => clk_tb,
        start => game_ticks,
        rst_n => RESET_N,
        A_score => A_SCORE,
        B_score => B_SCORE,
        winner => WINNER
    );

    --instantiate clock
    clk_generate : PROCESS IS
    BEGIN
        clk_tb <= '0';
        WAIT FOR (PERIOD/2);
        clk_tb <= '1';
        WAIT FOR (PERIOD/2);
    END PROCESS clk_generate;

    --THESE PROCESSES SIMULATE PLAYER INPUT BY SYSTEMATICALLY CHANGING SIGNALS
    --keyboard inputs (speed, shoot)
    --1) tanks moving back and forth
    --2) switch speed of tank A
    --2) set speed of tank B to 0 (stationary)
    --3) tank A shoots and hits tank B
    --4) tank A shoots and misses (bullet goes off screen)
    --5) set both tanks to stationary
    --6) tank B shoots and hits tank A
    --7) tank B shoots until score increments to 3
    --8) reset game
    --systematically move tanks

    update_process : process is
    begin
    end process;



end ARCHITECTURE behavioral;