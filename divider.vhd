LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.divider_const.ALL;
--Additional standard or custom libraries go here
USE ieee.numeric_std.ALL;
USE IEEE.std_logic_textio.ALL;

ENTITY divider IS
    PORT (
        -- clk : in std_logic;
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

    SIGNAL temp_out : STD_LOGIC_VECTOR ((DIVISOR_WIDTH)*(DIVIDEND_WIDTH-DIVISOR_WIDTH) DOWNTO 0);
    signal t_in1 : STD_LOGIC_VECTOR (DIVISOR_WIDTH DOWNTO 0);
    signal t_in2 : STD_LOGIC_VECTOR (DIVISOR_WIDTH DOWNTO 0);
    signal t_in3 : STD_LOGIC_VECTOR (DIVISOR_WIDTH DOWNTO 0);

BEGIN
    -- initialize quotient
    quotient <= (OTHERS => '0');

    -- check for overflow
    overflow <= '1' when (unsigned(dividend(DIVIDEND_WIDTH - 1 DOWNTO DIVISOR_WIDTH)) >= unsigned(divisor)) ELSE
        '0';

    -- actual division here
    -- report "sliced dividend " & integer'image(to_integer(unsigned(dividend(DIVIDEND_WIDTH - 1 DOWNTO DIVIDEND_WIDTH - DIVISOR_WIDTH))));
    subtractor : FOR i IN 0 TO (DIVIDEND_WIDTH - DIVISOR_WIDTH) GENERATE BEGIN
        firstslice : IF (i = 0) GENERATE BEGIN
            t_in1 <= std_logic_vector(resize(unsigned(dividend(DIVIDEND_WIDTH - 1 DOWNTO DIVIDEND_WIDTH - DIVISOR_WIDTH)), DIVISOR_WIDTH+1));
            comp_first : comparator
            PORT MAP(
                -- DINL => '0' & dividend(DIVIDEND_WIDTH - 1 DOWNTO DIVIDEND_WIDTH - DIVISOR_WIDTH),
                DINL => t_in1,
                DINR => divisor,
                DOUT => temp_out((DIVISOR_WIDTH)*(i+1)-1 downto (DIVISOR_WIDTH)*(i)),
                isGreaterEq => quotient(DIVIDEND_WIDTH - DIVISOR_WIDTH)
            );
        END GENERATE firstslice;

        midslice : IF (i > 0 AND i < (DIVIDEND_WIDTH - DIVISOR_WIDTH)) GENERATE BEGIN
            -- t_in <= temp_out & dividend(DIVIDEND_WIDTH - DIVISOR_WIDTH - i);
            t_in2 <= temp_out((DIVISOR_WIDTH)*(i)-1 downto (DIVISOR_WIDTH)*(i-1)) & dividend(DIVIDEND_WIDTH - DIVISOR_WIDTH - i);
            -- t_in <= (DIVISOR_WIDTH downto 1 => temp_out, others => dividend(DIVIDEND_WIDTH - DIVISOR_WIDTH - i));
            comp_mid : comparator
            PORT MAP(
                DINL => '0'&'1'&'0'&'1'&'0'&'1'&'0'&'1'&'0',
                DINR => divisor,
                DOUT => temp_out((DIVISOR_WIDTH)*(i+1)-1 downto (DIVISOR_WIDTH)*(i)),
                isGreaterEq => quotient(DIVIDEND_WIDTH - DIVISOR_WIDTH - i)
            );
        END GENERATE midslice;

        lastslice : IF (i = (DIVIDEND_WIDTH - DIVISOR_WIDTH)) GENERATE BEGIN
            -- t_in <= temp_out & dividend(0);
            -- t_in <= (DIVISOR_WIDTH downto 1 => temp_out, others => dividend(0));
            t_in3 <= temp_out((DIVISOR_WIDTH)*(i)-1 downto (DIVISOR_WIDTH)*(i-1)) & dividend(0);
            comp_last : comparator
            PORT MAP(
                DINL => t_in3,
                DINR => divisor,
                DOUT => remainder,
                isGreaterEq => quotient(0) -- same as quotient(DIVIDEND_WIDTH-DIVISOR_WIDTH-i) ie last bit
            );
        END GENERATE lastslice;

    END GENERATE subtractor;

END ARCHITECTURE structural_combinational;