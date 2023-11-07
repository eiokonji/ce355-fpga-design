LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
--Additional standard or custom libraries go here
USE WORK.decoder.ALL;
USE WORK.divider_const.ALL;
USE ieee.numeric_std.ALL;

ENTITY display_divider IS
    PORT (
        --You will replace these with your actual inputs and outputs
        reset1 : in std_logic;
		clk1 : IN STD_LOGIC;
        start1 : IN STD_LOGIC;
        dividend1 : IN STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0);
        divisor1 : IN STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0);
        --Outputs
        quotient1 : OUT STD_LOGIC_VECTOR ((DIVIDEND_WIDTH/4) * 7 - 1 DOWNTO 0);
        remainder1 : OUT STD_LOGIC_VECTOR ((DIVISOR_WIDTH/4) * 7 - 1 DOWNTO 0);
        overflow1 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        done1 : OUT std_logic;
        quot_sign : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        rem_sign : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    );
END ENTITY display_divider;

ARCHITECTURE structural OF display_divider IS
    --Signals and components go here
    COMPONENT divider IS
        PORT (
            clk : in std_logic;
            reset : in std_logic;
            --COMMENT OUT clk signal for Part A.
            start : IN STD_LOGIC;
            dividend : IN STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0);
            divisor : IN STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0);
            --Outputs
            quotient : OUT STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0);
            remainder : OUT STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0);
            overflow : OUT STD_LOGIC;
            done : out std_logic
        );
    END COMPONENT divider;

    COMPONENT leddcd IS
        PORT (
            --You will replace these with your actual inputs and outputs
            data_in : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            segments_out : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
        );
    END COMPONENT leddcd;

    SIGNAL quot_hl : STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0);
    SIGNAL abs_quot : STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0);
    SIGNAL rem_hl : STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0);
    SIGNAL abs_rem : STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0);
    SIGNAL over_hl : STD_LOGIC;
    signal overflow_din1 : std_logic_vector(3 downto 0);
    signal done_hl : std_logic;
BEGIN
    --Structural design goes here
    --instantiate divider
    divider1 : divider
    PORT MAP(
        --Inputs
		  clk => clk1,
          reset => reset1,
        start => start1,
        dividend => dividend1,
        divisor => divisor1,
        --Outputs
        quotient => quot_hl,
        remainder => rem_hl,
        overflow => over_hl,
        done => done_hl
    );

    quot_sign <= "0111111" when (quot_hl(DIVIDEND_WIDTH - 1) = '1') else
    "1111111";

    rem_sign <= "0111111" when (rem_hl(DIVISOR_WIDTH - 1) = '1') else
    "1111111";

    -- abs_quot <= STD_LOGIC_VECTOR(NOT(unsigned(quot_hl)) + unsigned(weird));
    -- abs_rem <= STD_LOGIC_VECTOR(NOT(unsigned(rem_hl)) + unsigned(short_weird));

    -- --instantiate 3 LED decoders, which will display in hex
    quot : FOR i IN 0 TO (DIVIDEND_WIDTH/4) -1 GENERATE BEGIN
        quot_dcd : leddcd
        PORT MAP(
            data_in => quot_hl(4 * (i + 1) - 1 DOWNTO 4 * i),
            segments_out => quotient1(7 * (i + 1) - 1 DOWNTO 7 * i)
        );
    END GENERATE;

    remain : FOR i IN 0 TO (DIVISOR_WIDTH/4) -1 GENERATE BEGIN
        rem_dcd : leddcd
        PORT MAP(
            data_in => rem_hl(4 * (i + 1) - 1 DOWNTO 4 * i),
            segments_out => remainder1(7 * (i + 1) - 1 DOWNTO 7 * i)
        );
    END GENERATE;

    overflow_din1 <= "000" & over_hl;
    ovr : leddcd
    PORT MAP(
        data_in => overflow_din1,
        segments_out => overflow1
    );
END ARCHITECTURE structural;