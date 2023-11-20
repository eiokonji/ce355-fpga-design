--This module generates the game clock counter at 50 Hz
--Positions on the screen are adjusted based on this counter

LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY clock_counter IS
    PORT (
        clk, rst_n : IN STD_LOGIC;
        game_tick : OUT STD_LOGIC
    );
END ENTITY clock_counter;

ARCHITECTURE behavioral_counter OF clock_counter IS
    SIGNAL cycle_count : INTEGER := 0;

BEGIN
    clock_process : PROCESS (clk, rst_n) IS
    BEGIN
        IF (rst_n = '1') THEN
            cycle_count <= 0;
            game_tick <= '0';
        ELSIF (rising_edge(clk)) THEN
            cycle_count <= cycle_count + 1;
            IF (cycle_count > 1000000) THEN --for 50Hz
                game_tick <= '1';
                cycle_count <= 0;
            ELSE
                game_tick
            END IF;
        END IF;

    END ARCHITECTURE behavioral_counter;