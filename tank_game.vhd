--This module controls the top-level VGA of the tank game
-- _C is combinational signal

LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY tank_game IS
	PORT (
		CLOCK_50 : IN STD_LOGIC;
		RESET : IN STD_LOGIC;
		--VGA 
		VGA_RED, VGA_GREEN, VGA_BLUE : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		HORIZ_SYNC, VERT_SYNC, VGA_BLANK, VGA_CLK : OUT STD_LOGIC

	);
END ENTITY tank_game;

ARCHITECTURE structural OF tank_game IS
	SIGNAL VGA_RED_temp, VGA_GREEN_temp, VGA_BLUE_temp : STD_LOGIC_VECTOR(7 DOWNTO 0);

	COMPONENT clock_counter IS
		GENERIC (
			BITS : INTEGER := 3
		);
		PORT (
			clk, rst : IN STD_LOGIC;
			game_tick : OUT STD_LOGIC
		);
	END COMPONENT clock_counter;

	COMPONENT pixelGenerator IS
		PORT (
			clk, ROM_clk, rst_n, video_on, eof : IN STD_LOGIC;
			pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			tank_A_lb, tank_A_rb, tank_A_tb, tank_A_bb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			tank_B_lb, tank_B_rb, tank_B_tb, tank_B_bb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			bullet_A_lb, bullet_A_rb, bullet_A_tb, bullet_A_bb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			bullet_B_lb, bullet_B_rb, bullet_B_tb, bullet_B_bb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);

			red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	END COMPONENT pixelGenerator;

	COMPONENT tank IS
		PORT (
			clk, rst_n : IN STD_LOGIC;
			pos_x, pos_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			left_bound, right_bound, top_bound, bottom_bound : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
		);
	END COMPONENT tank;

	COMPONENT bullet IS
		PORT (
			clk, rst_n : IN STD_LOGIC;
			pos_x, pos_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			x1, x2, y1, y2 : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
		);
	END COMPONENT bullet;

	COMPONENT tank_pos IS
		PORT (
			clk, rst : IN STD_LOGIC;
			start : IN STD_LOGIC;
			speed : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			pos_x : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			updated_pos_x : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
		);
	END COMPONENT tank_pos;

	COMPONENT collision IS
		PORT (
			clk, rst_n : IN STD_LOGIC;
			A_tank_lb, A_tank_rb, A_tank_tb, A_tank_bb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			B_tank_lb, B_tank_rb, B_tank_tb, B_tank_bb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			A_bullet_lb, A_bullet_rb, A_bullet_tb, A_bullet_bb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			B_bullet_lb, B_bullet_rb, B_bullet_tb, B_bullet_bb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			A_hit, B_hit : OUT STD_LOGIC
		);
	END COMPONENT collision;

	COMPONENT score IS
		PORT (
			clk, rst_n, start : IN STD_LOGIC;
			A_hit, B_hit : IN STD_LOGIC;
			A_score, B_score : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			A_win, B_win : OUT STD_LOGIC
		);
	END COMPONENT score;

	COMPONENT de2lcd IS
		PORT (
			reset, clk_50Mhz : IN STD_LOGIC;
			win : IN STD_LOGIC;
			LCD_RS, LCD_E, LCD_ON, RESET_LED, SEC_LED : OUT STD_LOGIC;
			LCD_RW : BUFFER STD_LOGIC;
			DATA_BUS : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0));
	END COMPONENT de2lcd;

	COMPONENT VGA_SYNC IS
		PORT (
			clock_50Mhz : IN STD_LOGIC;
			horiz_sync_out, vert_sync_out,
			video_on, pixel_clock, eof : OUT STD_LOGIC;
			pixel_row, pixel_column : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
		);
	END COMPONENT VGA_SYNC;

	--Signals for screen position updates
	SIGNAL game_ticks : STD_LOGIC;
	SIGNAL GAME_START : STD_LOGIC;
	SIGNAL GAME_DONE : STD_LOGIC;
	SIGNAL RESET_P, RESET_N : STD_LOGIC;

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

	-- bullet positions
	SIGNAL A_X1, A_X2, A_Y1, A_Y2 : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL B_X1, B_X2, B_Y1, B_Y2 : STD_LOGIC_VECTOR(9 DOWNTO 0);

	--initial position of tank A is (280, 435)
	SIGNAL A_POS_X : STD_LOGIC_VECTOR(9 DOWNTO 0) := (3 => '1', 4 => '1', 8 => '1', OTHERS => '0');
	SIGNAL A_POS_Y : STD_LOGIC_VECTOR(9 DOWNTO 0) := (0 => '1', 1 => '1', 4 => '1', 5 => '1', 7 => '1', 8 => '1', OTHERS => '0');
	SIGNAL A_POS_X_C : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL A_POS_Y_C : STD_LOGIC_VECTOR(9 DOWNTO 0);

	--initial position of tank B is (280, 10)
	SIGNAL B_POS_X : STD_LOGIC_VECTOR(9 DOWNTO 0) := (3 => '1', 4 => '1', 8 => '1', OTHERS => '0');
	SIGNAL B_POS_Y : STD_LOGIC_VECTOR(9 DOWNTO 0) := (1 => '1', 3 => '1', OTHERS => '0');
	SIGNAL B_POS_X_C : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL B_POS_Y_C : STD_LOGIC_VECTOR(9 DOWNTO 0);

	-- bullet position signals, bullet A (315, 410)
	-- (x,y) := (tank_X + 15, tank_X - 25)
	SIGNAL A_BULLET_POS_X : STD_LOGIC_VECTOR(9 DOWNTO 0) := (8 => '1', 5 => '1', 4 => '1', 3 => '1', 1 => '1', 0 => '1', OTHERS => '0');
	SIGNAL A_BULLET_POS_Y : STD_LOGIC_VECTOR(9 DOWNTO 0) := (8 => '1', 7 => '1', 4 => '1', 3 => '1', 1 => '1', OTHERS => '0');
	SIGNAL A_BULLET_POS_X_C : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL A_BULLET_POS_Y_C : STD_LOGIC_VECTOR(9 DOWNTO 0);

	-- bullet position signals, bullet B (315, 50)
	-- (x,y) := (tank_X + 15, tank_X + 40)
	SIGNAL B_BULLET_POS_X : STD_LOGIC_VECTOR(9 DOWNTO 0) := (8 => '1', 5 => '1', 4 => '1', 3 => '1', 1 => '1', 0 => '1', OTHERS => '0');
	SIGNAL B_BULLET_POS_Y : STD_LOGIC_VECTOR(9 DOWNTO 0) := (5 => '1', 4 => '1', 1 => '1', OTHERS => '0');
	SIGNAL B_BULLET_POS_X_C : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL B_BULLET_POS_Y_C : STD_LOGIC_VECTOR(9 DOWNTO 0);

	-- player tank, score, win signals
	SIGNAL A_SPEED : STD_LOGIC_VECTOR(1 DOWNTO 0) := (1 => '1', OTHERS => '0');
	signal A_TANK_HIT, B_TANK_HIT : std_logic;
	signal A_SCORE, B_SCORE : std_logic_vector(1 downto 0) := (others => '0');
	signal A_WINS, B_WINS : std_logic;

	--LCD signals
	signal LCD_RS1, LCD_E1, LCD_ON1, RESET_LED1, SEC_LED1 : STD_LOGIC;
	signal LCD_RW1 : std_logic;
	signal DATA_BUS1 : std_logic_vector(7 downto 0);

