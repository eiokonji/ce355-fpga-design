LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY score_led IS
    PORT (
        clock_50MHz, reset : IN STD_LOGIC;
        scoreA, scoreB : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        A_segments, B_segments : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    );
END ENTITY score_led;

ARCHITECTURE behavioral OF score_led IS
    COMPONENT leddcd IS
        PORT (
            data_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            segments_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT leddcd;

    SIGNAL resizedA, resizedB : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

    resizedA <= std_logic_vector(resize(unsigned(scoreA), 4));
    resizedB <= std_logic_vector(resize(unsigned(scoreB), 4));

    score_led_A : leddcd
    PORT MAP(
        data_in => resizedA,
        segments_out => A_segments
    );

    score_led_B : leddcd
    PORT MAP(
        data_in => resizedB,
        segments_out => B_segments
    );

END ARCHITECTURE behavioral;