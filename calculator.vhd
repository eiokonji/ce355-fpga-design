LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
--Additional standard or custom libraries go here
USE WORK.decoder.ALL;
USE WORK.calc_const.ALL;
USE IEEE.numeric_std.ALL; --provides signed/unsigned and integer data types

ENTITY calculator IS
    PORT (
        --Inputs
        DIN1 : IN STD_LOGIC_VECTOR (DIN1_WIDTH - 1 DOWNTO 0);
        DIN2 : IN STD_LOGIC_VECTOR (DIN2_WIDTH - 1 DOWNTO 0);
        operation : IN STD_LOGIC_VECTOR (OP_WIDTH - 1 DOWNTO 0);
        --Outputs
        DOUT : OUT STD_LOGIC_VECTOR (DOUT_WIDTH - 1 DOWNTO 0);
        sign : OUT STD_LOGIC
    );
END ENTITY calculator;

ARCHITECTURE behavioral OF calculator IS

    --Signals and components go here
    SIGNAL DIN1_int, DIN2_int, OP_int : INTEGER;
    SIGNAL output : std_logic_vector(DOUT_WIDTH-1 downto 0);
    CONSTANT ADD : std_logic_vector(OP_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(3,OP_WIDTH));
    CONSTANT MULTIPLY : std_logic_vector(OP_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(1,OP_WIDTH));
    CONSTANT SUBTRACT : std_logic_vector(OP_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(2,OP_WIDTH));
    --Behavioral design goes here
BEGIN
    calculate : PROCESS (DIN1, DIN2, operation)
    BEGIN
        --add
        IF (operation = ADD) THEN
            report "entered addition";
            DIN1_int <= to_integer(signed(DIN1));
            DIN2_int <= to_integer(signed(DIN2));
            report "DIN1_int is " & integer'image(DIN1_int);
            report "DIN2_int is " & integer'image(DIN2_int);
            output <= std_logic_vector(resize(signed(DIN1) + signed(DIN2), DOUT_WIDTH));
        --multiply
        ELSIF (operation = MULTIPLY) THEN
            report "entered multiplication";
            DIN1_int <= to_integer(signed(DIN1));
            DIN2_int <= to_integer(signed(DIN2));
            report "DIN1_int is " & integer'image(DIN1_int);
            report "DIN2_int is " & integer'image(DIN2_int);
            output <= std_logic_vector(resize(signed(DIN1) * signed(DIN2), DOUT_WIDTH));
            
        --subtract
        ELSIF (operation = SUBTRACT) THEN
            report "entered subtraction";
            DIN1_int <= to_integer(signed(DIN1));
            DIN2_int <= to_integer(signed(DIN2));
            report "DIN1_int is " & integer'image(DIN1_int);
            report "DIN2_int is " & integer'image(DIN2_int);
            output <= std_logic_vector(resize(signed(DIN1) - signed(DIN2), DOUT_WIDTH));
        ELSE
            output <= std_logic_vector(to_unsigned(0, DOUT_WIDTH));

        END IF;

    END PROCESS calculate;
    
        --compute absolute value of output
        DOUT <= std_logic_vector(abs(signed(output)));
        sign <= output(DOUT_WIDTH-1);

    -- end CALCULATE calculator1;
END ARCHITECTURE behavioral;