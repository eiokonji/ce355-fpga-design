--This module generates the game clock counter at 50 Hz
--Positions on the screen are adjusted based on this counter

LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY clock_counter IS
    generic (
        BITS : integer := 3
    );
    PORT (
        clk, rst : IN STD_LOGIC;
        game_tick : OUT STD_LOGIC
    );
END ENTITY clock_counter;

ARCHITECTURE behavioral_counter OF clock_counter IS
    -- SIGNAL cycle_count : NATURAL := 0;
    --create vector of counter bits
    signal cycle_count : std_logic_vector(BITS-1 downto 0);
    constant ZEROS : std_logic_vector(BITS-1 downto 0) := (others => '0');

BEGIN
    clock_process : PROCESS (clk, rst) IS
    BEGIN
        IF (rst = '1') THEN
            cycle_count <= (others => '0');
            game_tick <= '0';
        ELSIF (rising_edge(clk)) THEN
            cycle_count <= std_logic_vector(unsigned(cycle_count) + to_unsigned(1, BITS));
            IF (cycle_count = ZEROS) THEN --for 50Hz, 50000000/50 = 1000000
                game_tick <= '1';
            ELSE
                game_tick <= '0';
            END IF;
        END IF;
    END PROCESS clock_process;

END ARCHITECTURE behavioral_counter;