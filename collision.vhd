--This module detects whether there has been a collision between a tank and module
--and updates the score accordingly

LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

entity collision is 
port (
    clk, rst_n : in std_logic;
    A_tank_lb, A_tank_rb, A_tank_tb, A_tank_bb : in std_logic_vector(9 downto 0);
    B_tank_lb, B_tank_rb, B_tank_tb, B_tank_bb : in std_logic_vector(9 downto 0);
    A_bulletpos_x, A_bulletpos_y, B_bulletpos_x, B_bulletpos_y : in std_logic_vector(9 downto 0);
    A_hit, B_hit : out std_logic
);
end entity collision;

architecture behavioral_detection of collision is 
--signals of position vectors to ints
signal A_tank_lb_int : NATURAL;
signal A_tank_rb_int : NATURAL;
signal A_tank_tb_int : NATURAL;
signal A_tank_bb_int : NATURAL;
signal B_tank_lb_int : NATURAL;
signal B_tank_rb_int : NATURAL;
signal B_tank_tb_int : NATURAL;
signal B_tank_bb_int : NATURAL;

signal A_bulletpos_x_int : NATURAL;
signal A_bulletpos_y_int : NATURAL;
signal B_bulletpos_x_int : NATURAL;
signal B_bulletpos_y_int : NATURAL;

begin
    --conversion of position vectors to ints
    A_tank_lb_int <= to_integer(unsigned(A_tank_lb));
    A_tank_rb_int <= to_integer(unsigned(A_tank_rb));
    A_tank_tb_int <= to_integer(unsigned(A_tank_tb));
    A_tank_bb_int <= to_integer(unsigned(A_tank_bb));
    B_tank_lb_int <= to_integer(unsigned(B_tank_lb));
    B_tank_rb_int <= to_integer(unsigned(B_tank_rb));
    B_tank_tb_int <= to_integer(unsigned(B_tank_tb));
    B_tank_bb_int <= to_integer(unsigned(B_tank_bb));


    A_bulletpos_x_int <= to_integer(unsigned(A_bulletpos_x));
	A_bulletpos_y_int <= to_integer(unsigned(A_bulletpos_y));
    B_bulletpos_x_int <= to_integer(unsigned(B_bulletpos_x));
	B_bulletpos_y_int <= to_integer(unsigned(B_bulletpos_y));

    checkCollision : process(clk, rst_n) is  
    begin
        if (rst_n = '1') then 
            A_hit <= '0';
            B_hit <= '0';
        elsif (rising_edge(clk)) then 
            --check if bullet A hits tank B
            if 

            --check if bullet B hits tank A

        end if;

    end process checkCollision; 


end architecture behavioral_detection;