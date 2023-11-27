LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY ps2 IS
	PORT (
		keyboard_clk, keyboard_data, clock_50MHz,
		reset : IN STD_LOGIC;--, read : in std_logic;
		scan_readyo : OUT STD_LOGIC;
		hist3 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		hist2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		hist1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		hist0 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END ENTITY ps2;

ARCHITECTURE structural OF ps2 IS

	COMPONENT keyboard IS
		PORT (
			keyboard_clk, keyboard_data, clock_50MHz,
			reset, read : IN STD_LOGIC;
			scan_code : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			scan_ready : OUT STD_LOGIC);
	END COMPONENT keyboard;

	COMPONENT oneshot IS
		PORT (
			pulse_out : OUT STD_LOGIC;
			trigger_in : IN STD_LOGIC;
			clk : IN STD_LOGIC);
	END COMPONENT oneshot;

	SIGNAL scan2 : STD_LOGIC;
	SIGNAL scan_code2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL history3 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL history2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL history1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL history0 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL read : STD_LOGIC;

BEGIN

	u1 : keyboard PORT MAP(
		keyboard_clk => keyboard_clk,
		keyboard_data => keyboard_data,
		clock_50MHz => clock_50MHz,
		reset => reset,
		read => read,
		scan_code => scan_code2,
		scan_ready => scan2
	);

	pulser : oneshot PORT MAP(
		pulse_out => read,
		trigger_in => scan2,
		clk => clock_50MHz
	);

	scan_readyo <= scan2;

	hist0 <= history0;
	hist1 <= history1;
	hist2 <= history2;
	hist3 <= history3;

	a1 : PROCESS (scan2)
	BEGIN
		IF (rising_edge(scan2)) THEN
			history3 <= history2;
			history2 <= history1;
			history1 <= history0;
			history0 <= scan_code2;
		END IF;
	END PROCESS a1;

END ARCHITECTURE structural;
---------------------------------------------------------------