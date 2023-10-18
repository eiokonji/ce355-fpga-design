LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.divider_const.ALL;
--Additional standard or custom libraries go here
USE ieee.numeric_std.ALL;
USE IEEE.std_logic_textio.ALL;

ENTITY divider IS
    PORT (
        clk : IN STD_LOGIC;
        --COMMENT OUT clk signal for Part A.
        start : IN STD_LOGIC;
        dividend : IN STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0);
        divisor : IN STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0);
        --Outputs
        quotient : OUT STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0);
        remainder : OUT STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0);
        overflow : OUT STD_LOGIC
    );
END ENTITY divider;

ARCHITECTURE behavioral_sequential OF divider IS
    --signals and components
    COMPONENT comparator IS
        GENERIC (
            DATA_WIDTH : NATURAL := DIVISOR_WIDTH
        );
        PORT (
            --Inputs
            DINL : IN STD_LOGIC_VECTOR (DATA_WIDTH DOWNTO 0);
            DINR : IN STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
            --Outputs
            DOUT : OUT STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
            isGreaterEq : OUT STD_LOGIC
        );
    END COMPONENT comparator;

    --initialize signals (for sequential circuits)
    TYPE DINL_var_type IS ARRAY(DIVIDEND_WIDTH - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(DIVISOR_WIDTH DOWNTO 0);
    SIGNAL DINL_var : DINL_var_type;
    TYPE DOUT_var_type IS ARRAY(DIVIDEND_WIDTH - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(DIVISOR_WIDTH - 1 DOWNTO 0);
    SIGNAL DOUT_var : DOUT_var_type;
    SIGNAL temp_dinl : STD_LOGIC_VECTOR (DIVISOR_WIDTH DOWNTO 0);
    SIGNAL quotient_temp : STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0);
   -- SIGNAL remainder_temp : STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0);
    SIGNAL overflow_temp : STD_LOGIC;

BEGIN
    seq_divide : PROCESS (clk, start) BEGIN
        --compute overflow_temp
        IF  (to_integer(unsigned(divisor)) = 0) then
            overflow_temp <= '1';
        ELSE
            overflow_temp <= '0';
        END IF;

        --do actual division
        divide_loop : FOR i IN 0 TO DIVIDEND_WIDTH - 1 LOOP
            --start loop
            --feed inputs into comparator 
            --do one step division
            --feed inputs back into comparator (instantly?)
            --comparator only starts on the rising clock edge

            --figure out how to change temp_dinl according to current case
            --prepare inputs for the next clock cycle

            CASE (i) IS
                WHEN (0)
                    temp_dinl <= (0 => dividend(DIVIDEND_WIDTH - 1), OTHERS => '0');
                WHEN (1 TO DIVIDEND_WIDTH - 1)
                    temp_din1 <= DINL_var(i - 1);
            END CASE;

            WHILE (!rising_edge(clk)) LOOP
                --wait for rising clock edge
            END LOOP;

            IF (rising_edge(clk)) THEN
                comp_first : comparator
                PORT MAP(-- not necessarily concurrent
                    DINL => temp_dinl,
                    DINR => divisor,
                    DOUT => DOUT_var(i),
                    isGreaterEq => quotient_temp(DIVIDEND_WIDTH - 1 - i)
                );
                DINL_var(i) <= <= DOUT_var(i) & dividend(DIVIDEND_WIDTH - 2 - i);

            END IF;
        END LOOP divide_loop;

        --release results in temp variables to actual result variables
        --concurrently assign signals outside to prevent delay
        IF (rising_edge(start)) THEN
            quotient <= quotient_temp;
            remainder <= DOUT_var(DIVIDEND_WIDTH - 1);
            overflow <= overflow_temp;
        END IF;

    END PROCESS seq_divide;

END ARCHITECTURE behavioral_sequential;

ARCHITECTURE structural_combinational OF divider IS
    --Signals and components go here
    COMPONENT comparator IS
        GENERIC (
            DATA_WIDTH : NATURAL := DIVISOR_WIDTH
        );
        PORT (
            --Inputs
            DINL : IN STD_LOGIC_VECTOR (DATA_WIDTH DOWNTO 0);
            DINR : IN STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
            --Outputs
            DOUT : OUT STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
            isGreaterEq : OUT STD_LOGIC
        );
    END COMPONENT comparator;

    --custom 2D array to store DINL input values to mid slice comparators
    --dividend width x divisor width + 1
    TYPE DINL_var_type IS ARRAY(DIVIDEND_WIDTH - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(DIVISOR_WIDTH DOWNTO 0);
    SIGNAL DINL_var : DINL_var_type;
    TYPE DOUT_var_type IS ARRAY(DIVIDEND_WIDTH - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(DIVISOR_WIDTH - 1 DOWNTO 0);
    SIGNAL DOUT_var : DOUT_var_type;
    SIGNAL temp_dinl : STD_LOGIC_VECTOR (DIVISOR_WIDTH DOWNTO 0);
    SIGNAL quotient_temp : STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0);
    SIGNAL remainder_temp : STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0);
    SIGNAL overflow_temp : STD_LOGIC;

    --if using variables instead, declare within process.

BEGIN
    -- compute overflow_temp
    overflow_temp <= '1' WHEN (to_integer(unsigned(divisor)) = 0) ELSE
        '0';

    -- actual division here
    subtractor : FOR i IN 0 TO (DIVIDEND_WIDTH - 1) GENERATE BEGIN
        firstslice : IF (i = 0) GENERATE BEGIN
            temp_dinl <= (0 => dividend(DIVIDEND_WIDTH - 1), OTHERS => '0');
            comp_first : comparator
            PORT MAP(
                DINL => temp_dinl,
                DINR => divisor,
                DOUT => DOUT_var(i),
                isGreaterEq => quotient_temp(DIVIDEND_WIDTH - 1 - i)
            );
            DINL_var(i) <= DOUT_var(i) & dividend(DIVIDEND_WIDTH - 2 - i);
        END GENERATE firstslice;

        midslice : IF (i > 0 AND i < (DIVIDEND_WIDTH - 1)) GENERATE BEGIN
            comp_mid : comparator
            PORT MAP(
                DINL => DINL_var(i - 1),
                DINR => divisor,
                DOUT => DOUT_var(i),
                isGreaterEq => quotient_temp(DIVIDEND_WIDTH - 1 - i)
            );
            DINL_var(i) <= DOUT_var(i) & dividend(DIVIDEND_WIDTH - 2 - i);
        END GENERATE midslice;

        lastslice : IF (i = (DIVIDEND_WIDTH - 1)) GENERATE BEGIN
            comp_last : comparator
            PORT MAP(
                DINL => DINL_var(i - 1), --t_in3,
                DINR => divisor,
                DOUT => remainder_temp,
                isGreaterEq => quotient_temp(DIVIDEND_WIDTH - 1 - i) -- ie last bit
            );
        END GENERATE lastslice;

    END GENERATE subtractor;

    gate_start : PROCESS (start) BEGIN
        -- check for overflow: only when divisor is 0
        -- IF (start = '1') THEN
        IF (rising_edge(start)) THEN
            quotient <= quotient_temp;
            remainder <= remainder_temp;
            overflow <= overflow_temp;
        END IF;
    END PROCESS gate_start;

END ARCHITECTURE structural_combinational;