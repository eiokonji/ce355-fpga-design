--This module renders tank B on the screen via VGA (in red)
LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

--inputs: clk, rst_n, center positions
--outputs: left_bound, right_bound, top_bound, bottom_bound

ENTITY tankB IS
	PORT (
		clk, rst_n : IN STD_LOGIC;
		pos_x, pos_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		left_bound, right_bound, top_bound, bottom_bound : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END ENTITY tankB;

ARCHITECTURE behavioral_B OF tankB IS

	-- SIGNAL pixel_row_int, pixel_column_int : NATURAL;
	-- SIGNAL left_bound_B, right_bound_B, top_bound_B, bottom_bound_B : NATURAL;
	SIGNAL pos_x_int, pos_y_int : NATURAL;

BEGIN

	--------------------------------------------------------------------------------------------

	pos_x_int <= to_integer(unsigned(pos_x));
	pos_y_int <= to_integer(unsigned(pos_y));

	--------------------------------------------------------------------------------------------	

	tankB_Draw : PROCESS (clk, rst_n) IS

	BEGIN
		--store center position of each tank
		--return bounding box of the tank based on center position
		--width: 80, height: 34

		IF (rising_edge(clk)) THEN
			left_bound <= std_logic_vector(to_unsigned(pos_x_int, 10));
			right_bound <= std_logic_vector(to_unsigned(pos_x_int + 80, 10));
			top_bound <= std_logic_vector(to_unsigned(pos_y_int, 10));
			bottom_bound <= std_logic_vector(to_unsigned(pos_y_int + 35, 10));
		END IF;

	END PROCESS tankB_Draw;

	--------------------------------------------------------------------------------------------

END ARCHITECTURE behavioral_B;