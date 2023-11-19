LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY ps2_led IS
    PORT (
        keyboard_clk, keyboard_data, clock_50MHz,
        reset : IN STD_LOGIC;
        h0_segments : OUT STD_LOGIC_VECTOR ((8/4) * 7 - 1 DOWNTO 0);
        h1_segments : OUT STD_LOGIC_VECTOR ((8/4) * 7 - 1 DOWNTO 0);
        h2_segments : OUT STD_LOGIC_VECTOR ((8/4) * 7 - 1 DOWNTO 0);
        h3_segments : OUT STD_LOGIC_VECTOR ((8/4) * 7 - 1 DOWNTO 0)
    );
END ENTITY ps2_led;

ARCHITECTURE structural OF ps2_led IS
    COMPONENT ps2 IS
        PORT (
            keyboard_clk, keyboard_data, clock_50MHz,
            reset : IN STD_LOGIC;
            scan_code : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            scan_readyo : OUT STD_LOGIC;
            hist3 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            hist2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            hist1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            hist0 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT ps2;

    COMPONENT leddcd IS
        PORT (
            data_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            segments_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT leddcd;

    SIGNAL scan_code : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL scan_readyo : STD_LOGIC;
    SIGNAL hist3 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL hist2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL hist1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL hist0 : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

    ps2_1 : ps2
    PORT MAP(
        keyboard_clk => keyboard_clk,
        keyboard_data => keyboard_data,
        clock_50MHz => clock_50MHz,
        reset => reset,
        scan_code => scan_code,
        scan_readyo => scan_readyo,
        hist3 => hist3,
        hist2 => hist2,
        hist1 => hist1,
        hist0 => hist0
    );

    h0 : FOR i IN 0 TO 1 GENERATE BEGIN
        h0_dcd : leddcd PORT MAP(
            data_in => hist0(4 * (i + 1) - 1 DOWNTO 4 * i),
            segments_out => h0_segments(7 * (i + 1) - 1 DOWNTO 7 * i)
        );
    END GENERATE;

    h1 : FOR i IN 0 TO 1 GENERATE BEGIN
        h1_dcd : leddcd PORT MAP(
            data_in => hist1(4 * (i + 1) - 1 DOWNTO 4 * i),
            segments_out => h1_segments(7 * (i + 1) - 1 DOWNTO 7 * i)
        );
    END GENERATE;

    h2 : FOR i IN 0 TO 1 GENERATE BEGIN
        h2_dcd : leddcd PORT MAP(
            data_in => hist2(4 * (i + 1) - 1 DOWNTO 4 * i),
            segments_out => h2_segments(7 * (i + 1) - 1 DOWNTO 7 * i)
        );
    END GENERATE;

    h3 : FOR i IN 0 TO 1 GENERATE BEGIN
        h3_dcd : leddcd PORT MAP(
            data_in => hist3(4 * (i + 1) - 1 DOWNTO 4 * i),
            segments_out => h3_segments(7 * (i + 1) - 1 DOWNTO 7 * i)
        );
    END GENERATE;

END ARCHITECTURE structural;