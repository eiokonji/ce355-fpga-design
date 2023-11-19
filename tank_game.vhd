LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;

ENTITY tank_game IS
	PORT (
		CLOCK_50 : IN STD_LOGIC;
		RESET_N : IN STD_LOGIC;

		--VGA 
		VGA_RED, VGA_GREEN, VGA_BLUE : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		HORIZ_SYNC, VERT_SYNC, VGA_BLANK, VGA_CLK : OUT STD_LOGIC

	);
END ENTITY tank_game;


ARCHITECTURE structural OF tank_game IS
	signal VGA_RED_temp, VGA_GREEN_temp, VGA_BLUE_temp : std_logic_vector(7 downto 0);

	-- component pixelGenerator is
	-- 	port(
	-- 			clk, ROM_clk, rst_n, video_on, eof 				: in std_logic;
	-- 			pixel_row, pixel_column						    : in std_logic_vector(9 downto 0);
	-- 			red_out, green_out, blue_out					: out std_logic_vector(7 downto 0)
	-- 		);
	-- end component pixelGenerator;

	COMPONENT tankA IS
		PORT (
			clk, ROM_clk, rst_n, video_on, eof : IN STD_LOGIC;
			pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	END COMPONENT tankA;

	-- COMPONENT tankB IS
	-- 	PORT (
	-- 		clk, ROM_clk, rst_n, video_on, eof : IN STD_LOGIC;
	-- 		pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	-- 		red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	-- 	);
	-- END COMPONENT tankB;

	COMPONENT VGA_SYNC IS
		PORT (
			clock_50Mhz : IN STD_LOGIC;
			horiz_sync_out, vert_sync_out,
			video_on, pixel_clock, eof : OUT STD_LOGIC;
			pixel_row, pixel_column : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
		);
	END COMPONENT VGA_SYNC;

	--Signals for VGA sync
	SIGNAL pixel_row_int : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL pixel_column_int : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL video_on_int : STD_LOGIC;
	SIGNAL VGA_clk_int : STD_LOGIC;
	SIGNAL eof : STD_LOGIC;

BEGIN

	--------------------------------------------------------------------------------------------

	-- videoGen : pixelGenerator
	-- PORT MAP(CLOCK_50, VGA_clk_int, RESET_N, video_on_int, eof, pixel_row_int, pixel_column_int, VGA_RED, VGA_GREEN, VGA_BLUE);

	tankA_Gen : tankA
	PORT MAP(
		CLOCK_50,
		VGA_clk_int,
		RESET_N,
		video_on_int,
		eof,
		pixel_row_int,
		pixel_column_int,
		VGA_RED_temp,
		VGA_GREEN_temp,
		VGA_BLUE_temp
	);
	-- tankB_Gen : tankB
	-- PORT MAP(
	-- 	CLOCK_50,
	-- 	VGA_clk_int,
	-- 	RESET_N,
	-- 	video_on_int,
	-- 	eof,
	-- 	pixel_row_int,
	-- 	pixel_column_int,
	-- 	VGA_RED_temp,
	-- 	VGA_GREEN_temp,
	-- 	VGA_BLUE_temp
	-- );

	VGA_RED <= VGA_RED_temp;
	VGA_BLUE <= VGA_BLUE_temp;
	VGA_GREEN <= VGA_GREEN_temp;
	--------------------------------------------------------------------------------------------
	--This section should not be modified in your design.  This section handles the VGA timing signals
	--and outputs the current row and column.  You will need to redesign the pixelGenerator to choose
	--the color value to output based on the current position.

	videoSync : VGA_SYNC
	PORT MAP(CLOCK_50, HORIZ_SYNC, VERT_SYNC, video_on_int, VGA_clk_int, eof, pixel_row_int, pixel_column_int);

	VGA_BLANK <= video_on_int;

	VGA_CLK <= VGA_clk_int;

	--------------------------------------------------------------------------------------------	

END ARCHITECTURE structural;