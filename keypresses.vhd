-- This module returns the speed for each tank and if a bullet is fired based on keypresses.
-- speed levels: slow->1pt, med->5pt, fast->10pt

library STD;
library IEEE;
  use IEEE.std_logic_1164.all;
  use ieee.numeric_std.all;

entity keypresses is
  port (
    clock_50MHz, reset, start : in  STD_LOGIC;
    hist1, hist0              : in  STD_LOGIC_VECTOR(7 downto 0);
    speedA, speedB            : out STD_LOGIC_VECTOR(3 downto 0);
    bulletA, bulletB          : out std_logic
  );
end entity;

architecture behavioral of keypresses is
  type states is (idle, change_state);
  signal state, new_state : states;

  signal speedA_temp, speedB_temp     : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
  signal speedA_temp_n, speedB_temp_n : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

  signal bulletA_temp, bulletB_temp     : std_logic;
  signal bulletA_temp_n, bulletB_temp_n : std_logic;

  constant a        : STD_LOGIC_VECTOR(7 downto 0) := "00011100"; -- 0x1C, 28
  constant s        : STD_LOGIC_VECTOR(7 downto 0) := "00011011"; -- 0x1B, 27
  constant d        : STD_LOGIC_VECTOR(7 downto 0) := "00100011"; -- 0x23, 35
  constant j        : STD_LOGIC_VECTOR(7 downto 0) := "00111011"; -- 0x3B, 59
  constant k        : STD_LOGIC_VECTOR(7 downto 0) := "01000010"; -- 0X42, 66
  constant l        : STD_LOGIC_VECTOR(7 downto 0) := "01001011"; -- 0x4B, 75
  constant break    : STD_LOGIC_VECTOR(7 downto 0) := "11110000"; -- 0xF0, 240
  constant l_bullet : STD_LOGIC_VECTOR(7 downto 0) := "00010010"; -- 0x12, 18
  constant r_bullet : STD_LOGIC_VECTOR(7 downto 0) := "01011001"; -- 0x59, 89

begin

  clocked_process: process (clock_50MHz, reset) is
  begin
    if (reset = '1') then
      state <= idle;
      speedA_temp <= "0001";
      speedB_temp <= "0001";
      bulletA_temp <= '0';
      bulletB_temp <= '0';

    elsif (rising_edge(clock_50MHz)) then
      state <= new_state;
      speedA_temp <= speedA_temp_n;
      speedB_temp <= speedB_temp_n;
      bulletA_temp <= bulletA_temp_n;
      bulletB_temp <= bulletB_temp_n;

    end if;
  end process;

  change_speed_process: process (start, hist0, hist1) is
  begin
    -- default values for changing signals
    new_state <= state;
    speedA_temp_n <= speedA_temp;
    speedB_temp_n <= speedB_temp;
    bulletA_temp_n <= bulletA_temp;
    bulletB_temp_n <= bulletB_temp;

    case state is
      when idle =>
        if (start = '1') then
          new_state <= change_state;
        else
          new_state <= idle;
        end if;

      when change_state =>
        if (start = '1') then

          -- change speed of tank A
          if (unsigned(hist0) = unsigned(a) and unsigned(hist1) = unsigned(break)) then
            speedA_temp_n <= "0001";
          elsif (unsigned(hist0) = unsigned(s) and unsigned(hist1) = unsigned(break)) then
            speedA_temp_n <= "0101";
          elsif (unsigned(hist0) = unsigned(d) and unsigned(hist1) = unsigned(break)) then
            speedA_temp_n <= "1010";
          else
            speedA_temp_n <= speedA_temp;
          end if;

          -- fire bullet A
          if (unsigned(hist0) = unsigned(l_bullet) and unsigned(hist1) = unsigned(break)) then
            bulletA_temp_n <= '1';
          else
            bulletA_temp_n <= '0';
          end if;

          -- change tank B speed
          if (unsigned(hist0) = unsigned(j) and unsigned(hist1) = unsigned(break)) then
            speedB_temp_n <= "0001";
          elsif (unsigned(hist0) = unsigned(k) and unsigned(hist1) = unsigned(break)) then
            speedB_temp_n <= "0101";
          elsif (unsigned(hist0) = unsigned(l) and unsigned(hist1) = unsigned(break)) then
            speedB_temp_n <= "1010";
          else
            speedB_temp_n <= speedB_temp;
          end if;

          -- fire bullet B
          if (unsigned(hist0) = unsigned(r_bullet) and unsigned(hist1) = unsigned(break)) then
            bulletB_temp_n <= '1';
          else
            bulletB_temp_n <= '0';
          end if;
        end if;

    end case;
  end process;

  speedA  <= speedA_temp;
  speedB  <= speedB_temp;
  bulletA <= bulletA_temp;
  bulletB <= bulletB_temp;

end architecture;
