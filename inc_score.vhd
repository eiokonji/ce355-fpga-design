--This module increments the score of the players by checking if a bullet has collided with the opponent tank
LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

--inputs: clk, rst_n, start (game_ticks), A or B, self bullet, enemy tank
--outputs: score and dead (indicates if bullet is still)

ENTITY inc_score IS
    PORT (
        clk, rst_n, start : IN STD_LOGIC;
        A_or_B : IN STD_LOGIC;
        bullet_x, bullet_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        tank_x, tank_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        score : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        dead : OUT STD_LOGIC

    );
END ENTITY inc_score;

ARCHITECTURE behavioralScore OF inc_score IS
    --initialize states
    TYPE states IS (idle, play, collision, win);
    SIGNAL state, next_state : states;

    --clocking signals
    SIGNAL score1, score_c : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL dead1, dead_c : STD_LOGIC;

    --signals for collision check
    SIGNAL bullet_lb, bullet_rb, bullet_tb, bullet_bb : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL tank_lb, tank_rb, tank_bb, tank_tb : STD_LOGIC_VECTOR(9 DOWNTO 0);

    --constant for comparison
    CONSTANT WIN_SCORE : STD_LOGIC_VECTOR(3 DOWNTO 0) := (0 => '1', 1 => '1', OTHERS => '0');

BEGIN

    bullet_lb <= STD_LOGIC_VECTOR(unsigned(bullet_x) - 5);
    bullet_rb <= STD_LOGIC_VECTOR(unsigned(bullet_x) + 5);
    bullet_tb <= STD_LOGIC_VECTOR(unsigned(bullet_y) - 10);
    bullet_bb <= STD_LOGIC_VECTOR(unsigned(bullet_y) + 10);
    tank_lb <= STD_LOGIC_VECTOR(unsigned(tank_x) - 40);
    tank_rb <= STD_LOGIC_VECTOR(unsigned(tank_x) + 40);
    tank_tb <= STD_LOGIC_VECTOR(unsigned(tank_y) - 17);
    tank_bb <= STD_LOGIC_VECTOR(unsigned(tank_y) + 17);
    clockProcess : PROCESS (clk, rst_n) IS
    BEGIN
        IF (rst_n = '1') THEN
            state <= idle;
            dead1 <= '0';
            score1 <= (OTHERS => '0');

        ELSIF (rising_edge(clk)) THEN
            state <= next_state;
            dead1 <= dead_c;
            score1 <= score_c;
        END IF;
    END PROCESS clockProcess;

    incProcess : PROCESS (start, state, dead1, bullet_x, bullet_y, tank_x, score1, bullet_lb, bullet_rb, bullet_tb, bullet_bb, tank_lb, tank_rb, tank_bb, tank_tb) IS
    BEGIN
        next_state <= state;
        score_c <= score1;
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
                    IF (score1 = WIN_SCORE) THEN
                        next_state <= win;
                        dead_c <= '1'; --deactivate bullet
                    ELSE
                        IF (A_or_B = '0') THEN
                            IF (unsigned(bullet_tb) <= unsigned(tank_bb)) THEN
                                --check for collision (has bullet A hit tank B?)
                                IF (unsigned(bullet_lb) >= unsigned(tank_lb) AND unsigned(bullet_rb) <= unsigned(tank_rb)) THEN
                                    score_c <= STD_LOGIC_VECTOR(unsigned(score1) + 1);
                                    dead_c <= '1';
                                    next_state <= collision;
                                    -- on the right
                                ELSIF ((unsigned(bullet_lb) >= unsigned(tank_lb)) AND ((unsigned(bullet_lb) + 1) < unsigned(tank_rb))) THEN
                                    score_c <= STD_LOGIC_VECTOR(unsigned(score1) + 1);
                                    dead_c <= '1';
                                    next_state <= collision;
                                    -- on the left
                                ELSIF ((unsigned(bullet_rb) <= unsigned(tank_rb)) AND ((unsigned(bullet_rb) - 1) > unsigned(tank_lb))) THEN
                                    score_c <= STD_LOGIC_VECTOR(unsigned(score1) + 1);
                                    dead_c <= '1';
                                    next_state <= collision;

                                    --check if bullet is off screen
                                ELSIF (unsigned(bullet_tb) <= 10) THEN
                                    score_c <= score1;
                                    dead_c <= '1';
                                    next_state <= collision;
                                ELSE
                                    score_c <= score1; --score stays the same
                                    dead_c <= '0';
                                END IF;
                            END IF;
                        ELSE --check for collision (has bullet B hit tank A?)
                            IF (unsigned(bullet_bb) >= unsigned(tank_tb)) THEN
                                --check for collision (has bullet B hit tank A?)
                                IF (unsigned(bullet_lb) >= unsigned(tank_lb) AND unsigned(bullet_rb) <= unsigned(tank_rb)) THEN
                                    score_c <= STD_LOGIC_VECTOR(unsigned(score1) + 1);
                                    dead_c <= '1';
                                    next_state <= collision;
                                ELSIF ((unsigned(bullet_lb) >= unsigned(tank_lb)) AND ((unsigned(bullet_lb) + 10) <= (unsigned(tank_rb) + 9))) THEN
                                    score_c <= STD_LOGIC_VECTOR(unsigned(score1) + 1);
                                    dead_c <= '1';
                                    next_state <= collision;
                                ELSIF ((unsigned(bullet_rb) <= unsigned(tank_rb)) AND ((unsigned(bullet_rb) - 10) >= (unsigned(tank_lb) - 9))) THEN
                                    score_c <= STD_LOGIC_VECTOR(unsigned(score1) + 1);
                                    dead_c <= '1';
                                    next_state <= collision;

                                    --check if bullet is off screen
                                ELSIF (unsigned(bullet_bb) >= 470) THEN
                                    score_c <= score1;
                                    dead_c <= '1';
                                    next_state <= collision;
                                ELSE
                                    score_c <= score1; --score stays the same
                                    dead_c <= '0';
                                END IF;
                            END IF;
                        END IF;
                    end if;
                END IF;

                WHEN collision =>
                    if (A_or_B = '0') then
                        IF (unsigned(bullet_tb) >= unsigned(tank_tb)) THEN
                            next_state <= play;
                            dead_c <= '0';
                        END IF;
                    else 
                        IF (unsigned(bullet_bb) <= unsigned(tank_bb)) THEN
                            next_state <= play;
                            dead_c <= '0';
                        END IF;
                    end if;

                WHEN win =>
                    next_state <= win;
                    dead_c <= '1';

                END CASE;

        END PROCESS incProcess;

        --assign output signals
        score <= score_c;
        dead <= dead1;

    END ARCHITECTURE behavioralScore;