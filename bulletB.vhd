--This module manipulates the position of the bullets on the screen

LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

--Inputs: clock, reset, speed, direction, collision A_hit or B_hit, (x,y) of TANK
--(x,y) of both tanks

--Outputs: (x, y) aka (pixel_row, pixel_column) position of BULLET, active

--Notes:
--speed comes from keyboard input
--direction = 0 moves up, direction = 1 moves down
--collision input is either A_hit or B_hit from collision module
--active output signal indicates whether or not to draw the bullet

ENTITY bulletB IS
    PORT (
        clk, rst_n, start : IN STD_LOGIC;
        fired, dead : IN STD_LOGIC;
        tank_x, tank_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        pos_x, pos_y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END ENTITY bulletB;

ARCHITECTURE behavioral OF bulletB IS
    --initialize states
    TYPE states IS (idle, firing);
    SIGNAL state, next_state : states;

    --clocking signals for position
    SIGNAL pos_x1, pos_y1, pos_x_c, pos_y_c : STD_LOGIC_VECTOR(9 DOWNTO 0);

    --constant for position increments
    SIGNAL BULLET_SPEED : NATURAL := 10;

BEGIN
    clockProcess : PROCESS (clk, rst_n) IS
    BEGIN
        IF (rst_n = '1') THEN
            state <= idle;
            pos_x1 <= tank_x; --center based on tank position
            pos_y1 <= STD_LOGIC_VECTOR(unsigned(tank_y) + 27); -- 40 + 10 = 50 

        ELSIF (rising_edge(clk)) THEN
            state <= next_state;
            pos_x1 <= pos_x_c;
            pos_y1 <= pos_y_c;
        END IF;
    END PROCESS clockProcess;

    bulletProcess : PROCESS (start, fired, dead, tank_x, tank_y, pos_y1) IS
    BEGIN
        next_state <= state;
        pos_x_c <= pos_x1;
        pos_y_c <= pos_y1;

        CASE state IS
            WHEN idle =>
                IF (start = '1' AND fired = '1') THEN
                    next_state <= firing;
                else 
                    pos_x_c <= tank_x;
                    pos_y_c <= STD_LOGIC_VECTOR(unsigned(tank_y) + 27);
                END IF;
    

            WHEN firing =>
                IF (start = '1') THEN
                    IF (dead = '0') THEN
                        if ((unsigned(pos_y1) + BULLET_SPEED) <= 470) then
                            pos_y_c <= STD_LOGIC_VECTOR(unsigned(pos_y1) + BULLET_SPEED);
                        else 
                            next_state <= idle;
                            pos_x_c <= tank_x; --center based on tank position
                            pos_y_c <= STD_LOGIC_VECTOR(unsigned(tank_y) + 27); 
                        end if;
                    ELSIF (dead = '1') THEN
                        next_state <= idle;
                        pos_x_c <= tank_x; --center based on tank position
                        pos_y_c <= STD_LOGIC_VECTOR(unsigned(tank_y) + 27); 
                    END IF;
                END IF;
        END CASE;

    END PROCESS bulletProcess;

    --assign output signals
    pos_x <= pos_x1;
    pos_y <= pos_y1;

END ARCHITECTURE behavioral;