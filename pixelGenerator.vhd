LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY pixelGenerator IS
	PORT (
		clk, ROM_clk, rst_n, video_on, eof : IN STD_LOGIC;
		pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		tankA_x, tankA_y, tankB_x, tankB_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		-- bulletA_x, bulletA_y, bulletB_x, bulletB_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END ENTITY pixelGenerator;

ARCHITECTURE behavioral OF pixelGenerator IS

	CONSTANT color_red : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
	CONSTANT color_green : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001";
	CONSTANT color_blue : STD_LOGIC_VECTOR(2 DOWNTO 0) := "010";
	CONSTANT color_yellow : STD_LOGIC_VECTOR(2 DOWNTO 0) := "011";
	CONSTANT color_magenta : STD_LOGIC_VECTOR(2 DOWNTO 0) := "100";
	CONSTANT color_cyan : STD_LOGIC_VECTOR(2 DOWNTO 0) := "101";
	CONSTANT color_black : STD_LOGIC_VECTOR(2 DOWNTO 0) := "110";
	CONSTANT color_white : STD_LOGIC_VECTOR(2 DOWNTO 0) := "111";

	COMPONENT colorROM IS
		PORT (
			address : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			clock : IN STD_LOGIC := '1';
			q : OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
		);
	END COMPONENT colorROM;

	SIGNAL colorAddress : STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL color : STD_LOGIC_VECTOR (23 DOWNTO 0);

	SIGNAL pixel_row_int, pixel_column_int : NATURAL;

	SIGNAL tank_A_lbound, tank_A_rbound, tank_A_tbound, tank_A_bbound : NATURAL;
	SIGNAL tank_B_lbound, tank_B_rbound, tank_B_tbound, tank_B_bbound : NATURAL;
	-- SIGNAL bullet_A_lbound, bullet_A_rbound, bullet_A_tbound, bullet_A_bbound : NATURAL;
	-- SIGNAL bullet_B_lbound, bullet_B_rbound, bullet_B_tbound, bullet_B_bbound : NATURAL;

BEGIN

	--------------------------------------------------------------------------------------------

	red_out <= color(23 DOWNTO 16);
	green_out <= color(15 DOWNTO 8);
	blue_out <= color(7 DOWNTO 0);

	pixel_row_int <= to_integer(unsigned(pixel_row));
	pixel_column_int <= to_integer(unsigned(pixel_column));

	--------------------------------------------------------------------------------------------	

	colors : colorROM
	PORT MAP(colorAddress, ROM_clk, color);

	--------------------------------------------------------------------------------------------	
	findBounds : PROCESS (clk, rst_n) IS
	BEGIN
		tank_A_lbound <= to_integer(unsigned(tankA_x) - 40);
		tank_A_rbound <= to_integer(unsigned(tankA_x) + 40);
		tank_A_tbound <= to_integer(unsigned(tankA_y) - 17);
		tank_A_bbound <= to_integer(unsigned(tankA_y) + 17);
		tank_B_lbound <= to_integer(unsigned(tankB_x) - 40);
		tank_B_rbound <= to_integer(unsigned(tankB_x) + 40);
		tank_B_tbound <= to_integer(unsigned(tankB_y) - 17);
		tank_B_bbound <= to_integer(unsigned(tankB_y) + 17);
		
	END PROCESS findBounds;

	pixelDraw : PROCESS (clk, rst_n) IS

	BEGIN

		IF (rising_edge(clk)) THEN
			IF (pixel_row_int >= tank_A_tbound AND pixel_row_int < tank_A_bbound AND pixel_column_int >= tank_A_lbound AND pixel_column_int < tank_A_rbound) THEN
				colorAddress <= color_blue;

			ELSIF (pixel_row_int >= tank_B_tbound AND pixel_row_int < tank_B_bbound AND pixel_column_int >= tank_B_lbound AND pixel_column_int < tank_B_rbound) THEN
				colorAddress <= color_red;

			-- ELSIF (pixel_row_int >= bullet_A_tbound AND pixel_row_int < bullet_A_bbound AND pixel_column_int >= bullet_A_lbound AND pixel_column_int < bullet_A_rbound) THEN
			-- 	colorAddress <= color_blue;

			-- ELSIF (pixel_row_int >= bullet_B_tbound AND pixel_row_int < bullet_B_bbound AND pixel_column_int >= bullet_B_lbound AND pixel_column_int < bullet_B_rbound) THEN
			-- 	colorAddress <= color_red;

			ELSE
				colorAddress <= color_black;

			END IF;
		END IF;

	END PROCESS pixelDraw;

	--------------------------------------------------------------------------------------------

END ARCHITECTURE behavioral;