LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
--Additional standard or custom libraries go here
USE ieee.numeric_std.ALL;

ENTITY comparator IS
    GENERIC (
        DATA_WIDTH : NATURAL := 4
    );
    PORT (
        --Inputs
        DINL : IN STD_LOGIC_VECTOR (DATA_WIDTH DOWNTO 0);
        DINR : IN STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
        --Outputs
        DOUT : OUT STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
        isGreaterEq : OUT STD_LOGIC
    );
END ENTITY comparator;
ARCHITECTURE behavioral OF comparator IS
    --Signals and components go here
    SIGNAL DINR_resized : unsigned(DATA_WIDTH DOWNTO 0);
    SIGNAL dout1 : STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL ige : STD_LOGIC;
BEGIN
    --Behavioral design goes here
    compare : PROCESS (DINR, DINL)
    BEGIN
        --initialize DINR_resized as an unsigned bit vector
        report "dinr is " & integer'image(to_integer(unsigned(DINR)));
        -- DINR_resized <= resize(unsigned(DINR), DATA_WIDTH + 1);
        DINR_resized <= unsigned('0' & DINR);
        report "unsigned dinr is " & integer'image(to_integer(unsigned(DINR)));
        report "dinr_resized is " & integer'image(to_integer(DINR_resized));

        --if DINL >= DINR:
        --isGreaterEq = 1
        --else = 0
        
        if (unsigned(DINL) >= DINR_resized) then
            ige <= '1';
        ELSE
            ige <= '0';
        end if;

        --if DINL >= DINR:
        --DOUT = remainder of DINL - DINR if
        --else if DINL < DINR:
        --DOUT = DINL 
        IF (unsigned(DINL) >= DINR_resized) THEN
            dout1 <= STD_LOGIC_VECTOR(unsigned(DINL) - DINR_resized);
        ELSE
            dout1 <= STD_LOGIC_VECTOR(resize(unsigned(DINL), DATA_WIDTH));
        END IF;
    END PROCESS compare;

    DOUT <= dout1;
    isGreaterEq <= ige;

END ARCHITECTURE behavioral;