LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;

ENTITY leddcd IS
	PORT (
		data_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		segments_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END ENTITY leddcd;

ARCHITECTURE data_flow OF leddcd IS
BEGIN

	segments_out <= "1000000" WHEN data_in = "0000" ELSE
		"1111001" WHEN data_in = "0001" ELSE
		"0100100" WHEN data_in = "0010" ELSE
		"0110000" WHEN data_in = "0011" ELSE
		"0011001" WHEN data_in = "0100" ELSE
		"0010010" WHEN data_in = "0101" ELSE
		"0000010" WHEN data_in = "0110" ELSE
		"1111000" WHEN data_in = "0111" ELSE
		"0000000" WHEN data_in = "1000" ELSE
		"0011000" WHEN data_in = "1001" ELSE
		"0001000" WHEN data_in = "1010" ELSE
		"0000011" WHEN data_in = "1011" ELSE
		"0100111" WHEN data_in = "1100" ELSE
		"0100001" WHEN data_in = "1101" ELSE
		"0000110" WHEN data_in = "1110" ELSE
		"0001110";

END ARCHITECTURE data_flow;