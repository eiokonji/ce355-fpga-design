-- This module returns the speed for each tank and if a bullet is fired based on keypresses.
-- speed levels: slow->1pt, med->5pt, fast->10pt

LIBRARY STD;
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY keypresses IS
  PORT (
    clock_50MHz, reset, start : IN STD_LOGIC;
    hist2, hist1, hist0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    speedA, speedB : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    bulletA, bulletB : OUT STD_LOGIC
  );
END ENTITY;

ARCHITECTURE behavioral OF keypresses IS
  TYPE states IS (idle, change_state);
  SIGNAL state, new_state : states;

  SIGNAL speedA_temp, speedB_temp : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL speedA_temp_n, speedB_temp_n : STD_LOGIC_VECTOR(3 DOWNTO 0);

  SIGNAL bulletA_temp, bulletB_temp : STD_LOGIC;
  SIGNAL bulletA_temp_n, bulletB_temp_n : STD_LOGIC;

  CONSTANT break : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11110000"; -- 0xF0, 240
  CONSTANT a : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00011100"; -- 0x1C, 28
  CONSTANT s : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00011011"; -- 0x1B, 27
  CONSTANT d : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00100011"; -- 0x23, 35
  CONSTANT l_bullet : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00010010"; -- 0x12, 18
  CONSTANT j : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00111011"; -- 0x3B, 59
  CONSTANT k : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000010"; -- 0X42, 66
  CONSTANT l : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01001011"; -- 0x4B, 75
  CONSTANT r_bullet : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01011001"; -- 0x59, 89

BEGIN

  clocked_process : PROCESS (clock_50MHz, reset) IS
  BEGIN
    IF (reset = '1') THEN
      state <= idle;
      speedA_temp <= "0001";
      speedB_temp <= "0001";
      bulletA_temp <= '0';
      bulletB_temp <= '0';

    ELSIF (rising_edge(clock_50MHz)) THEN
      state <= new_state;
      speedA_temp <= speedA_temp_n;
      speedB_temp <= speedB_temp_n;
      bulletA_temp <= bulletA_temp_n;
      bulletB_temp <= bulletB_temp_n;

    END IF;
  END PROCESS;

  change_speed_process : PROCESS (start, hist0, hist1, hist2, state, speedA_temp, speedB_temp, bulletA_temp, bulletB_temp ) IS
  BEGIN
    -- default values for changing signals
    new_state <= state;
    speedA_temp_n <= speedA_temp;
    speedB_temp_n <= speedB_temp;
    bulletB_temp_n <= '0';
 	 bulletA_temp_n <= '0';

    CASE state IS
      WHEN idle =>
        IF (start = '1') THEN
          new_state <= change_state;
        ELSE
          new_state <= idle;
        END IF;

      WHEN change_state =>
          -- change speed of tank A
          IF (unsigned(hist0) = unsigned(a) AND unsigned(hist1) = unsigned(break)) THEN
            speedA_temp_n <= "0001";
          ELSIF (unsigned(hist0) = unsigned(s) AND unsigned(hist1) = unsigned(break)) THEN
            speedA_temp_n <= "0101";
          ELSIF (unsigned(hist0) = unsigned(d) AND unsigned(hist1) = unsigned(break)) THEN
            speedA_temp_n <= "1010";
          END IF;

          -- fire bullet A
          IF (unsigned(hist0) = unsigned(l_bullet) AND unsigned(hist1) = unsigned(break)) THEN -- and unsigned(hist2) = unsigned(l_bullet)) THEN
            bulletA_temp_n <= '1';
          END IF;

          -- change tank B speed
          IF (unsigned(hist0) = unsigned(j) AND unsigned(hist1) = unsigned(break)) THEN
            speedB_temp_n <= "0001";
          ELSIF (unsigned(hist0) = unsigned(k) AND unsigned(hist1) = unsigned(break)) THEN
            speedB_temp_n <= "0101";
          ELSIF (unsigned(hist0) = unsigned(l) AND unsigned(hist1) = unsigned(break)) THEN
            speedB_temp_n <= "1010";
          END IF;

          -- fire bullet B
          IF (unsigned(hist0) = unsigned(r_bullet) AND unsigned(hist1) = unsigned(break)) THEN
            bulletB_temp_n <= '1';
          END IF;
			 
			 new_state <= idle;

    END CASE;
  END PROCESS;

  speedA <= speedA_temp;
  speedB <= speedB_temp;
  bulletA <= bulletA_temp;
  bulletB <= bulletB_temp;

END ARCHITECTURE;