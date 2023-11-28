--This module has the PLL (phase locked loop) to optimize the design's timing

LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

entity my_PLL is
    port (
        clk_50 : in std_logic;
        clk_out : out std_logic
    );
end entity my_PLL;

architecture behavioral of my_PLL is 
begin
    --
end architecture behavioral;