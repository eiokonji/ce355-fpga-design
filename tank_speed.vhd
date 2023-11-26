-- This module returns the new speed based on the key pressed.

LIBRARY STD;
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tank_speed IS
    PORT (
        clock_50MHz, reset, start : IN STD_LOGIC;
        hist1, hist0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        speedA, speedB : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
    );
END ENTITY tank_speed;

ARCHITECTURE behavioral OF tank_speed IS

    TYPE states IS (idle, change_speed);
    SIGNAL state, new_state : states;

    SIGNAL speedA_temp, speedB_temp : STD_LOGIC_VECTOR (1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL speedA_temp_n, speedB_temp_n : STD_LOGIC_VECTOR (1 DOWNTO 0) := (OTHERS => '0');

    CONSTANT a : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00011100"; -- 0x1C, 28
    CONSTANT s : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00011011"; -- 0x1B, 27
    CONSTANT d : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00100011"; -- 0x23, 35
    CONSTANT j : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00111011"; -- 0x3B, 59
    CONSTANT k : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000010"; -- 0X42, 66
    CONSTANT l : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01001011"; -- 0x4B, 75
    CONSTANT break : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11110000"; -- 0xF0, 240

BEGIN

    clocked_process : PROCESS (clock_50MHz, reset) IS
    BEGIN
        IF (reset = '1') THEN
            state <= idle;
            speedA_temp <= "00";
            speedB_temp <= "00";

        ELSIF (rising_edge(clock_50MHz)) THEN
            state <= new_state;
            speedA_temp <= speedA_temp_n;
            speedB_temp <= speedB_temp_n;

        END IF;
    END PROCESS clocked_process;

    change_speed_process : PROCESS (start, hist0, hist1) IS
    BEGIN
        -- default values for changing signals
        new_state <= state;
        speedA_temp_n <= speedA_temp;
        speedB_temp_n <= speedB_temp;

        CASE state IS
            WHEN idle =>
                IF (start = '1') THEN
                    new_state <= change_speed;
                ELSE
                    new_state <= idle;
                END IF;

            WHEN change_speed =>
                IF (unsigned(hist0) = unsigned(a) AND unsigned(hist1) = unsigned(break)) THEN
                    speedA_temp_n <= "00";
                ELSIF (unsigned(hist0) = unsigned(s) AND unsigned(hist1) = unsigned(break)) THEN
                    speedA_temp_n <= "01";
                ELSIF (unsigned(hist0) = unsigned(d) AND unsigned(hist1) = unsigned(break)) THEN
                    speedA_temp_n <= "10";
                ELSE
                    speedA_temp_n <= "11";
                END IF;

                IF (unsigned(hist0) = unsigned(j) AND unsigned(hist1) = unsigned(break)) THEN
                    speedB_temp_n <= "00";
                ELSIF (unsigned(hist0) = unsigned(k) AND unsigned(hist1) = unsigned(break)) THEN
                    speedB_temp_n <= "01";
                ELSIF (unsigned(hist0) = unsigned(l) AND unsigned(hist1) = unsigned(break)) THEN
                    speedB_temp_n <= "10";
                ELSE
                    speedB_temp_n <= "11";
                END IF;
        END CASE;
    END PROCESS change_speed_process;

    speedA <= speedA_temp;
    speedB <= speedB_temp;
END ARCHITECTURE behavioral;