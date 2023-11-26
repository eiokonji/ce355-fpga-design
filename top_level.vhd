--This module controls the top-level VGA of the tank game
-- _C is combinational signal

LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY top_level IS
    PORT (
        CLOCK_50 : IN STD_LOGIC;
        RESET : IN STD_LOGIC;
        --VGA 
        VGA_RED, VGA_GREEN, VGA_BLUE : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        HORIZ_SYNC, VERT_SYNC, VGA_BLANK, VGA_CLK : OUT STD_LOGIC

    );
END ENTITY top_level;

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
            tankA_x, tankA_y, tankB_x, tankB_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            -- bulletA_x, bulletA_y, bulletB_x, bulletB_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT pixelGenerator;

    COMPONENT tankA IS
        PORT (
            clk, rst_n, start : IN STD_LOGIC;
            speed : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            pos_x, pos_y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    END COMPONENT tankA;

    COMPONENT tankB IS
        PORT (
            clk, rst_n, start : IN STD_LOGIC;
            speed : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            pos_x, pos_y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    END COMPONENT tankB;

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
    SIGNAL RESET_N : STD_LOGIC;

    --Signals for VGA sync
    SIGNAL pixel_row_int : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL pixel_column_int : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL video_on_int : STD_LOGIC;
    SIGNAL VGA_clk_int : STD_LOGIC;
    SIGNAL eof : STD_LOGIC;

    --signals for tank positions
    SIGNAL TANKA_X, TANKA_Y, TANKB_X, TANKB_Y : STD_LOGIC_VECTOR(9 DOWNTO 0);
    --signals for tank speed
    SIGNAL TANKA_SPEED, TANKB_SPEED : STD_LOGIC_VECTOR(3 DOWNTO 0) := (0 = '1', others => '0');

BEGIN
    RESET_N <= NOT RESET; -- if reset is 1, because RESET is '0'

    --------------------------------------------------------------------------------------------
    clockCount : clock_counter
    GENERIC MAP(
        BITS => 21
    )
    PORT MAP(
        clk => CLOCK_50,
        rst => RESET_N,
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

        tankA_x => TANKA_X,
        tankA_y => TANKA_Y,
        tankB_x => TANKB_X,
        tankB_y => TANKB_Y,
        -- bulletA_x, bulletA_y, bulletB_x, bulletB_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);

        red_out => VGA_RED,
        green_out => VGA_GREEN,
        blue_out => VGA_BLUE
    );

    tankAModule : tankA IS
    PORT MAP(
        clk => CLOCK_50,
        rst_n => RESET_N,
        start => game_ticks,
        speed => TANKA_SPEED,
        pos_x => TANKA_X,
        pos_y => TANKA_Y
    );

    tankBModule : tankB IS
    PORT MAP(
        clk => CLOCK_50,
        rst_n => RESET_N,
        start => game_ticks,
        speed => TANKB_SPEED,
        pos_x => TANKB_X,
        pos_y => TANKB_Y
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