BEGIN

	RESET_N <= NOT RESET_P;

	--------------------------------------------------------------------------------------------
	clockCount : clock_counter
	GENERIC MAP(
		BITS => 3
	)
	PORT MAP(
		clk => CLOCK_50,
		rst => RESET_P,
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

		tank_A_lb => A_LEFT_BOUND,
		tank_A_rb => A_RIGHT_BOUND,
		tank_A_tb => A_TOP_BOUND,
		tank_A_bb => A_BOTTOM_BOUND,
		tank_B_lb => B_LEFT_BOUND,
		tank_B_rb => B_RIGHT_BOUND,
		tank_B_tb => B_TOP_BOUND,
		tank_B_bb => B_BOTTOM_BOUND,
		bullet_A_lb => A_X1,
		bullet_A_rb => A_X2,
		bullet_A_tb => A_Y1,
		bullet_A_bb => A_Y2,
		bullet_B_lb => B_X1,
		bullet_B_rb => B_X2,
		bullet_B_tb => B_Y1,
		bullet_B_bb => B_Y2,
		red_out => VGA_RED,
		green_out => VGA_GREEN,
		blue_out => VGA_BLUE
	);

	tankA_Draw : tank
	PORT MAP(
		clk => game_ticks,
		rst_n => RESET_N,
		pos_x => A_POS_X,
		pos_y => A_POS_Y,
		left_bound => A_LEFT_BOUND,
		right_bound => A_RIGHT_BOUND,
		top_bound => A_TOP_BOUND,
		bottom_bound => A_BOTTOM_BOUND
	);

	tankB_Draw : tank
	PORT MAP(
		clk => game_ticks,
		rst_n => RESET_N,
		pos_x => B_POS_X,
		pos_y => B_POS_Y,
		left_bound => B_LEFT_BOUND,
		right_bound => B_RIGHT_BOUND,
		top_bound => B_TOP_BOUND,
		bottom_bound => B_BOTTOM_BOUND
	);

	bulletA_pos : bullet
	PORT MAP(
		clk => CLOCK_50,
		rst_n => RESET_N,
		pos_x => A_BULLET_POS_X,
		pos_y => A_BULLET_POS_Y,
		x1 => A_X1,
		x2 => A_X2,
		y1 => A_Y1,
		y2 => A_Y2
	);

	bulletB_pos : bullet
	PORT MAP(
		clk => CLOCK_50,
		rst_n => RESET_N,
		pos_x => B_BULLET_POS_X,
		pos_y => B_BULLET_POS_Y,
		x1 => B_X1,
		x2 => B_X2,
		y1 => B_Y1,
		y2 => B_Y2
	);

	tankA_position : tank_pos
	PORT MAP(
		clk => CLOCK_50,
		start => game_ticks,
		rst => RESET_P,
		speed => A_SPEED,
		pos_x => A_POS_X,
		updated_pos_x => A_POS_X_C
	);

	collision_check : collision
	PORT MAP(
		clk => CLOCK_50,
		rst_n => RESET_P,
		A_tank_lb => A_LEFT_BOUND,
		A_tank_rb => A_RIGHT_BOUND,
		A_tank_tb => A_RIGHT_BOUND,
		A_tank_bb => A_BOTTOM_BOUND,
		B_tank_lb => B_LEFT_BOUND,
		B_tank_rb => B_RIGHT_BOUND,
		B_tank_tb => B_TOP_BOUND,
		B_tank_bb => B_BOTTOM_BOUND,
		A_bullet_lb => A_X1,
		A_bullet_rb => A_X2,
		A_bullet_tb => A_Y1,
		A_bullet_bb => A_Y2,
		B_bullet_lb => B_X1,
		B_bullet_rb => B_X2,
		B_bullet_tb => B_Y1,
		B_bullet_bb => B_Y2,
		A_hit = > A_TANK_HIT,
		B_hit => B_TANK_HIT
	);

	scoring : score 
	PORT MAP(
		clk => CLOCK_50, 
		rst_n => RESET_P, 
		start => game_ticks,
		A_hit => A_TANK_HIT, 
		B_hit => B_TANK_HIT,
		A_score => A_SCORE, 
		B_score => B_SCORE,
		A_win => A_WINS, 
		B_win => B_WINS
	);

	LCD_display : de2lcd IS
	PORT MAP(
		reset => RESET_P, 
		clk_50Mhz => CLOCK_50,
		win => 
		LCD_RS => LCD_RS1, 
		LCD_E => LCD_E1, 
		LCD_ON => LCD_ON1, 
		RESET_LED = RESET_LED1, 
		SEC_LED => SEC_LED1,
		LCD_RW => LCD_RW1,
		DATA_BUS => DATA_BUS1
	);

	clocked_proc : PROCESS (CLOCK_50) IS
	BEGIN
		A_POS_X <= A_POS_X_C;

	END PROCESS clocked_proc;

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