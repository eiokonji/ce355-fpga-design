--This module updates the horizontal position of the tanks, 
--flipping the direction when the tank reaches the side boundaries
LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

--inputs: clk, rst_n, start (game ticks), A (0) or B (1), speed, winner
--outputs: (x,y) of tank

--notes: 
--speed comes from keyboard input

ENTITY tank IS
    PORT (
        clk, rst_n, start : IN STD_LOGIC;
        A_or_B : IN STD_LOGIC;
        speed : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        winner : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        pos_x, pos_y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END ENTITY tank;

ARCHITECTURE behavioral OF tank IS
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

    --constants for tank assignment
    CONSTANT TANKA_POS_X : STD_LOGIC_VECTOR(9 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(320, 10));
    CONSTANT TANKA_POS_Y : STD_LOGIC_VECTOR(9 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(452, 10));
    CONSTANT TANKB_POS_X : STD_LOGIC_VECTOR(9 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(320, 10));
    CONSTANT TANKB_POS_Y : STD_LOGIC_VECTOR(9 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(27, 10));

BEGIN

    clockProcess : PROCESS (clk, rst_n) IS
    BEGIN
        IF (rst_n = '1') THEN
            state <= init;
            pos_x1 <= (OTHERS => '0');
            pos_y1 <= (OTHERS => '0');

        ELSIF (rising_edge(clk)) THEN
            state <= next_state;
            pos_x1 <= pos_x_c;
            pos_y1 <= pos_y_c;
            direction <= direction_c;

        END IF;
    END PROCESS clockProcess;

    --update positions
    tankProcess : PROCESS (start, state, winner, A_or_B, pos_x1, pos_y1, direction, speed) IS
    BEGIN
        --assign defaults
        next_state <= state;
        pos_x_c <= pos_x1;
        pos_y_c <= pos_y1;
        direction_c <= direction;

        CASE state IS
            WHEN init =>
                IF (A_or_B = '0') THEN
                    pos_x_c <= TANKA_POS_X; --Tank A default
                    pos_y_c <= TANKA_POS_Y;
                ELSE
                    pos_x_c <= TANKB_POS_X; --Tank B default
                    pos_y_c <= TANKB_POS_Y;
                END IF;
                next_state <= idle;

            WHEN idle =>
                IF (start = '1') THEN
                    next_state <= move;
                ELSE
                    next_state <= idle;
                END IF;

            WHEN move =>
                IF (start = '1') THEN
                    IF (direction = '0') THEN
                        IF (unsigned(pos_x1) + unsigned(speed) <= right_bound) THEN
                            pos_x_c <= STD_LOGIC_VECTOR(unsigned(pos_x1) + unsigned(speed));
                        ELSE
                            direction_c <= '1'; --if tank exceeds right bound, flip direction
                        END IF;
                    ELSIF (direction = '1') THEN
                        IF (unsigned(pos_x1) - unsigned(speed) >= left_bound) THEN
                            pos_x_c <= STD_LOGIC_VECTOR(unsigned(pos_x1) - unsigned(speed));
                        ELSE
                            direction_c <= '0'; --if tank exceeds left bound, flip direction
                        END IF;
                    END IF;
                    IF (winner = "01" OR winner = "10") THEN
                        next_state <= game_over;
                    END IF;
                END IF;

            WHEN game_over =>
                next_state <= game_over;

        END CASE;

    END PROCESS tankProcess;

    pos_x <= pos_x1;
    pos_y <= pos_y1;

END ARCHITECTURE behavioral;