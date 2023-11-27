LIBRARY STD;
LIBRARY IEEE;
USE std.textio.ALL;
USE IEEE.std_logic_textio.ALL;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END ENTITY testbench;

ARCHITECTURE behavioral OF testbench IS

    COMPONENT clock_counter IS
        GENERIC (
            BITS : INTEGER := 20
        );
        PORT (
            clk, rst : IN STD_LOGIC;
            game_tick : OUT STD_LOGIC
        );
    END COMPONENT clock_counter;

    COMPONENT game_state IS
        PORT (
            clk, rst_n, start : IN STD_LOGIC;
            A_score, B_score : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            game_over : OUT STD_LOGIC;
            winner : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
        );
    END COMPONENT game_state;

    --testbench signals
    SIGNAL clk_tb, rst_tb, game_tick_tb : STD_LOGIC;
    SIGNAL A_score_tb, B_score_tb : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL game_over_tb : STD_LOGIC;
    SIGNAL winner_tb : STD_LOGIC_VECTOR (1 DOWNTO 0);

    CONSTANT PERIOD : TIME := 20 ns; --50 mhz clock
    CONSTANT wait_period : TIME := 590 ns;
    CONSTANT reset_period : TIME := 1790 ns;

BEGIN

    dut : game_state
    PORT MAP(
        clk => clk_tb,
        start => game_tick_tb,
        rst_n => rst_tb,
        A_score => A_score_tb,
        B_score => B_score_tb,
        game_over => game_over_tb,
        winner => winner_tb
    );

    clockCount : clock_counter
    GENERIC MAP(
        BITS => 5
    )
    PORT MAP(
        clk => clk_tb,
        rst => rst_tb,
        game_tick => game_tick_tb
    );

    --instantiate clock
    clk_generate : PROCESS IS
    BEGIN
        clk_tb <= '0';
        WAIT FOR (PERIOD/2);
        clk_tb <= '1';
        WAIT FOR (PERIOD/2);
    END PROCESS clk_generate;

    reset_process : PROCESS IS
    BEGIN
        rst_tb <= '1';
        WAIT FOR 5 ns;
        rst_tb <= '0';
        WAIT for reset_period;
        rst_tb <= '1';
        WAIT FOR 5 ns;
        rst_tb <= '0';
        WAIT for reset_period;
        WAIT;
    END PROCESS reset_process;

    print_process : PROCESS IS
        VARIABLE read_line, write_line : line;
        VARIABLE temp1, temp2 : INTEGER;
        FILE infile : text OPEN read_mode IS "game_state.in";
        FILE outfile : text OPEN write_mode IS "game_state.out";

    BEGIN
        WAIT FOR PERIOD;

        WHILE NOT (endfile(infile)) LOOP

            readline(infile, read_line);
            read(read_line, temp1);
            A_score_tb <= STD_LOGIC_VECTOR(to_unsigned(temp1, 4));

            readline(infile, read_line);
            read(read_line, temp2);
            B_score_tb <= STD_LOGIC_VECTOR(to_unsigned(temp2, 4));

            -- write break code
            write(write_line, STRING'("A: "));
            write(write_line, temp1);
            write(write_line, STRING'(" -- B:  "));
            write(write_line, temp2);
            writeline (outfile, write_line);

            --wait for computation
            WAIT FOR wait_period;

            -- was bulletA, bulletB fired?
            write(write_line, STRING'("Game over: "));
            IF (game_over_tb = '0') THEN
                write(write_line, STRING'("NO!"));
            ELSE
                write(write_line, STRING'("YES!"));
            END IF;

            write(write_line, STRING'(" -- "));
            write(write_line, STRING'("Winner: "));
            IF (winner_tb = "01") THEN
                write(write_line, STRING'("Player A"));
            ELSIF (winner_tb = "10") THEN
                write(write_line, STRING'("Player B"));
            ELSE
                write(write_line, STRING'("No winner yet"));
            END IF;
            writeline (outfile, write_line);
        END LOOP;
    END PROCESS print_process;

END ARCHITECTURE behavioral;