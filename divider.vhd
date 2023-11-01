<<<<<<< Updated upstream
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
        if (rising_edge(start)) then
            quotient <= quotient_temp;
            remainder <= remainder_temp;
            overflow <= overflow_temp;
        END IF;
    END PROCESS gate_start;

=======
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.divider_const.ALL;
--Additional standard or custom libraries go here
USE ieee.numeric_std.ALL;
USE IEEE.std_logic_textio.ALL;

ENTITY divider IS
    PORT (
        --Inputs
        clk : IN STD_LOGIC;
        start : IN STD_LOGIC;
        dividend : IN STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0);
        divisor : IN STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0);
        --Outputs
        quotient : OUT STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0);
        remainder : OUT STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0);
        overflow : OUT STD_LOGIC
    );
END ENTITY divider;

ARCHITECTURE fsm_behavior of divider is
    --declaration region
    signal a : std_logic_vector(DIVIDEND_WIDTH-1 downto 0);
    signal b : std_logic_vector(DIVISOR_WIDTH-1 downto 0);
    signal q : STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0) := (others = '0');
    signal r : STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0); 
    signal o : std_logic;
    signal done : std_logic;

    -- clocked signals
    signal a_c : std_logic_vector(DIVIDEND_WIDTH-1 downto 0);
    signal b_c : std_logic_vector(DIVISOR_WIDTH-1 downto 0);
    signal q_c : STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0);
    signal r_c : STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0); 
    signal o_c : std_logic;
    signal done_c : std_logic;

    -- declaring state signals
    type states (s0, s1, s2);
    signal state, next_state : states;

    function get_msb_pos (signal s: std_logic_vector) return integer is
        -- declarative region
        begin
            for i in s'Reverse_Range loop
                if s(i) = '1' then
                    return i;
                end if;
            end loop;
            --if vector is 0
            return 0;

    end function get_msb_pos;


    begin

    clk_process: process(clk,reset) is 
    begin
        -- intialize on reset
        if (reset = '1') then
            done <= '0';
            a <= (others => '0');
            b <= (others => '0');
            r <= (others => '0');
            o <= '0';
            q <= (others => '0');
            state <= s0;
        
        -- update on rising edge of clock
        elsif (rising_edge(clk)) then
            done <= done_c;
            a <= a_c;
            b <= b_c;
            r <= r_c;
            o <= o_c;
            q <= q_c;
            state <= next_state;
        end if;
        

    end process clk_process;

    comb_process: process(a,b,p,start) is 
    variable p : integer := 0;
    variable sign : std_logic := '0';

    begin
        a <= ((signed)dividend < 0) ? (not((signed)dividend) + 1) : dividend;
        b <= ((signed)divisor < 0) ? (not((signed)divisor) + 1) : divisor;
    end process comb_process;



end architecture fsm_behavior;

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

    --signals for clocking (storing new vs old inputs)
    SIGNAL dividend_temp : STD_LOGIC_VECTOR(DIVIDEND_WIDTH - 1 DOWNTO 0);
    SIGNAL dinl_temp : STD_LOGIC_VECTOR (DIVISOR_WIDTH DOWNTO 0);
    SIGNAL divisor_temp : STD_LOGIC_VECTOR(DIVISOR_WIDTH - 1 DOWNTO 0);
    SIGNAL dout_temp : STD_LOGIC_VECTOR(DIVISOR_WIDTH - 1 DOWNTO 0);
    SIGNAL i : INTEGER := 0;

    --signals for temporary outputs
    SIGNAL quotient_temp : STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0);
    SIGNAL quotient_bit : STD_LOGIC;
    SIGNAL overflow_temp : STD_LOGIC;
    SIGNAL remainder_temp : STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0);



BEGIN
    --instantiate a single comparator
    comp_first : comparator
    PORT MAP(
        DINL => dinl_temp,
        DINR => divisor_temp,
        DOUT => dout_temp,
        isGreaterEq => quotient_bit
    );

    --perform the actual division
    seq_divide : PROCESS (clk, start)
    BEGIN
        IF (rising_edge(start)) THEN
            --update new inputs
            dividend_temp <= dividend;
            divisor_temp <= divisor;
            --set dividend index to 0
            i <= 0;
            --set up first comparator inputs
            dinl_temp <= (0 => dividend(DIVIDEND_WIDTH - 1), OTHERS => '0');
            --compute overflow_temp
            IF (to_integer(unsigned(divisor)) = 0) THEN
                overflow_temp <= '1';
            ELSE
                overflow_temp <= '0';
            END IF;

            
        --check for clock edge
        ELSIF (rising_edge(clk)) THEN
            IF (i < DIVIDEND_WIDTH) THEN
                --store IsGreaterEq result 
                quotient_temp(DIVIDEND_WIDTH - 1 - i) <= quotient_bit;
                --update din1_temp with previous output
                if (i < DIVIDEND_WIDTH-1) then
                    dinl_temp <= dout_temp & dividend_temp(DIVIDEND_WIDTH - 2 - i);
                end if;
                --increment division index
                i <= i + 1;
            ELSE
                -- done with division, so assign remainder as last dout
                -- report "entered else " & integer'image (i);
                remainder_temp <= dout_temp;
            END IF;
        END IF;
    END PROCESS seq_divide;

    --concurrently assign output outside of process to prevent delay
    quotient <= quotient_temp;
    remainder <= remainder_temp;
    overflow <= overflow_temp;

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
                isGreaterEq => quotient_temp(DIVIDEND_WIDTH - 1 - i) -- i.e. last bit
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

>>>>>>> Stashed changes
END ARCHITECTURE structural_combinational;