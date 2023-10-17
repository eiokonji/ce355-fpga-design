LIBRARY STD;
LIBRARY IEEE;
--Additional standard or custom libraries go here
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;
USE work.divider_const.ALL;

ENTITY testbench1 IS
END ENTITY testbench1;

ARCHITECTURE behavioral OF testbench1 IS
    --Entity (as component) and input ports (as signals) go here
    COMPONENT divider IS
        PORT (
            -- clk : in std_logic;
            --COMMENT OUT clk signal for Part A.
            start : IN STD_LOGIC;
            dividend : IN STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0);
            divisor : IN STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0);
            quotient : OUT STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0);
            remainder : OUT STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0);
            overflow : OUT STD_LOGIC
        );
    END COMPONENT divider;

    SIGNAL start_tb : STD_LOGIC := '0';
    SIGNAL dividend_tb : STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0) := (OTHERS => '0'); -- dividend
    SIGNAL divisor_tb : STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0) := (OTHERS => '0'); -- divsor
    SIGNAL quotient_tb : STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL remainder_tb : STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL overflow_tb : STD_LOGIC := '0';

BEGIN
    --     --component declaration and stimuli processes go here
    dut : divider
    PORT MAP (
        start => start_tb,
        dividend => dividend_tb,
        divisor => divisor_tb,
        quotient => quotient_tb,
        remainder => remainder_tb,
        overflow => overflow_tb
    );

    PROCESS IS
        -- CONSTANT DIVIDE : std_logic_vector(OP_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(2,OP_WIDTH));
        VARIABLE read_line : line; -- a buffer for what was read
        VARIABLE write_line : line; -- a buffer for what was written
        FILE infile : text OPEN read_mode IS "divider32.in";
        FILE outfile : text OPEN write_mode IS "divider32.out";
        VARIABLE temp1 : INTEGER;
        VARIABLE temp2 : INTEGER;

    BEGIN
        wait for 1ns;
        
        WHILE NOT (endfile(infile)) LOOP
            -- read in both operands and operations
            readline(infile, read_line);
            read(read_line, temp1);
            dividend_tb <= STD_LOGIC_VECTOR(to_unsigned(temp1, DIVIDEND_WIDTH));

            readline(infile, read_line);
            read(read_line, temp2);
            divisor_tb <= STD_LOGIC_VECTOR(to_unsigned(temp2, DIVISOR_WIDTH));

            wait for 1ns;            
            start_tb <= '1';

            -- write operand one
            write(write_line, temp1);
            write(write_line, STRING'(" / "));
            -- write operand two
            write(write_line, temp2);
            write(write_line, STRING'(" = "));

            WAIT FOR 5 ns;

            --calculator answer
            write(write_line, to_integer(unsigned(quotient_tb)));
            write(write_line, STRING'(" -- "));       
            write(write_line, to_integer(unsigned(remainder_tb)));
            writeline (outfile, write_line);
            start_tb <= '0';
            WAIT FOR 5 ns;
        END LOOP;

    END PROCESS;

END ARCHITECTURE behavioral;