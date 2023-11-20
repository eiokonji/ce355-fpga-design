--This module controls the top-level VGA of the tank game
LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;


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
	SIGNAL VGA_RED_temp, VGA_GREEN_temp, VGA_BLUE_temp : STD_LOGIC_VECTOR(7 DOWNTO 0);

	component clock_counter is 
	port (
		clk, rst_n : in std_logic;
		game_tick : out std_logic
	);
	end component clock_counter;

	COMPONENT pixelGenerator IS
		PORT (
			clk, ROM_clk, rst_n, video_on, eof : IN STD_LOGIC;
			pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			A_lb, A_rb, A_tb, A_bb          : in std_logic_vector(9 downto 0);
			B_lb, B_rb, B_tb, B_bb          : in std_logic_vector(9 downto 0);
			red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	END COMPONENT pixelGenerator;

	COMPONENT tankA IS
		PORT (
			clk, rst_n : IN STD_LOGIC;
			pos_x, pos_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			left_bound, right_bound, top_bound, bottom_bound : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
		);
	END COMPONENT tankA;

	COMPONENT tankB IS
		PORT (
			clk, rst_n : IN STD_LOGIC;
			pos_x, pos_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			left_bound, right_bound, top_bound, bottom_bound : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
		);
	END COMPONENT tankB;

	COMPONENT tankA_pos IS
    PORT (
        clk, rst_n, direction : IN STD_LOGIC;
        speed : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        pos_x : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        updated_pos_x : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
	END COMPONENT tankA_pos;

	COMPONENT VGA_SYNC IS
		PORT (
			clock_50Mhz : IN STD_LOGIC;
			horiz_sync_out, vert_sync_out,
			video_on, pixel_clock, eof : OUT STD_LOGIC;
			pixel_row, pixel_column : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
		);
	END COMPONENT VGA_SYNC;

	--Signals for screen position updates
	signal game_ticks : std_logic;

	--Signals for VGA sync
	SIGNAL pixel_row_int : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL pixel_column_int : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL video_on_int : STD_LOGIC;
	SIGNAL VGA_clk_int : STD_LOGIC;
	SIGNAL eof : STD_LOGIC;

	--tank positions
	SIGNAL A_LEFT_BOUND : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL A_RIGHT_BOUND : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL A_TOP_BOUND : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL A_BOTTOM_BOUND : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL B_LEFT_BOUND : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL B_RIGHT_BOUND : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL B_TOP_BOUND : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL B_BOTTOM_BOUND : STD_LOGIC_VECTOR(9 DOWNTO 0);

	--initial position of tank A is (435,280)
	SIGNAL A_POS_X : STD_LOGIC_VECTOR(9 DOWNTO 0) := (3 => '1', 4 => '1', 8 => '1', OTHERS => '0');
	SIGNAL A_POS_Y : STD_LOGIC_VECTOR(9 DOWNTO 0) := (0 => '1', 1 => '1', 4 => '1', 5 => '1', 7 => '1', 8 => '1', OTHERS => '0');
	SIGNAL A_POS_X_C : STD_LOGIC_VECTOR(9 downto 0);
	SIGNAL A_POS_Y_C : STD_LOGIC_VECTOR(9 downto 0);
	--initial position of tank B is (10,280)
	SIGNAL B_POS_X : STD_LOGIC_VECTOR(9 DOWNTO 0) := (3 => '1', 4 => '1', 8 => '1', OTHERS => '0');
	SIGNAL B_POS_Y : STD_LOGIC_VECTOR(9 DOWNTO 0) := (1 => '1', 3 => '1', OTHERS => '0');
	SIGNAL B_POS_X_C : STD_LOGIC_VECTOR(9 downto 0);
	SIGNAL B_POS_Y_C : STD_LOGIC_VECTOR(9 downto 0);

BEGIN

	--------------------------------------------------------------------------------------------
	clockCount : clock_counter
	port map (
		clk => CLOCK_50, 
		rst_n => RESET_N,
        game_tick => game_ticks
	);

	videoGen : pixelGenerator
	PORT MAP(
		clk => CLOCK_50,
		ROM_clk => VGA_clk_int,
		rst_n => RESET_N,
		video_on => video_on_int,
		eof => eof,
		pixel_row => pixel_row_int,
		pixel_column => pixel_column_int,
		A_lb => A_LEFT_BOUND, 
		A_rb => A_RIGHT_BOUND, 
		A_tb => A_TOP_BOUND, 
		A_bb => A_BOTTOM_BOUND, 
		B_lb => B_LEFT_BOUND, 
		B_rb => B_RIGHT_BOUND, 
		B_tb => B_TOP_BOUND, 
		B_bb => B_BOTTOM_BOUND,          
		red_out => VGA_RED,
		green_out => VGA_GREEN,
		blue_out => VGA_BLUE
	);

	tankA_Draw : tankA
	PORT MAP(
		clk => CLOCK_50,
		rst_n => RESET_N,
		pos_x => A_POS_X,
		pos_y => A_POS_Y,
		left_bound => A_LEFT_BOUND,
		right_bound => A_RIGHT_BOUND,
		top_bound => A_TOP_BOUND,
		bottom_bound => A_BOTTOM_BOUND
	);	

	tankB_Draw : tankB
	PORT MAP(
		clk => CLOCK_50,
		rst_n => RESET_N,
		pos_x => B_POS_X,
		pos_y => B_POS_Y,
		left_bound => B_LEFT_BOUND,
		right_bound => B_RIGHT_BOUND,
		top_bound => B_TOP_BOUND,
		bottom_bound => B_BOTTOM_BOUND
	);
	
	tankA_Position : tankA_pos
    PORT MAP(
        clk => game_ticks, 
		rst_n => RESET_N, 
		direction => A_DIRECTION,
        speed => A_SPEED,
        pos_x => A_POS_X,
        updated_pos_x => A_POS_X_C
    );

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