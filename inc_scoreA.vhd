--This module increments the score of the player A by checking if bullet A has hit tank B
LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

--inputs: clk, rst_n, center positions
--outputs: left_bound, right_bound, top_bound, bottom_bound based on top left position
--width: 80, height: 34

ENTITY inc_scoreA IS
    PORT (
        clk, rst_n, start : IN STD_LOGIC;
        bulletA_x, bulletA_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        tankB_x, tankB_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        A_score : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        dead : OUT STD_LOGIC

    );
END ENTITY inc_scoreA;

ARCHITECTURE behavioralScore OF inc_scoreA IS
    --initialize states
    TYPE states IS (idle, play, collision, win);
    SIGNAL state, next_state : states;

    --clocking signals
    SIGNAL A_score1, A_score_c : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL dead1, dead_c : STD_LOGIC;

    --signals for collision check
    SIGNAL A_bullet_lb, A_bullet_rb, A_bullet_tb : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL B_tank_lb, B_tank_rb, B_tank_bb, B_tank_tb: STD_LOGIC_VECTOR(9 DOWNTO 0);

    --constant for comparison
    CONSTANT WIN_SCORE : STD_LOGIC_VECTOR(3 DOWNTO 0) := (0 => '1', 1 => '1', OTHERS => '0');

BEGIN

    A_bullet_lb <= STD_LOGIC_VECTOR(unsigned(bulletA_x) - 5);
    A_bullet_rb <= STD_LOGIC_VECTOR(unsigned(bulletA_x) + 5);
    A_bullet_tb <= STD_LOGIC_VECTOR(unsigned(bulletA_y) - 10);
    B_tank_lb <= STD_LOGIC_VECTOR(unsigned(tankB_x) - 40);
    B_tank_rb <= STD_LOGIC_VECTOR(unsigned(tankB_x) + 40);
    B_tank_bb <= STD_LOGIC_VECTOR(unsigned(tankB_y) + 17);
	 B_tank_tb <= STD_LOGIC_VECTOR(unsigned(tankB_y) - 17);

    clockProcess : PROCESS (clk, rst_n) IS
    BEGIN
        IF (rst_n = '1') THEN
            state <= idle;
            dead1 <= '0';
            A_score1 <= (OTHERS => '0');

        ELSIF (rising_edge(clk)) THEN
            state <= next_state;
            dead1 <= dead_c;
            A_score1 <= A_score_c;
        END IF;
    END PROCESS clockProcess;

    incProcess : PROCESS (start, state, dead1, bulletA_x, bulletA_y, tankB_x, A_score1, A_bullet_lb, A_bullet_rb, A_bullet_tb, B_tank_lb, B_tank_rb, B_tank_bb, B_tank_tb) IS
    BEGIN
        next_state <= state;
        A_score_c <= A_score1;
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
                IF (start = '1') THEN
                    --check if player has already won
                    IF (A_score1 = WIN_SCORE) THEN
                        next_state <= win;
                        dead_c <= '1'; --deactivate bullet
                    ELSE
                        IF (unsigned(A_bullet_tb) <= unsigned(B_tank_bb)) THEN
                            --check for collision (has bullet A hit tank B?)
                            -- in the center?
                            IF (unsigned(A_bullet_lb) >= unsigned(B_tank_lb) AND unsigned(A_bullet_rb) <= unsigned(B_tank_rb)) THEN
                                A_score_c <= STD_LOGIC_VECTOR(unsigned(A_score1) + 1);
                                dead_c <= '1';
                                next_state <= collision;
                                -- on the right
                            ELSIF ((unsigned(A_bullet_lb) >= unsigned(B_tank_lb)) AND ((unsigned(A_bullet_lb) + 1) < unsigned(B_tank_rb))) THEN
                                A_score_c <= STD_LOGIC_VECTOR(unsigned(A_score1) + 1);
                                dead_c <= '1';
                                next_state <= collision;
                                -- on the left
                            ELSIF ((unsigned(A_bullet_rb) <= unsigned(B_tank_rb)) AND ((unsigned(A_bullet_rb) - 1) > unsigned(B_tank_lb))) THEN
                                A_score_c <= STD_LOGIC_VECTOR(unsigned(A_score1) + 1);
                                dead_c <= '1';
                                next_state <= collision;

                                --check if bullet is off screen
                            ELSIF (unsigned(A_bullet_tb) <= 10) THEN
                                A_score_c <= A_score1;
                                dead_c <= '1';
                                next_state <= collision;
                            ELSE
                                A_score_c <= A_score1; --score stays the same
                                dead_c <= '0';
                            END IF;
                        END IF;
                    END IF;
                END IF;

            WHEN collision =>
                --IF (start = '1') THEN
                    IF (unsigned(A_bullet_tb) >= unsigned(B_tank_tb)) THEN
                        next_state <= play;
                        dead_c <= '0';
                    END IF;
                --END IF;

            WHEN win =>
                --if (start ='1') then
                --don't do anything?
                next_state <= win;
                dead_c <= '1';
                -- end if;

        END CASE;

    END PROCESS incProcess;

    --assign output signals
    A_score <= A_score_c;
    dead <= dead1;

END ARCHITECTURE behavioralScore;