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
        --if DINL >= DINR:
        --DOUT = remainder of DINL - DINR
        --isGreaterEq = 1
        --else if DINL < DINR:
        --DOUT = DINL 
        --isGreaterEq = 0
        
        IF (unsigned(DINL) >= unsigned(DINR)) THEN
            dout1 <= STD_LOGIC_VECTOR(resize((unsigned(DINL) - unsigned(DINR)), DATA_WIDTH));
            ige <= '1';
        ELSE
            dout1 <= STD_LOGIC_VECTOR(resize(unsigned(DINL), DATA_WIDTH));
            ige <= '0';
        END IF;
    END PROCESS compare;

    DOUT <= dout1;
    isGreaterEq <= ige;

END ARCHITECTURE behavioral;