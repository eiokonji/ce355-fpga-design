-- This module tests the keypresses file 

LIBRARY STD;
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;
USE IEEE.std_logic_textio.ALL;

ENTITY testbench IS
END ENTITY testbench;

ARCHITECTURE behavioral OF testbench IS
    COMPONENT keypresses IS
        PORT (
            clock_50MHz, reset, start : IN STD_LOGIC;
            hist1, hist0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            speedA, speedB : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            bulletA, bulletB : OUT STD_LOGIC
        );
    END COMPONENT keypresses;

    SIGNAL clk_tb, reset_tb, start_tb, bulletA_tb, bulletB_tb : STD_LOGIC;
    SIGNAL hist1_tb, hist0_tb : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL speedA_tb, speedB_tb : STD_LOGIC_VECTOR (3 DOWNTO 0);

    CONSTANT PERIOD : TIME := 20 ns; --50 mhz clock

BEGIN
    dut : keypresses
    PORT MAP(
        clock_50MHz => clk_tb,
        reset => reset_tb,
        start => start_tb,
        hist1 => hist1_tb,
        hist0 => hist0_tb,
        speedA => speedA_tb,
        speedB => speedB_tb,
        bulletA => bulletA_tb,
        bulletB => bulletB_tb
    );

    clk_generate : PROCESS IS
    BEGIN
        clk_tb <= '0';
        WAIT FOR (PERIOD/2);
        clk_tb <= '1';
        WAIT FOR (PERIOD/2);
    END PROCESS clk_generate;

    -- reset_process : PROCESS IS
    -- BEGIN
    --     reset_tb <= '0';
    --     WAIT UNTIL (clk_tb = '0');
    --     WAIT UNTIL (clk_tb = '1');
    --     reset_tb <= '1';
    --     WAIT UNTIL (clk_tb = '0');
    --     WAIT UNTIL (clk_tb = '1');
    --     reset_tb <= '0';
    --     WAIT;
    -- END PROCESS reset_process;

    start_process : PROCESS IS
    BEGIN
        start_tb <= '1';
        WAIT;
    END PROCESS start_process;

    reset_process : PROCESS IS
    BEGIN
        reset_tb <= '0';
        WAIT;
    END PROCESS reset_process;

    PROCESS IS
        VARIABLE read_line, write_line : line;
        VARIABLE temp1, temp2 : INTEGER;
        FILE infile : text OPEN read_mode IS "keypress.in";
        FILE outfile : text OPEN write_mode IS "keypress.out";

    BEGIN
        WAIT FOR PERIOD;

        WHILE NOT (endfile(infile)) LOOP

            readline(infile, read_line);
            read(read_line, temp1);
            hist1_tb <= STD_LOGIC_VECTOR(to_unsigned(temp1, 8));

            readline(infile, read_line);
            read(read_line, temp2);
            hist0_tb <= STD_LOGIC_VECTOR(to_unsigned(temp2, 8));

            -- write break code
            write(write_line, STRING'("break code is "));
            write(write_line, temp1);
            write(write_line, STRING'(" "));
            write(write_line, temp2);
            writeline (outfile, write_line);

            --wait for computation
            WAIT FOR PERIOD;

            -- document effects of break code aka keypress
            -- did tankA, tankB speed change? 
            write(write_line, STRING'("speedA: "));
            write(write_line, to_integer(unsigned(speedA_tb)));
            write(write_line, STRING'(" -- "));
            write(write_line, STRING'("speedB: "));
            write(write_line, to_integer(unsigned(speedB_tb)));
            writeline (outfile, write_line);

            -- was bulletA, bulletB fired?
            write(write_line, STRING'("bulletA: "));
            if (bulletA_tb = '1') THEN
                write(write_line, STRING'("fired!"));
            ELSE
                write(write_line, STRING'("not fired"));
            end if;
            write(write_line, STRING'(" -- "));
            write(write_line, STRING'("bulletB: "));
            if (bulletB_tb = '1') THEN
                write(write_line, STRING'("fired!"));
            ELSE
                write(write_line, STRING'("not fired"));
            end if;
            writeline (outfile, write_line);
        END LOOP;
    END PROCESS;

END ARCHITECTURE behavioral;