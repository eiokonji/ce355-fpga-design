--This module manipulates the position of the bullets on the screen

LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

--inputs: clock, reset, speed, direction, collision A_hit or B_hit, (x,y) of TANK
--outputs: (x, y) aka (pixel_row, pixel_column) position of BULLET
--notes:
--speed comes from keyboard input
--direction = 0 moves up, direction = 1 moves down
--collision input is either A_hit or B_hit from collision module

ENTITY bullet_pos IS
    PORT (
        clk, rst, start : IN STD_LOGIC;
        direction, collision : IN STD_LOGIC;
        speed : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        tank_x, tank_y, bullet_x, bullet_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        updated_bullet_x, updated_bullet_y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END ENTITY bullet_pos;

ARCHITECTURE behavioral_bulletpos OF bullet_pos IS
    --initialize states
    TYPE states IS (idle, firing);
    SIGNAL state, next_state : states;

    --declare signals
    CONSTANT TOP_BOUND : NATURAL := 45; --this is the bottom of the top tank (B)
    CONSTANT BOTTOM_BOUND : NATURAL := 435; --this is the top of the bottom tank (A)

    --initialize ints for positioning
    SIGNAL bullet_x_int : NATURAL := to_integer(unsigned(pos_x));
    SIGNAL new_bullet_x_int : NATURAL;
    SIGNAL bullet_y_int : NATURAL := to_integer(unsigned(pos_x));
    SIGNAL new_bullet_y_int : NATURAL;

    --clocking signals
    SIGNAL active_c : STD_LOGIC := '0';

    --constant for speed of bullet
    CONSTANT BULLET_SPEED : NATURAL := 10;

BEGIN

    clocked_process : PROCESS (clk, rst) IS --is this supposed to be clock or game tick?
    BEGIN
        IF (rst = '1') THEN
            --restore to defaults 
            state <= idle;
            bullet_x_int <= to_integer(unsigned(tank_x)) + 40; --add 40 to left bound of tank to get center of the tank
            bullet_y_int <= to_integer(unsigned(tank_y)); --top or bottom bound of tank depending on which bullet
        ELSIF (rising_edge(clk)) THEN
            state <= new_state;
            bullet_x_int <= new_bullet_x_int;
            bullet_y_int <= new_bullet_y_int;
        END IF;
    END PROCESS clocked_process;

    update_bullet : PROCESS (start, collision) IS --start, pos_x_int, direction, speed
    BEGIN
        --assign defaults
        next_state <= state;
        new_bullet_x_int <= bullet_x_int;
        new_bullet_y_int <= bullet_y_int;

        CASE state IS
            WHEN idle =>
                IF (start = '1') THEN
                    state <= firing;
                END IF;
                --default bullet position
                new_bullet_x_int <= to_integer(unsigned(tank_x)) + 40; --add 40 to left bound of tank to get center of the tank
                new_bullet_y_int <= to_integer(unsigned(tank_y)); --top or bottom bound of tank depending on which bullet

            WHEN firing =>
                IF (collision = '1') THEN
                    --restore bullet to position based on tank
                    next_state <= idle;
                END IF;

                --check which direction the bullet is moving
                IF (direction = '0') THEN --if bullet traveling up
                    new_bullet_y_int <= bullet_y_int - BULLET_SPEED;
                ELSIF (direction = '1') THEN --if bullet traveling down
                    new_bullet_y_int <= bullet_y_int + BULLET_SPEED;
                END IF;
        END CASE;

    END PROCESS update_bullet;

    updated_bullet_x <= STD_LOGIC_VECTOR(to_unsigned(new_bullet_x_int, 10));
    updated_bullet_y <= STD_LOGIC_VECTOR(to_unsigned(new_bullet_y_int, 10));

END ARCHITECTURE behavioral_bulletpos;