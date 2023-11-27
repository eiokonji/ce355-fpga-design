-- This module determines the game state based on score A and score B
-- and passes output signals to the display module.

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

-- Outputs:
-- game_over: indicates if a player score has reached 3
--          : 0 = no winner, 1 = a winner
-- winner: indicates which player is the winner
--       : 0 = A wins, 1 = B wins
-- score led

ENTITY game_state IS
    PORT (
        clk, rst_n, start : IN STD_LOGIC;
        A_score, B_score : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        game_over : OUT STD_LOGIC;
        winner : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
    );
END ENTITY game_state;

ARCHITECTURE behavioral OF game_state IS
    -- initialize states
    TYPE states IS (idle, check, win);
    SIGNAL state, next_state : states;

    -- signals for clocking
    SIGNAL game_over1, game_over_c : STD_LOGIC := '0';
    SIGNAL winner1, winner_c : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";

    -- constants
    CONSTANT WIN_SCORE : STD_LOGIC_VECTOR(3 DOWNTO 0) := (3 => '0', 2 => '0', OTHERS => '1');

BEGIN
    clockProcess : PROCESS (clk, rst_n) IS
    BEGIN
        IF (rst_n = '1') THEN
            state <= idle;
            game_over1 <= '0';
            winner1 <= "00";
        ELSIF (rising_edge(clk)) THEN
            state <= next_state;
            game_over1 <= game_over_c;
            winner1 <= winner_c;
        END IF;
    END PROCESS clockProcess;

    gameStateProcess : PROCESS (start, state, A_score, B_score, game_over1, winner1) IS
    BEGIN
        -- defaults for combinational signals
        next_state <= state;
        game_over_c <= game_over1;
        winner_c <= winner1;

        CASE state IS
            WHEN idle =>
                IF (start = '1') THEN
                    next_state <= check;
                    game_over_c <= '0';
                    winner_c <= "00";
                END IF;

            WHEN check =>
                IF (start = '1') THEN
                    IF ((A_score = WIN_SCORE) OR (B_score = WIN_SCORE)) THEN
                        next_state <= win;
                        game_over_c <= '1';
                        IF (unsigned(A_score) > unsigned(B_score)) THEN
                            winner_c <= "01";
                        ELSIF (unsigned(B_score) > unsigned(A_score)) THEN
                            winner_c <= "10";
                        ELSE
                            winner_c <= "00";
                        END IF;
                    ELSE
                        next_state <= check;
                        game_over_c <= '0';
                        winner_c <= winner1;
                    END IF;
                END IF;

            WHEN win =>
                IF (start = '1') THEN
                    next_state <= win;
                    game_over_c <= '1';
                END IF;
        END CASE;

    END PROCESS gameStateProcess;

    --assign output signals
    game_over <= game_over1;
    winner <= winner1;
END ARCHITECTURE behavioral;