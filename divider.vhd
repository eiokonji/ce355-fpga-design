LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.divider_const.ALL;
--Additional standard or custom libraries go here
USE ieee.numeric_std.ALL;
USE IEEE.std_logic_textio.ALL;

ENTITY divider IS
    PORT (
        --Inputs
        reset : IN STD_LOGIC;
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

ARCHITECTURE fsm_behavior OF divider IS
    --declaration region
    SIGNAL a : STD_LOGIC_VECTOR(DIVIDEND_WIDTH - 1 DOWNTO 0);
    SIGNAL b : STD_LOGIC_VECTOR(DIVISOR_WIDTH - 1 DOWNTO 0);
    SIGNAL q : STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL r : STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0);
    SIGNAL o : STD_LOGIC;
    SIGNAL done : STD_LOGIC;

    -- clocked signals
    SIGNAL a_c : STD_LOGIC_VECTOR(DIVIDEND_WIDTH - 1 DOWNTO 0);
    SIGNAL b_c : STD_LOGIC_VECTOR(DIVISOR_WIDTH - 1 DOWNTO 0);
    SIGNAL q_c : STD_LOGIC_VECTOR (DIVIDEND_WIDTH - 1 DOWNTO 0);
    SIGNAL r_c : STD_LOGIC_VECTOR (DIVISOR_WIDTH - 1 DOWNTO 0);
    SIGNAL o_c : STD_LOGIC;
    SIGNAL done_c : STD_LOGIC;

    -- declaring state signals
    TYPE states is (s0, s1, s2);
    SIGNAL state, next_state : states;

    -- constants
    constant zeros : std_logic_vector(DIVISOR_WIDTH - 1 downto 0) := (others => '0');

    -- get_msb_pos function
    FUNCTION get_msb_pos (SIGNAL s : STD_LOGIC_VECTOR) RETURN INTEGER IS
        -- declarative region
    BEGIN
        FOR i IN s'Reverse_Range LOOP
            IF s(i) = '1' THEN
                RETURN i;
            END IF;
        END LOOP;
        --if vector is 0
        RETURN 0;

    END FUNCTION get_msb_pos;
BEGIN
    clk_process : PROCESS (clk, reset) IS
    BEGIN
        -- intialize on reset
        IF (reset = '1') THEN
            done <= '0';
            a <= (OTHERS => '0');
            b <= (OTHERS => '0');
            r <= (OTHERS => '0');
            o <= '0';
            q <= (OTHERS => '0'); 
            state <= s0;

        -- update on rising edge of clock
        ELSIF (rising_edge(clk)) THEN
            done <= done_c;
            a <= a_c;
            b <= b_c;
            r <= r_c;
            o <= o_c;
            q <= q_c;
            state <= next_state;
        END IF;
    END PROCESS clk_process;

    comb_process : PROCESS (a, b, start, state, done) IS
        -- set internal variables
        VARIABLE p : INTEGER := 0;
        VARIABLE sign_q : STD_LOGIC := '0';
        VARIABLE one : STD_LOGIC_VECTOR(DIVIDEND_WIDTH - 1 DOWNTO 0) := (0 => '1', OTHERS => '0');

    BEGIN
    -- _c signals are LHS in this section
        case (state) is 
            -- init state
            when s0 =>
                --a_c <= (signed(dividend) < 0)  ? (NOT(signed(dividend)) + 1) : dividend;
                -- b_c <= (signed(divisor) < 0) ? (NOT(signed(divisor)) + 1) : divisor;
                -- o_c <= (unsigned(divisor) = unsigned(zeros)) ? '1' : '0';
                
                if (signed(dividend) < 0) then
                    a_c <= std_logic_vector((NOT(unsigned(dividend)) + unsigned(one)));
                else 
                    a_c <= dividend;
                end if;

                if (signed(divisor) < 0) then
                    b_c <= std_logic_vector((NOT(unsigned(divisor)) + unsigned(one)));
                else 
                    b_c <= divisor;
                end if;
                
                if (unsigned(divisor) = unsigned(zeros)) then 
                    o_c <= '1';
                else 
                    o_c <= '0';
                end if;

                r_c <= (others => '0');
                q_c <= (others => '0');
                done_c <= '0';

                --check if start button was pressed
                if (rising_edge(start)) then
                    done_c <= '1';
                    next_state <= s1;
                end if;

            -- division state
            -- how do you use done signal?
            when s1 =>
                p := get_msb_pos(a) - get_msb_pos(b);
                if (shift_left(unsigned(b), p) > unsigned(a)) then -- shouldn't matter if signed/unsigned right?
                    p := p - 1;
                end if;
                q_c <= std_logic_vector(unsigned(q) + (shift_left(unsigned(one), p)));
                a_c <= std_logic_vector(unsigned(a) - (shift_left(unsigned(b), p)));
    
                --increment state when done
                if (unsigned(a_c) < unsigned(b_c)) then -- compare the clocked or unclocked?
                    done <= '1';
                    next_state <= s2;
                end if;

            -- epilogue state
            when s2 =>
                -- get sign_ 
                sign_q := dividend(DIVIDEND_WIDTH-1) xor divisor(DIVISOR_WIDTH-1);
                --sign_q := (shift_right(signed(dividend),(DIVIDEND_WIDTH - 1))) xor (shift_right(signed(divisor), (DIVISOR_WIDTH - 1)));
                -- apply result's sign to quotient, dividend's sign to remainder
                if (sign_q = '1') then
                    q_c <= std_logic_vector(NOT(unsigned(q_c)) + unsigned(one));
                end if;
                if (shift_right(unsigned(dividend), (DIVIDEND_WIDTH - 1)) = unsigned(one)) then
                    r_c <= std_logic_vector(NOT(unsigned(a_c)) + unsigned(one));
                end if;
                
                --return to first state
                next_state <= s0;
        end case;
        
    END PROCESS comb_process;

    -- pass the correct signals into the actual outputs
    quotient <= q;
    remainder <= r;
    overflow <= o;

END ARCHITECTURE fsm_behavior;

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
                IF (i < DIVIDEND_WIDTH - 1) THEN
                    dinl_temp <= dout_temp & dividend_temp(DIVIDEND_WIDTH - 2 - i);
                END IF;
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
END ARCHITECTURE structural_combinational;