LIBRARY STD;
LIBRARY IEEE;
--Additional standard or custom libraries go here
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END ENTITY testbench;

ARCHITECTURE behavioral OF testbench IS

    COMPONENT clock_counter is
    PORT (
        clk, rst : in std_logic;
        game_tick : out std_logic
    );
    END COMPONENT clock_counter;

    COMPONENT inc_scoreA IS
    PORT (
        clk, rst_n, start : IN STD_LOGIC;
        bulletA_x, bulletA_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        tankB_x, tankB_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        A_score : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        dead : OUT STD_LOGIC;

    );
    END COMPONENT inc_scoreA;
    
end architecture behavioral;