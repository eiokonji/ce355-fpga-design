--This module manipulates the horizontal position of tank A (pixel_column_A) on the screen

LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

--inputs: clock, reset, speed, direction, (x,y) of tankA
--outputs: (x, y) aka (pixel_row, pixel_column) position of tankA
--notes:
--speed comes from keyboard input
--direction = 0 moves right, direction = 1 moves left
ENTITY tank_pos IS
    PORT (
        clk, rst, start : IN STD_LOGIC;
        speed : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        pos_x : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        updated_pos_x : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END ENTITY tank_pos;

ARCHITECTURE behavioral OF tank_pos IS
    --declarative region
    SIGNAL tank_speed : NATURAL;

    --declare signals
    CONSTANT left_bound : NATURAL := 0;
    CONSTANT right_bound : NATURAL := 640 - 80;

    SIGNAL direction : STD_LOGIC := '0';
    SIGNAL new_direction : STD_LOGIC;
    SIGNAL pos_x_int : NATURAL := to_integer(unsigned(pos_x));
    SIGNAL new_pos_x_int : NATURAL;

    CONSTANT speed1 : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    CONSTANT speed2 : STD_LOGIC_VECTOR(1 DOWNTO 0) := (0 => '1', OTHERS => '0');
    CONSTANT speed3 : STD_LOGIC_VECTOR(1 DOWNTO 0) := (1 => '1', OTHERS => '0');

    TYPE states IS (idle, move);
    SIGNAL state, new_state : states;

BEGIN
    clocked_process : PROCESS (clk, rst) IS --is this supposed to be clock or game tick?
    BEGIN
        IF (rst = '1') THEN
            --restore to defaults (x = 280, moving right)
            pos_x_int <= 280;
            direction <= '0';
            state <= idle;

        ELSIF (rising_edge(clk)) THEN
            -- report "pos_x: " & integer'image(pos_x_int);
            -- report "new_pos_x: " & integer'image(new_pos_x_int);
            pos_x_int <= new_pos_x_int;
            direction <= new_direction;
            state <= new_state;
        END IF;
    END PROCESS clocked_process;

    updateTank_process : PROCESS (start) IS --start, pos_x_int, direction, speed
    BEGIN
        --assign defaults
        new_direction <= direction;
        new_pos_x_int <= pos_x_int;
        new_state <= state;

        CASE state IS
            WHEN idle =>
                IF (start ='1') THEN
                    new_state <= move;
                END IF;
            when move =>

                REPORT "entered move state";

                --assign tank speed
                IF (speed = speed1) THEN
                    tank_speed <= 1;
                ELSIF (speed = speed2) THEN
                    tank_speed <= 5;
                ELSIF (speed = speed3) THEN
                    tank_speed <= 15;
                ELSE
                    tank_speed <= 0; --if nothing is pressed
                END IF;

                if (rising_edge(start)) then 
                    IF (direction = '0') THEN
                        REPORT "entered direction = '0'";
                        IF (pos_x_int + tank_speed <= right_bound) THEN
                            new_pos_x_int <= pos_x_int + tank_speed;
                            REPORT "new_x-pos:" & INTEGER'image(new_pos_x_int);
                        ELSE
                            new_direction <= NOT direction; --if tank exceeds right bound, flip direction
                        END IF;
                    ELSIF (direction = '1') THEN
                        REPORT "entered direction = '0'";
                        IF (pos_x_int - tank_speed >= left_bound) THEN
                            new_pos_x_int <= pos_x_int - tank_speed;
                            REPORT "new_x-pos:" & INTEGER'image(new_pos_x_int);
                        ELSE
                            new_direction <= NOT direction; --if tank exceeds left bound, flip direction
                        END IF;
                    END IF;
                else 
                    new_pos_x_int <= pos_x_int;
                end if;
        end case;

    END PROCESS updateTank_process;

    updated_pos_x <= STD_LOGIC_VECTOR(to_unsigned(pos_x_int, 10));

END ARCHITECTURE behavioral;