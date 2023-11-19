--This module manipulates the horizontal position of tank A (pixel_column_A) on the screen

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--inputs: clock, reset, speed, direction
--outputs: (x, y) aka (pixel_row, pixel_column) position of tankA
entity tankA_pos is
	port(
			clk, rst_n, direction 				: in std_logic;
            speed : in std_logic_vector(1 downto 0);
			pixel_row_A, pixel_column_A						    : out std_logic_vector(9 downto 0)
		);
end entity tankA_pos;

--need a counter to increment position based on 50 Hz
--collision detection with screen boundaries
--modify pixel_column_A
--need the speed 

--declare signals
signal pixel_row_A_int, pixel_column_A_int : natural;
signal left_bound : natural := 0;
signal right_bound : natural := 640;


-- constant speed1 : natural := 5;
-- constant speed2 : natural := 10;
-- constant speed3 : natural := 30;

constant speed1 : std_logic_vector := (others => '0');
constant speed2 : std_logic_vector := (0 => '1', others => '0');
constant speed3 : std_logic_vector := (1 => '1', others => '0');


architecture behavioral of tankA_pos is 
--declarative region
signal tank_speed : natural;

begin
    pixel_column_A_int <= to_integer(unsigned(pixel_column_A));

    if (speed = speed1) then
        tank_speed <= 5;
    elsif (speed = speed2) then
        tank_speed <= 10;
    elsif (speed = speed3) then
        tank_speed <= 30;
    else 
        tank_speed <= 0;
    end if;

    if (direction = '1') then
        tank_speed <= tank_speed * -1;
    end if;

    tankA_pos : process (clk, rst_n) is 
    begin
        if (rising_edge(clk)) then
            --if tank is within screen boundaries
            if (pixel_column_A_int >= left_bound and pixel_column_A_int < right_bound) then 
                pixel_column_A_int <= pixel_column_A_int + tank_speed;

            --if tank exceeds boundaries, flip direction
            elsif (pixel_column_A_int < left_bound or pixel_column_A_int >= right_bound) then
                direction <= not direction;
            end if;
        end if;

    end process tankA_pos;

    pixel_column_A <= std_logic_vector(pixel_column_A_int);

end architecture behavioral;
