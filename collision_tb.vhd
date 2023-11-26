LIBRARY STD;
LIBRARY IEEE;
--Additional standard or custom libraries go here
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END ENTITY testbench;

ARCHITECTURE behavioral OF testbench IS
    --declare components
    COMPONENT clock_counter IS
        PORT (
            clk, rst_n : IN STD_LOGIC;
            game_tick : OUT STD_LOGIC
        );
    END COMPONENT clock_counter;

    COMPONENT tank_pos IS
        PORT (
            clk, rst, start : IN STD_LOGIC;
            speed : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            pos_x : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            updated_pos_x : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    END COMPONENT tank_pos;

    COMPONENT bullet_pos IS
        PORT (
            clk, rst, start : IN STD_LOGIC;
            direction, collision, fired : IN STD_LOGIC;
            speed : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            tank_x, tank_y, bullet_x, bullet_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            updated_bullet_x, updated_bullet_y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            active : OUT STD_LOGIC;
        );
    END COMPONENT bullet_pos;

    COMPONENT collision IS
        PORT (
            clk, rst_n : IN STD_LOGIC;
            A_tank_lb, A_tank_rb, A_tank_tb, A_tank_bb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            B_tank_lb, B_tank_rb, B_tank_tb, B_tank_bb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            A_bullet_lb, A_bullet_rb, A_bullet_tb, A_bullet_bb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            B_bullet_lb, B_bullet_rb, B_bullet_tb, B_bullet_bb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            A_hit, B_hit : OUT STD_LOGIC
        );
    END COMPONENT collision;

    --declare signals for test bench


BEGIN

    --instantiate clock

END ARCHITECTURE behavioral;