library IEEE;

use IEEE.std_logic_1164.all;
USE WORK.decoder.ALL;
USE WORK.calc_const.ALL;
--Additional standard or custom libraries go here

entity display_calc is
    port(
        --You will replace these with your actual inputs and outputs
		  --Inputs
        din1 : IN STD_LOGIC_VECTOR (DIN1_WIDTH - 1 DOWNTO 0);
        din2 : IN STD_LOGIC_VECTOR (DIN2_WIDTH - 1 DOWNTO 0);
        op_code : IN STD_LOGIC_VECTOR (OP_WIDTH - 1 DOWNTO 0);
        --Outputs
        s_out : OUT STD_LOGIC_VECTOR ((DOUT_WIDTH/4)*7-1 DOWNTO 0);
		  negative : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    );
end entity display_calc;

architecture structural of display_calc is
--Signals and components go here
component leddcd IS
    PORT (
        --You will replace these with your actual inputs and outputs
        data_in : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        segments_out : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    );
    
END component leddcd;
component calculator IS
    PORT (
        --Inputs
        DIN1 : IN STD_LOGIC_VECTOR (DIN1_WIDTH - 1 DOWNTO 0);
        DIN2 : IN STD_LOGIC_VECTOR (DIN2_WIDTH - 1 DOWNTO 0);
        operation : IN STD_LOGIC_VECTOR (OP_WIDTH - 1 DOWNTO 0);
        --Outputs
        DOUT : OUT STD_LOGIC_VECTOR (DOUT_WIDTH - 1 DOWNTO 0);
        sign : OUT STD_LOGIC
    );
END component calculator;

signal sign : STD_LOGIC;
signal dout : STD_LOGIC_VECTOR(DOUT_WIDTH-1 downto 0);


begin
--Structural design goes here
calc1 : calculator
port map (
	DIN1 => din1,
   DIN2 => din2,
   operation => op_code,
   --Outputs
   DOUT => dout,
   sign => sign
);

numbers: for i in 0 to (DOUT_WIDTH/4) - 1 generate begin
	dcd : leddcd
	port map(
		data_in => dout(4*(i+1)-1 downto 4*i),
		segments_out => s_out(7*(i+1)-1 downto 7*i)
	);
end generate;

--instantiate decoder for sign LED
--input sign, which is 1 bit

negative <= "0111111" when sign = '1' else
	"1111111";



end architecture structural;