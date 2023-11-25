--This module renders tank A on the screen via VGA (in blue)
LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

--inputs: clk, rst_n, center positions
--outputs: left_bound, right_bound, top_bound, bottom_bound

ENTITY tank IS
	PORT (
		clk, rst_n, start : IN STD_LOGIC;
		pos_x, pos_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		left_bound, right_bound, top_bound, bottom_bound : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END ENTITY tank;

ARCHITECTURE behavioral OF tank IS

	SIGNAL pos_x_int, pos_y_int : NATURAL;

	--initialize states
	TYPE states IS (idle, move);
    SIGNAL state, next_state : states;

	--clocking signals
	signal left_bound_c, right_bound_c, top_bound_c, bottom_bound_c : std_logic_vector(9 downto 0);

BEGIN

	--------------------------------------------------------------------------------------------

	pos_x_int <= to_integer(unsigned(pos_x));
	pos_y_int <= to_integer(unsigned(pos_y));

	--------------------------------------------------------------------------------------------
	clockProcess : process (clk, rst_n) IS
	begin 
		if (rst_n = '1') then 
			state <= idle;
			left_bound <= std_logic_vector(to_unsigned(280, 10));
			right_bound <= std_logic_vector(to_unsigned(360, 10));
			top_bound <= std_logic_vector(to_unsigned(435, 10));
			bottom_bound <= std_logic_vector(to_unsigned(470, 10));

		elsif (rising_edge(clk)) then
			state <= next_state;
			left_bound <= left_bound_c;
			right_bound <= right_bound_c;
			top_bound <= top_bound_c;
			bottom_bound <= bottom_bound_c;
		end if;
	end process clockProcess;

	tank_Draw : PROCESS (start, pos_x, pos_y) IS
	BEGIN
		--store center position of each tank
		--return bounding box of the tank based on center position
		--width: 80, height: 34

		--assign defaults
		next_state <= state;
		left_bound_c <= left_bound;
		right_bound_c <= right_bound;
		top_bound_c <= top_bound;
		bottom_bound_c <= bottom_bound;s


		case state is
			when idle =>
				if (start = '1') then
					next_state <= move;
				else 
					left_bound_c <= std_logic_vector(to_unsigned(280, 10));
					right_bound_c <= std_logic_vector(to_unsigned(360, 10));
					top_bound_c <= std_logic_vector(to_unsigned(435, 10));
					bottom_bound_c <= std_logic_vector(to_unsigned(470, 10));
				end if;
			when move =>
				left_bound_c <= std_logic_vector(to_unsigned(pos_x_int, 10));
				right_bound_c <= std_logic_vector(to_unsigned(pos_x_int + 80, 10));
				top_bound_c <= std_logic_vector(to_unsigned(pos_y_int, 10));
				bottom_bound_c <= std_logic_vector(to_unsigned(pos_y_int + 35, 10));
		end case;

	END PROCESS tank_Draw;

	--------------------------------------------------------------------------------------------

END ARCHITECTURE behavioral;