-- This module is structural. It basically has all the game components without the associated peripherals.

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY game IS
    PORT (
        CLOCK_50 : IN STD_LOGIC;
        RESET : IN STD_LOGIC;

        TANKA_SPEED, TANKB_SPEED : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        BULLETA_FIRED, BULLETB_FIRED : IN STD_LOGIC;

        TANKA_X, TANKA_Y, TANKB_X, TANKB_Y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        BULLETA_X, BULLETA_Y, BULLETB_X, BULLETB_Y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        BULLETA_DEAD, BULLETB_DEAD : out std_logic;

        WINNER : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        GAME_TICKS : out std_logic; --this is so that we can more easily control the game in the simulation

        A_SCORE, B_SCORE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    );
END ENTITY game;

ARCHITECTURE structural OF game IS
    COMPONENT clock_counter IS
        GENERIC (
            BITS : INTEGER := 20
        );
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

    -- signals for screen position updates
    SIGNAL RESET_N : STD_LOGIC;
    SIGNAL GAME_TICKS : std_logic;

    -- signals for tank and bullet positions
    SIGNAL TANKA_X_T, TANKA_Y_T, TANKB_X_T, TANKB_Y_T : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL BULLETA_X_T, BULLETA_Y_T, BULLETB_X_T, BULLETB_Y_T : STD_LOGIC_VECTOR(9 DOWNTO 0);

    -- signals for bullet fired and dead
    SIGNAL A_DEAD, B_DEAD : STD_LOGIC;

    --signals for scoring
    SIGNAL A_SCORE_T, B_SCORE_T : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL WINNER_T : STD_LOGIC_VECTOR(1 DOWNTO 0);

    -- constants for selection between A and B
    CONSTANT A : STD_LOGIC_VECTOR := '0';
    CONSTANT B : STD_LOGIC_VECTOR := '1';
BEGIN
    RESET_N <= NOT RESET;
    BULLETA_DEAD <= A_DEAD;
    BULLETB_DEAD <= B_DEAD;

    clockCount : clock_counter
    GENERIC MAP(
        BITS => 20
    )
    PORT MAP(
        clk => CLOCK_50,
        rst => RESET_N,
        game_tick => GAME_TICKS
    );

    tankAModule : tank
    PORT MAP(
        clk => CLOCK_50,
        rst_n => RESET_N,
        start => GAME_TICKS,
        A_or_B => A,
        winner => WINNER_T,
        speed => TANKA_SPEED,
        pos_x => TANKA_X_T,
        pos_y => TANKA_Y_T
    );

    tankBModule : tank
    PORT MAP(
        clk => CLOCK_50,
        rst_n => RESET_N,
        start => GAME_TICKS,
        A_or_B => B,
        winner => WINNER_T,
        speed => TANKB_SPEED,
        pos_x => TANKB_X_T,
        pos_y => TANKB_Y_T
    );

    bulletAModule : bullet
    PORT MAP(
        clk => CLOCK_50,
        start => GAME_TICKS,
        rst_n => RESET_N,
        A_or_B => A,
        fired => BULLETA_FIRED,
        dead => A_DEAD,
        tank_x => TANKA_X_T,
        tank_y => TANKA_Y_T,
        pos_x => BULLETA_X_T,
        pos_y => BULLETA_Y_T
    );

    bulletBModule : bullet
    PORT MAP(
        clk => CLOCK_50,
        start => GAME_TICKS,
        rst_n => RESET_N,
        A_or_B => B,
        fired => BULLETB_FIRED,
        dead => B_DEAD,
        tank_x => TANKB_X_T,
        tank_y => TANKB_Y_T,
        pos_x => BULLETB_X_T,
        pos_y => BULLETB_Y_T
    );

    scoreA : inc_score
    PORT MAP(
        clk => CLOCK_50,
        start => GAME_TICKS,
        rst_n => RESET_N,
        A_or_B => A,
        bullet_x => BULLETA_X_T,
        bullet_y => BULLETA_Y_T,
        tank_x => TANKB_X_T,
        tank_y => TANKB_Y_T,
        score => A_SCORE_T,
        dead => A_DEAD
    );

    scoreB : inc_score
    PORT MAP(
        clk => CLOCK_50,
        start => GAME_TICKS,
        rst_n => RESET_N,
        A_or_B => B,
        bullet_x => BULLETB_X_T,
        bullet_y => BULLETB_Y_T,
        tank_x => TANKA_X_T,
        tank_y => TANKA_Y_T,
        score => B_SCORE_T,
        dead => B_DEAD
    );

    gameState : game_state
    PORT MAP(
        clk => CLOCK_50,
        start => GAME_TICKS,
        rst_n => RESET_N,
        A_score => A_SCORE_T,
        B_score => B_SCORE_T,
        winner => WINNER
    );

    -- assign temp signals to outputs
    WINNER <= WINNER_T;
    TANKA_X <= TANKA_X_T;
    TANKA_Y <= TANKA_Y_T;
    TANKB_X <= TANKB_X_T;
    TANKB_Y <= TANKB_Y_T;
    BULLETA_X <= BULLETA_X_T;
    BULLETA_Y <= BULLETA_Y_T;
    BULLETB_X <= BULLETB_X_T;
    BULLETB_Y <= BULLETB_Y_T;

    A_SCORE <= A_SCORE_T;
    B_SCORE <= B_SCORE_T;

END ARCHITECTURE structural;