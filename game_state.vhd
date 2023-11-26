--This module determines the game state based on score A and score B
--and passes output signals to the display module

LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

--Outputs:
    --game_over: indicates if a player score has reached 3
    --winner" 0 = A wins, 1 = B wins

ENTITY game_state IS
    PORT (
        clk, rst_n, start : IN STD_LOGIC;
        A_score, B_score : in std_logic_vector(1 downto 0);
        game_over, winner : out std_logic
    );
END ENTITY game_state;

ARCHITECTURE behavioral of game_state is
    --initialize states
    TYPE states IS (idle, check, win);
    SIGNAL state, next_state : states;

    --signals for clocking
    signal game_over1, game_over_c : std_logic := '0';
    
    --constants
    CONSTANT WIN_SCORE : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '1');

BEGIN
    clockProcess : PROCESS (clk, rst_n) IS
    BEGIN
        IF (rst_n = '1') THEN
            state <= idle;
            game_over1 <= '0';
        ELSIF (rising_edge(clk)) THEN
            state <= next_state;
            game_over1 <= game_over_c;
        END IF;
    END PROCESS clockProcess;

    gameStateProcess : process (start) is
    BEGIN
        next_state <= state;
        game_over_c <= game_over1;

        case state is 
            when idle =>
                if (start = '1') then 
                    next_state <= check;
                    game_over_c <= '0';
                end if;

            when check =>
                if ((A_score = WIN_SCORE) or (B_score = WIN_SCORE)) then 
                    next_state <= win;
                    game_over_c <= '1';
                end if;

            when win =>
                next_state <= win;
                game_over_c <= '1';

        end case;

    end process gameStateProcess;

    --assign output signals
    game_over <= game_over1;
    if (unsigned(A_score) > unsigned(B_score)) THEN
        winner <= '0';
    else 
        winner <= '1';
    end if;

end architecture behavioral;