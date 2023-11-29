--This module controls the top-level VGA of the tank game
-- _C is combinational signal

LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY top_level IS
    PORT (
        CLOCK_50 : IN STD_LOGIC;
        RESET : IN STD_LOGIC;
        -- KEYBOARD
        KEYBOARD_CLK, KEYBOARD_DATA : IN STD_LOGIC;
        --VGA 
        VGA_RED, VGA_GREEN, VGA_BLUE : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        HORIZ_SYNC, VERT_SYNC, VGA_BLANK, VGA_CLK : OUT STD_LOGIC;
        -- LCD
        LCD_RS, LCD_E, LCD_ON, RESET_LED, SEC_LED : OUT STD_LOGIC;
        LCD_RW : BUFFER STD_LOGIC;
        DATA_BUS : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        SHOW_A_SCORE : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        SHOW_B_SCORE : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END ENTITY top_level;

ARCHITECTURE structural OF top_level IS
    SIGNAL VGA_RED_temp, VGA_GREEN_temp, VGA_BLUE_temp : STD_LOGIC_VECTOR(7 DOWNTO 0);
	 SIGNAl clk : std_logic;
	 
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
            tankA_x, tankA_y, tankB_x, tankB_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            bulletA_x, bulletA_y, bulletB_x, bulletB_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            winner : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT pixelGenerator;

    COMPONENT tank IS
        PORT (
            clk, rst_n, start : IN STD_LOGIC;
            A_or_B : IN STD_LOGIC;
            speed : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            winner : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            pos_x, pos_y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    END COMPONENT tank;

    COMPONENT bullet IS
        PORT (
            clk, rst_n, start : IN STD_LOGIC;
            A_or_B : IN STD_LOGIC;
            fired, dead : IN STD_LOGIC;
            tank_x, tank_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            pos_x, pos_y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    END COMPONENT bullet;

    COMPONENT inc_score IS
        PORT (
            clk, rst_n, start : IN STD_LOGIC;
            A_or_B : IN STD_LOGIC;
            bullet_x, bullet_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            tank_x, tank_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            score : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            dead : OUT STD_LOGIC
        );
    END COMPONENT inc_score;

    COMPONENT game_state IS
        PORT (
            clk, rst_n, start : IN STD_LOGIC;
            A_score, B_score : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            game_over : OUT STD_LOGIC;
            winner : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
        );
    END COMPONENT game_state;

    COMPONENT VGA_SYNC IS
        PORT (
            clock_50Mhz : IN STD_LOGIC;
            horiz_sync_out, vert_sync_out,
            video_on, pixel_clock, eof : OUT STD_LOGIC;
            pixel_row, pixel_column : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    END COMPONENT VGA_SYNC;

    COMPONENT ps2 IS
        PORT (
            keyboard_clk, keyboard_data, clock_50MHz,
            reset : IN STD_LOGIC;--, read : in std_logic;
            scan_readyo : OUT STD_LOGIC;
            hist3 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            hist2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            hist1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            hist0 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT ps2;

    COMPONENT keypresses IS
        PORT (
            clock_50MHz, reset, start : IN STD_LOGIC;
            hist2, hist1, hist0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            speedA, speedB : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            bulletA, bulletB : OUT STD_LOGIC
        );
    END COMPONENT keypresses;

    COMPONENT de2lcd IS
        PORT (
            reset, clk_50Mhz : IN STD_LOGIC;
            winner : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            LCD_RS, LCD_E, LCD_ON, RESET_LED, SEC_LED : OUT STD_LOGIC;
            LCD_RW : BUFFER STD_LOGIC;
            DATA_BUS : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0));
    END COMPONENT de2lcd;

    COMPONENT leddcd IS
        PORT (
            data_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            segments_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT leddcd;

	COMPONENT pll IS
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC 
	);
	END COMPONENT pll;
	
    --Signals for screen position updates
    SIGNAL game_ticks : STD_LOGIC;
    SIGNAL RESET_N : STD_LOGIC;

    --Signals for VGA sync
    SIGNAL pixel_row_int : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL pixel_column_int : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL video_on_int : STD_LOGIC;
    SIGNAL VGA_clk_int : STD_LOGIC;
    SIGNAL eof : STD_LOGIC;

    --constants for selection between A and B
    CONSTANT A : std_logic := '0';
    CONSTANT B : std_logic := '1';

    --signals for tank and bullet positions
    SIGNAL TANKA_X, TANKA_Y, TANKB_X, TANKB_Y : STD_LOGIC_VECTOR(9 DOWNTO 0);

    --signals for tank speed
    SIGNAL TANKA_SPEED, TANKB_SPEED : STD_LOGIC_VECTOR(3 DOWNTO 0) := (0 => '1', OTHERS => '0');

    -- signals for bullet positions
    SIGNAL BULLETA_X, BULLETA_Y, BULLETB_X, BULLETB_Y : STD_LOGIC_VECTOR(9 DOWNTO 0);

    -- signals for bullet fired and dead
    SIGNAL BULLETA_FIRED, BULLETB_FIRED : STD_LOGIC;
    SIGNAL A_DEAD, B_DEAD : STD_LOGIC;

    --signals for scoring
    SIGNAL A_SCORE, B_SCORE : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL WINNER : STD_LOGIC_VECTOR(1 DOWNTO 0);

    -- signals for ps2
    SIGNAL scan_ready : STD_LOGIC;
    SIGNAL hist2, hist1, hist0 : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
    RESET_N <= NOT RESET; -- if reset is 1, because RESET is '0'

	 
	 pll_inst : pll 
	 PORT MAP (
		areset => RESET_N,
		inclk0 => CLOCK_50,
		c0	=> clk
	 );
	 
    --------------------------------------------------------------------------------------------
    clockCount : clock_counter
    GENERIC MAP(
        BITS => 20
    )
    PORT MAP(
        clk => clk,
        rst => RESET_N,
        game_tick => game_ticks
    );

    videoGen : pixelGenerator
    PORT MAP(
        clk => clk,
        ROM_clk => VGA_clk_int,
        rst_n => RESET_N,
        video_on => video_on_int,
        eof => eof,
        pixel_row => pixel_row_int,
        pixel_column => pixel_column_int,

        tankA_x => TANKA_X,
        tankA_y => TANKA_Y,
        tankB_x => TANKB_X,
        tankB_y => TANKB_Y,
        bulletA_x => BULLETA_X,
        bulletA_y => BULLETA_Y,
        bulletB_x => BULLETB_X,
        bulletB_y => BULLETB_Y,

        winner => WINNER,

        red_out => VGA_RED,
        green_out => VGA_GREEN,
        blue_out => VGA_BLUE
    );

    tankAModule : tank
    PORT MAP(
        clk => clk,
        rst_n => RESET_N,
        start => game_ticks,
        A_or_B => A,
        winner => WINNER,
        speed => TANKA_SPEED,
        pos_x => TANKA_X,
        pos_y => TANKA_Y
    );

    tankBModule : tank
    PORT MAP(
        clk => clk,
        rst_n => RESET_N,
        start => game_ticks,
        A_or_B => B,
        winner => WINNER,
        speed => TANKB_SPEED,
        pos_x => TANKB_X,
        pos_y => TANKB_Y
    );

    bulletAModule : bullet
    PORT MAP(
        clk => clk,
        start => game_ticks,
        rst_n => RESET_N,
        A_or_B => A,
        fired => BULLETA_FIRED,
        dead => A_DEAD,
        tank_x => TANKA_X,
        tank_y => TANKA_Y,
        pos_x => BULLETA_X,
        pos_y => BULLETA_Y
    );

    bulletBModule : bullet
    PORT MAP(
        clk => clk,
        start => game_ticks,
        rst_n => RESET_N,
        A_or_B => B,
        fired => BULLETB_FIRED,
        dead => B_DEAD,
        tank_x => TANKB_X,
        tank_y => TANKB_Y,
        pos_x => BULLETB_X,
        pos_y => BULLETB_Y
    );

    scoreA : inc_score
    PORT MAP(
        clk => clk,
        start => game_ticks,
        rst_n => RESET_N,
        A_or_B => A,
        bullet_x => BULLETA_X,
        bullet_y => BULLETA_Y,
        tank_x => TANKB_X,
        tank_y => TANKB_Y,
        score => A_SCORE,
        dead => A_DEAD
    );

    scoreB : inc_score
    PORT MAP(
        clk => clk,
        start => game_ticks,
        rst_n => RESET_N,
        A_or_B => B,
        bullet_x => BULLETB_X,
        bullet_y => BULLETB_Y,
        tank_x => TANKA_X,
        tank_y => TANKA_Y,
        score => B_SCORE,
        dead => B_DEAD
    );

    gameState : game_state
    PORT MAP(
        clk => clk,
        start => game_ticks,
        rst_n => RESET_N,
        A_score => A_SCORE,
        B_score => B_SCORE,
        winner => WINNER
    );

    ps2_1 : ps2
    PORT MAP(
        keyboard_clk => KEYBOARD_CLK,
        keyboard_data => KEYBOARD_DATA,
        clock_50MHz => CLOCK_50,
        reset => RESET,
        scan_readyo => scan_ready,
        hist3 => OPEN,
        hist2 => hist2,
        hist1 => hist1,
        hist0 => hist0
    );

    keypress_1 : keypresses
    PORT MAP(
        clock_50MHz => clk,
        reset => RESET_N,
        start => scan_ready,
        hist2 => hist2,
        hist1 => hist1,
        hist0 => hist0,
        speedA => TANKA_SPEED,
        speedB => TANKB_SPEED,
        bulletA => BULLETA_FIRED,
        bulletB => BULLETB_FIRED
    );

    current_Ascore : leddcd
    PORT MAP(
        data_in => A_SCORE,
        segments_out => SHOW_A_SCORE
    );

    current_Bscore : leddcd
    PORT MAP(
        data_in => B_SCORE,
        segments_out => SHOW_B_SCORE
    );

    show_winner : de2lcd
    PORT MAP(
        reset => RESET,
        clk_50Mhz => CLOCK_50,
        winner => WINNER,
        LCD_RS => LCD_RS,
        LCD_E => LCD_E,
        LCD_ON => LCD_ON,
        RESET_LED => RESET_LED,
        SEC_LED => SEC_LED,
        LCD_RW => LCD_RW,
        DATA_BUS => DATA_BUS
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