--This module controls the FSM of the tank game, including the clocking and combinational processes
LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;


entity GAME_FSM is 
    PORT(
        clk, rst_n, game_tick : in std_logic
    );
end entity GAME_FSM;

architecture behavioral_fsm of GAME_FSM is 
--initialize states
type states is idle, play, game_over;
signal state, next_state : states;

begin
    clock_process : process (clk, rst_n) is 
    begin 
        --clock process
        if (rst_n = '1') then
            state <= idle;
        elsif (rising_edge(clk)) then
            state <= next_state;
            --update positions
            A_POS_X <= A_POS_X_C;
            A_POS_Y <= A_POS_Y_C;
            B_POS_X <= B_POS_X_C;
            B_POS_X <= B_POS_Y_C;
        end if;
    end process clock_process;

    comb_process : process () is 
    begin 
    next_state <= state;

        case state is 
            when idle =>
            --score = 0, wait for start button
            ;
            when play =>
            ;
            when game_over =>
            ;
        end case;
    end process comb_process;
end architecture behavioral_fsm;