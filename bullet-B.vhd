-- Bullet rendering for Tank B
-- Should show a rectangular blue bullet

LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

--inputs: clk, rst_n, center positions
--outputs: left_bound, right_bound, top_bound, bottom_bound

ENTITY bulletB IS
	PORT (
		clk, rst_n : IN STD_LOGIC;
		pos_x, pos_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		x1, x2, y1, y2 : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END ENTITY bulletB;

ARCHITECTURE behavioral_B OF bulletB IS

	SIGNAL pos_x_int, pos_y_int : NATURAL;

BEGIN

	--------------------------------------------------------------------------------------------

    -- get integer versions of the current position (bottom left corner)
	pos_x_int <= to_integer(unsigned(pos_x));
	pos_y_int <= to_integer(unsigned(pos_y));

	--------------------------------------------------------------------------------------------	

	bulletB_tips : PROCESS (clk, rst_n) IS

	BEGIN
		-- return bounding box of the bullet
		-- width: 10, height: 20
        
		IF (rising_edge(clk)) THEN
			x1 <= std_logic_vector(to_unsigned(pos_x_int, 10));
			x2 <= std_logic_vector(to_unsigned(pos_x_int + 10, 10));
			y1 <= std_logic_vector(to_unsigned(pos_y_int, 10));
			y2 <= std_logic_vector(to_unsigned(pos_y_int + 20, 10));
		END IF;

	END PROCESS bulletB_tips;

	--------------------------------------------------------------------------------------------

END ARCHITECTURE behavioral_B;