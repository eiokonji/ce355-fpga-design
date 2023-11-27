--This module renders the tanks on the screen via VGA (in blue and red)
LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

--inputs: clk, rst_n, center positions
--outputs: left_bound, right_bound, top_bound, bottom_bound based on top left position
--width: 80, height: 34

ENTITY tankA IS
    PORT (
        clk, rst_n, start : IN STD_LOGIC;
        speed : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        winner : IN STD_LOGIC_VECTOR(1 downto 0);
        pos_x, pos_y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END ENTITY tankA;

ARCHITECTURE behavioral_A OF tankA IS
    --initialize states
    TYPE states IS (init, idle, move, game_over);
    SIGNAL state, next_state : states;

    --signals for position
    SIGNAL pos_x1, pos_y1, pos_x_c, pos_y_c : STD_LOGIC_VECTOR(9 DOWNTO 0);

    --signal for direction (0= right, 1 = left)
    SIGNAL direction : STD_LOGIC := '0';
    SIGNAL direction_c : STD_LOGIC;

    --declare constant bounds
    CONSTANT left_bound : NATURAL := 0 + 40;
    CONSTANT right_bound : NATURAL := 640 - 40;

    --signal for speed
    -- SIGNAL tank_speed : INTEGER := 5;

BEGIN

    clockProcess : PROCESS (clk, rst_n) IS
    BEGIN
        IF (rst_n = '1') THEN
            state <= init;
            pos_x1 <= (others => '0');
            pos_y1 <= (others => '0');

        ELSIF (rising_edge(clk)) THEN
            state <= next_state;
            pos_x1 <= pos_x_c;
            pos_y1 <= pos_y_c;
            direction <= direction_c;

        END IF;
    END PROCESS clockProcess;

    --update positions
    tankProcess : PROCESS (start, state, pos_x1, pos_y1, direction, speed) IS
    BEGIN
        --assign defaults
        next_state <= state;
        pos_x_c <= pos_x1;
        pos_y_c <= pos_y1;
        direction_c <= direction;

        CASE state IS
			WHEN init =>
					pos_x_c <= STD_LOGIC_VECTOR(to_unsigned(320, 10));
					pos_y_c <= STD_LOGIC_VECTOR(to_unsigned(452, 10));
					next_state <= idle;
					
            WHEN idle =>
                IF (start = '1') THEN
                    next_state <= move;
                ELSE
                    --pos_x1 <= STD_LOGIC_VECTOR(to_unsigned(320, 10));
                    --pos_y1 <= STD_LOGIC_VECTOR(to_unsigned(452, 10));
                    next_state <= idle;
                END IF;
            WHEN move =>
                if (start = '1') then 
                    IF (direction = '0' and ) THEN
                        IF (unsigned(pos_x1) + unsigned(speed) <= right_bound) THEN
                            pos_x_c <= std_logic_vector(unsigned(pos_x1) + unsigned(speed));
                        ELSE
                            direction_c <= '1'; --if tank exceeds right bound, flip direction
                        END IF;
                    ELSIF (direction = '1') THEN
                        IF (unsigned(pos_x1) - unsigned(speed) >= left_bound) THEN
                            pos_x_c <= std_logic_vector(unsigned(pos_x1) - unsigned(speed));
                        ELSE
                            direction_c <= '0'; --if tank exceeds left bound, flip direction
                        END IF;
                    END IF;
                    if (winner not "00") then 
                        next_state <= game_over;
                    end if;
                end if;

            WHEN game_over =>
                next_state <= game_over;

        END CASE;

    END PROCESS tankProcess;

    pos_x <= pos_x1;
    pos_y <= pos_y1;

END ARCHITECTURE behavioral_A;