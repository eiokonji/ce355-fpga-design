--This module manipulates the position of the bullets on the screen

LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

--Inputs: clock, reset, start (game_ticks), A (0) or B (1), fired, dead, tank (x,y)
--Outputs: (x, y) aka (pixel_row, pixel_column) position of BULLET, active

--Notes:
--direction = 0 moves up, direction = 1 moves down
--collision input is either A_hit or B_hit from collision module
--active output signal indicates whether or not to draw the bullet

ENTITY bullet IS
	PORT (
		clk, rst_n, start : IN STD_LOGIC;
		A_or_B : IN STD_LOGIC;
		fired, dead : IN STD_LOGIC;
		tank_x, tank_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		pos_x, pos_y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END ENTITY bullet;

ARCHITECTURE behavioral OF bullet IS
	--initialize states
	TYPE states IS (WAIT_ON_FIRE, idle, firing, bulletA, bulletB);
	SIGNAL state, next_state : states;

	--clocking signals for position
	SIGNAL pos_x1, pos_y1, pos_x_c, pos_y_c : STD_LOGIC_VECTOR(9 DOWNTO 0);

	--constant for position increments
	CONSTANT BULLET_SPEED : NATURAL := 10;

BEGIN
	clockProcess : PROCESS (clk, rst_n) IS
	BEGIN
		IF (rst_n = '1') THEN
			state <= WAIT_ON_FIRE;
			pos_x1 <= (OTHERS => '0');
			pos_y1 <= (OTHERS => '0');

		ELSIF (rising_edge(clk)) THEN
			state <= next_state;
			pos_x1 <= pos_x_c;
			pos_y1 <= pos_y_c;
		END IF;
	END PROCESS clockProcess;

	bulletProcess : PROCESS (start, state, fired, dead, A_or_B, tank_x, tank_y, pos_y1, pos_x1) IS
	BEGIN
		next_state <= state;
		pos_x_c <= pos_x1;
		pos_y_c <= pos_y1;

		CASE state IS
			WHEN WAIT_ON_FIRE =>
				pos_x_c <= tank_x;
				IF (A_or_B = '0') THEN
					pos_y_c <= STD_LOGIC_VECTOR(unsigned(tank_y) - 27); --Bullet A
				ELSE
					pos_y_c <= STD_LOGIC_VECTOR(unsigned(tank_y) + 27); --Bullet B
				END IF;

				IF (fired = '1') THEN
					next_state <= idle;
				END IF;

			WHEN idle =>
				IF (start = '1') THEN
					next_state <= firing;
				END IF;

			WHEN firing =>
				--if bullet A:
				IF (A_or_B = '0') THEN
					next_state <= bulletA;
					--if bullet B:
				ELSE
					next_state <= bulletB;
				END IF;

			WHEN bulletA =>
				IF ((unsigned(pos_y1) >= BULLET_SPEED)) THEN
					pos_y_c <= STD_LOGIC_VECTOR(unsigned(pos_y1) - BULLET_SPEED);
					next_state <= idle;
				ELSE
					next_state <= WAIT_ON_FIRE;
				END IF;

			WHEN bulletB =>
				IF ((unsigned(pos_y1) <= 470)) THEN
					pos_y_c <= STD_LOGIC_VECTOR(unsigned(pos_y1) + BULLET_SPEED);
					next_state <= idle;
				ELSE
					next_state <= WAIT_ON_FIRE;
				END IF;

			WHEN OTHERS =>
				next_state <= WAIT_ON_FIRE;

		END CASE;

	END PROCESS bulletProcess;

	--assign output signals
	pos_x <= pos_x1;
	pos_y <= pos_y1;

END ARCHITECTURE behavioral;