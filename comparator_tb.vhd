LIBRARY STD;
LIBRARY IEEE;
--Additional standard or custom libraries go here
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END ENTITY testbench;
ARCHITECTURE behavioral OF testbench IS
    --Entity (as component) and input ports (as signals) go here
    COMPONENT comparator IS
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
    END COMPONENT comparator;

    --initialize signals
    constant data_width :  NATURAL := 4;
    SIGNAL dinl_tb : STD_LOGIC_VECTOR (data_width DOWNTO 0) := (others => '0');
    SIGNAL dinr_tb : STD_LOGIC_VECTOR (data_width-1 DOWNTO 0) := (others => '0'); 
    SIGNAL dout_tb : STD_LOGIC_VECTOR (data_width-1 DOWNTO 0) := (others => '0');
    SIGNAL ige_tb : STD_LOGIC := '0';

BEGIN
    --component declaration and stimuli processes go here
    dut : comparator
    PORT MAP(
        DINL => dinl_tb,
        DINR => dinr_tb,
        DOUT => dout_tb,
        isGreaterEq => ige_tb
    );

    COMP : PROCESS is 
    -- vars, constants go here
    begin 
        dinl_tb <= "00011";   -- 3
        dinr_tb <= "0001";    -- 1
        -- expected dout: 2
        -- expected ige: 1
        wait for 10ns;
        dinl_tb <= "00001";   -- 1
        dinr_tb <= "0011";    -- 3
        -- expected dout: 1
        -- expected ige: 0
        wait for 10ns;
        dinl_tb <= "00010";   -- 2
        dinr_tb <= "0010";    -- 2
        -- expected dout: 0
        -- expected ige: 1
        wait for 10ns;
        dinl_tb <= "11111";   -- 31
        dinr_tb <= "1111";    -- 15
        -- expected dout: 16
        -- expected ige: 1
        wait;

    end PROCESS COMP;

END ARCHITECTURE behavioral;