--This module manipulates the horizontal position of tank A (pixel_column_A) on the screen

LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

--inputs: clock, reset, speed, direction, (x,y) of tankA
--outputs: (x, y) aka (pixel_row, pixel_column) position of tankA
--notes:
--speed comes from keyboard input
--direction = 0 moves right, direction = 1 moves left
ENTITY tankA_pos IS
    PORT (
        clk, rst_n, direction : IN STD_LOGIC;
        speed : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        pos_x : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        updated_pos_x : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END ENTITY tankA_pos;

--declare signals
SIGNAL pox_x_int : NATURAL;
SIGNAL left_bound : NATURAL := 0;
SIGNAL right_bound : NATURAL := 640-80;

CONSTANT speed1 : STD_LOGIC_VECTOR := (OTHERS => '0');
CONSTANT speed2 : STD_LOGIC_VECTOR := (0 => '1', OTHERS => '0');
CONSTANT speed3 : STD_LOGIC_VECTOR := (1 => '1', OTHERS => '0');

ARCHITECTURE behavioral OF tankA_pos IS
    --declarative region
    SIGNAL tank_speed : NATURAL;

BEGIN
    pox_x_int <= to_integer(unsigned(pos_x));

    IF (speed = speed1) THEN
        tank_speed <= 5;
    ELSIF (speed = speed2) THEN
        tank_speed <= 10;
    ELSIF (speed = speed3) THEN
        tank_speed <= 30;
    ELSE
        tank_speed <= 0; --if nothing is pressed
    END IF;

    tankA_pos : PROCESS (clk, rst_n) IS
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (direction = '0') THEN
                IF (pox_x_int + tank_speed <= right_bound) THEN
                    pox_x_int <= pox_x_int + tank_speed;
                ELSE
                    direction <= NOT direction; --if tank exceeds right bound, flip direction
                END IF;
            ELSIF (direction = '1') THEN
                IF (pox_x_int - tank_speed >= left_bound) THEN
                    pox_x_int <= pox_x_int - tank_speed;
                ELSE
                    directon <= NOT direction; --if tank exceeds left bound, flip direction
                END IF;
            END IF;
        END IF;

    END PROCESS tankA_pos;

    updated_pos_x <= STD_LOGIC_VECTOR(to_unsigned(pos_x_int,10));

END ARCHITECTURE behavioral;