--This module controls the top-level VGA of the tank game
-- _C is clocked signal

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

	component clock_counter is 
	generic (
		BITS :integer := 3
	);
	port (
		clk, rst : in std_logic;
		game_tick : out std_logic
	);
	end component clock_counter;

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

	COMPONENT tankA_pos IS
    PORT (
		clk, rst : IN STD_LOGIC;
        start : IN STD_LOGIC;
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
	signal GAME_START : std_logic;
	signal GAME_DONE : std_logic;
	signal RESET_P, RESET_N : std_logic;

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
	SIGNAL A_BULLET_POS_X : STD_LOGIC_VECTOR(9 DOWNTO 0) := (8 => '1', 5 => '1', 4 => '1', 3 => '1', 1 => '1', 0 => '1',OTHERS => '0');
	SIGNAL A_BULLET_POS_Y : STD_LOGIC_VECTOR(9 DOWNTO 0) := (8 => '1', 7 => '1', 4 => '1', 3 => '1', 1 => '1', OTHERS => '0');
	SIGNAL A_BULLET_POS_X_C : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL A_BULLET_POS_Y_C : STD_LOGIC_VECTOR(9 DOWNTO 0);

	-- bullet position signals, bullet B (315, 50)
	-- (x,y) := (tank_X + 15, tank_X + 40)
	SIGNAL B_BULLET_POS_X : STD_LOGIC_VECTOR(9 DOWNTO 0) := (8 => '1', 5 => '1', 4 => '1', 3 => '1', 1 => '1', 0 => '1',OTHERS => '0');
	SIGNAL B_BULLET_POS_Y : STD_LOGIC_VECTOR(9 DOWNTO 0) := (5 => '1', 4 => '1', 1 => '1', OTHERS => '0');
	SIGNAL B_BULLET_POS_X_C : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL B_BULLET_POS_Y_C : STD_LOGIC_VECTOR(9 DOWNTO 0);

	--tank speed
	SIGNAL A_SPEED : std_logic_vector(1 downto 0) := (1 => '1', OTHERS => '0');

BEGIN

	RESET_N <= not RESET_P;

	--------------------------------------------------------------------------------------------
	clockCount : clock_counter
	generic map(
		BITS => 3
	)
	port map (
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

	tankA_Position : tankA_pos
    PORT MAP(
        clk => CLOCK_50,
		start => game_ticks, 
		rst => RESET_P, 
        speed => A_SPEED,
        pos_x => A_POS_X,
        updated_pos_x => A_POS_X_C
    );

	clocked_proc : process (CLOCK_50) is 
	begin
		A_POS_X <= A_POS_X_C;

	end process clocked_proc;

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