--This module increments the score of the player A by checking if bullet A has hit tank B
LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

--inputs: clk, rst_n, center positions
--outputs: left_bound, right_bound, top_bound, bottom_bound based on top left position
--width: 80, height: 34

ENTITY inc_scoreB IS
    PORT (
        clk, rst_n, start : IN STD_LOGIC;
        bulletB_x, bulletB_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        tankA_x, tankA_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        B_score : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        dead : OUT STD_LOGIC;

    );
END ENTITY inc_scoreB;

ARCHITECTURE behavioralScore OF inc_scoreB IS
    --initialize states
    TYPE states IS (idle, play);
    SIGNAL state, next_state : states;

    --clocking signals
    SIGNAL B_score1, B_score_c : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL dead1, dead_c : STD_LOGIC;

    --signals for collision check
    SIGNAL B_bullet_lb : STD_LOGIC_VECTOR(9 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(bulletB_x) - 5);
    SIGNAL B_bullet_rb : STD_LOGIC_VECTOR(9 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(bulletB_x) + 5);
    SIGNAL B_bullet_tb : STD_LOGIC_VECTOR(9 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(bulletB_y) - 10);
    SIGNAL B_bullet_bb : STD_LOGIC_VECTOR(9 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(bulletB_y) + 10);
    SIGNAL A_tank_lb : STD_LOGIC_VECTOR(9 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(tankA_x) - 40);
    SIGNAL A_tank_rb : STD_LOGIC_VECTOR(9 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(tankA_x) + 40);
    SIGNAL A_tank_bb : STD_LOGIC_VECTOR(9 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(tankA_y) + 17);

    --constant for comparison
    CONSTANT WIN_SCORE : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '1');

BEGIN
    clockProcess : PROCESS (clk, rst_n) IS
    BEGIN
        IF (rst_n = '1') THEN
            state <= idle;
            dead1 <= '0';
            B_score1 <= (OTHERS => '0');

        ELSIF (rising_edge(clk)) THEN
            state <= next_state;
            dead1 <= dead_c;
            B_score1 <= B_score_c;
        END IF;
    END PROCESS clockProcess;

    incProcess : PROCESS (start, state, bulletB_x, bulletB_y, tankA_x, B_score1) IS
    BEGIN
        next_state <= state;
        B_score_c <= B_score1;
        dead_c <= dead1;

        CASE state IS
            WHEN idle =>
                IF (start = '1') THEN
                    next_state <= play;
                    dead_c <= '0';
                ELSE
                    next_state <= idle;
                    dead_c <= '1';
                END IF;

            WHEN play =>
                --check for collision (has bullet A hit tank B?)
                IF (B_score1 = WIN_SCORE) THEN
                    next_state <= win;
                    dead_c <= '1';
                ELSE
                    IF (B_bullet_bb <= A_tank_tb) THEN
                        IF (B_bullet_lb >= A_tank_lb AND B_bullet_rb <= A_tank_rb) THEN
                            B_score_c <= STD_LOGIC_VECTOR(unsigned(B_score1) + 1);
                        ELSIF (B_bullet_lb >= A_tank_lb AND ((B_bullet_lb + 10) <= (A_tank_rb + 9))) THEN
                            B_score_c <= STD_LOGIC_VECTOR(unsigned(B_score1) + 1);
                        ELSIF ((B_bullet_rb <= A_tank_rb) AND ((B_bullet_rb - 10) >= (A_tank_lb - 9))) THEN
                            B_score_c <= STD_LOGIC_VECTOR(unsigned(B_score1) + 1);
                        ELSE
                            B_score_c <= B_score1; --score stays the same
                        END IF;
                    END IF;
                END IF;

            WHEN win =>
                --don't do anything?
                next_state <= win;
                dead_c <= '1';

        END CASE;

    END PROCESS incProcess;

    --assign output signals
    B_score <= B_score_c;
    dead <= dead1;

END ARCHITECTURE behavioralScore;