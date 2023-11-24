--This module takes signals from the collision module and updates scoring for each player according.
--Outputs signals that are passed to the LEDs (score) and LCD (win message)

LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY score IS
    PORT (
        clk, rst_n, start: IN STD_LOGIC;
        A_hit, B_hit : in std_logic;
        A_score, B_score: out std_logic_vector(1 downto 0);
        A_win, B_win : OUT STD_LOGIC
    );
END ENTITY score;

architecture behavioral_scoring of score is
--initialize states
type states is (idle, play, win);
signal state, next_state : states;

--signals for score
constant WIN_SCORE : std_logic_vector(1 downto 0) : (others => '1');
signal A_score_temp, B_score_temp : std_logic_vector(1 downto 0) := (others => '0');
signal A_win_c, B_win_c : std_logic := '0';

begin
    clock_process : process (clk, rst_n) is 
        if (rst_n = '1') THEN
            A_score <= (others => '0');
            B_score <= (others => '0');
            A_win <= '0';
            B_win <= '0';
            state <= idle; 
        elsif (rising_edge(clk)) then 
            state <= next_state;
            A_win <= A_win_c;
            B_win <= B_win_c;
        end if;
    end process clock_process;

    comb_process : process (start, A_hit, B_hit) is
        next_state <= state;
        A_win_c <= A_win;
        B_win_c <= B_win;

        case state is
            when idle =>
                if (start = '1') then 
                    state <= play;
                end if;
            
            when play =>
                --increment score based on collision
                if (A_hit = '1') then 
                    B_score_temp <= (B_score_temp + 1);
                end if;
                if (B_hit = '1') then
                    A_score_temp <= (A_score_temp + 1);
                end if;

                --check if either player has reached score = 3
                if (A_score_temp >= unsigned(WIN_SCORE) or B_score_temp >= unsigned(WIN_SCORE)) then   
                    next_state <= win;
                end if;

            when win =>
                if (A_score_temp >= unsigned(WIN_SCORE)) then 
                    A_win_c <= '1';
                    B_win_c <= '0';
                else 
                    A_win_c <= '0';
                    B_win_c <= '1';
                end if;

        end case;

        A_score <= std_logic_vector(A_score_temp);
        B_score <= std_logic_vector(B_score_temp);
        
    end process comb_process;

end architecture behavioral_scoring;