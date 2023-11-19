--This module renders tank A on the screen via VGA (in blue)
library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tankA is
	port(
			clk, ROM_clk, rst_n, video_on, eof 				: in std_logic;
			pixel_row, pixel_column						    : in std_logic_vector(9 downto 0);
			red_out, green_out, blue_out					: out std_logic_vector(7 downto 0)
		);
end entity tankA;

architecture behavioral_A of tankA is

constant color_red 	 	 : std_logic_vector(2 downto 0) := "000";
constant color_green	 : std_logic_vector(2 downto 0) := "001";
constant color_blue 	 : std_logic_vector(2 downto 0) := "010";
constant color_yellow 	 : std_logic_vector(2 downto 0) := "011";
constant color_magenta 	 : std_logic_vector(2 downto 0) := "100";
constant color_cyan 	 : std_logic_vector(2 downto 0) := "101";
constant color_black 	 : std_logic_vector(2 downto 0) := "110";
constant color_white	 : std_logic_vector(2 downto 0) := "111";
	
component colorROM is
	port
	(
		address		: in std_logic_vector (2 downto 0);
		clock		: in std_logic  := '1';
		q			: out std_logic_vector (23 downto 0)
	);
end component colorROM;

signal colorAddress : std_logic_vector (2 downto 0);
signal color        : std_logic_vector (23 downto 0);

signal pixel_row_A_int, pixel_column_A_int : natural;

begin

--------------------------------------------------------------------------------------------
	
	red_out <= color(23 downto 16);
	green_out <= color(15 downto 8);
	blue_out <= color(7 downto 0);

	pixel_row_A_int <= to_integer(unsigned(pixel_row));
	pixel_column_A_int <= to_integer(unsigned(pixel_column));
	
--------------------------------------------------------------------------------------------	
	
	colors : colorROM
		port map(colorAddress, ROM_clk, color);

--------------------------------------------------------------------------------------------	

	tankA_Draw : process(clk, rst_n) is
	
	begin
			
		if (rising_edge(clk)) then
                if (pixel_row_A_int >= 435 and pixel_row_A_int < 470 and pixel_column_A_int >= 280 and pixel_column_A_int < 360) then
                    colorAddress <= color_blue;

                elsif (pixel_row_A_int >= 10 and pixel_row_A_int < 45 and pixel_column_A_int >= 280 and pixel_column_A_int < 360) then
                    colorAddress <= color_red;
				else
				    colorAddress <= color_white;

				end if;			
		end if;
		
	end process tankA_Draw;	

--------------------------------------------------------------------------------------------
	
end architecture behavioral_A;		