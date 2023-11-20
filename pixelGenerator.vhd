library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pixelGenerator is
	port(
			clk, ROM_clk, rst_n, video_on, eof 				: in std_logic;
			pixel_row, pixel_column						    : in std_logic_vector(9 downto 0);
			A_lb, A_rb, A_tb, A_bb          : in std_logic_vector(9 downto 0);
			B_lb, B_rb, B_tb, B_bb          : in std_logic_vector(9 downto 0);
			red_out, green_out, blue_out					: out std_logic_vector(7 downto 0)
		);
end entity pixelGenerator;

architecture behavioral of pixelGenerator is

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

signal pixel_row_int, pixel_column_int : natural;
signal A_lbound, A_rbound, A_tbound, A_bbound : natural;
signal B_lbound, B_rbound, B_tbound, B_bbound : natural;

begin

--------------------------------------------------------------------------------------------
	
	red_out <= color(23 downto 16);
	green_out <= color(15 downto 8);
	blue_out <= color(7 downto 0);

	pixel_row_int <= to_integer(unsigned(pixel_row));
	pixel_column_int <= to_integer(unsigned(pixel_column));

	A_lbound <= to_integer(unsigned(A_lb));
	A_rbound <= to_integer(unsigned(A_rb));
	A_tbound <= to_integer(unsigned(A_tb));
	A_bbound <= to_integer(unsigned(A_bb));

	B_lbound <= to_integer(unsigned(B_lb));
	B_rbound <= to_integer(unsigned(B_rb));
	B_tbound <= to_integer(unsigned(B_tb));
	B_bbound <= to_integer(unsigned(B_bb));
	
--------------------------------------------------------------------------------------------	
	
	colors : colorROM
		port map(colorAddress, ROM_clk, color);

--------------------------------------------------------------------------------------------	

	pixelDraw : process(clk, rst_n) is
	
	begin
			
		if (rising_edge(clk)) then
				if (pixel_row_int >= A_tbound and pixel_row_int < A_bbound and pixel_column_int >= A_lbound and pixel_column_int < A_rbound) then
                    colorAddress <= color_blue;

                elsif (pixel_row_int >= B_tbound and pixel_row_int < B_bbound and pixel_column_int >= B_lbound and pixel_column_int < B_rbound) then
                    colorAddress <= color_red;
				else
				    colorAddress <= color_white;

				end if;			

			
		end if;
		
	end process pixelDraw;	

--------------------------------------------------------------------------------------------
	
end architecture behavioral;		