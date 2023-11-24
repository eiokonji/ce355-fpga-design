--This module detects whether there has been a collision between a tank and module
--and outputs signal indicating hit/not hit to be passed to the scoring module

LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY collision IS
    PORT (
        clk, rst_n : IN STD_LOGIC;
        A_tank_lb, A_tank_rb, A_tank_tb, A_tank_bb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        B_tank_lb, B_tank_rb, B_tank_tb, B_tank_bb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        A_bullet_lb, A_bullet_rb, A_bullet_tb, A_bullet_bb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        B_bullet_lb, B_bullet_rb, B_bullet_tb, B_bullet_bb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        A_hit, B_hit : OUT STD_LOGIC
    );
END ENTITY collision;

ARCHITECTURE behavioral_detection OF collision IS
    --signals of position integers
    SIGNAL A_tank_lb_int, A_tank_rb_int, A_tank_tb_int, A_tank_bb_int : NATURAL;
    SIGNAL B_tank_lb_int, B_tank_rb_int, B_tank_tb_int, B_tank_bb_int : NATURAL;
    SIGNAL A_bullet_lb_int, A_bullet_rb_int, A_bullet_tb_int, A_bullet_bb_int : NATURAL;
    SIGNAL B_bullet_lb_int, B_bullet_rb_int, B_bullet_tb_int, B_bullet_bb_int : NATURAL;

    --combination signals
    SIGNAL A_hit_c, B_hit_c : STD_LOGIC := '0';

    --initialize states
    TYPE states IS (idle, play);
    SIGNAL state, next_state : states;

BEGIN
    --conversion of position vectors to ints
    A_tank_lb_int <= to_integer(unsigned(A_tank_lb));
    A_tank_rb_int <= to_integer(unsigned(A_tank_rb));
    A_tank_tb_int <= to_integer(unsigned(A_tank_tb));
    A_tank_bb_int <= to_integer(unsigned(A_tank_bb));
    B_tank_lb_int <= to_integer(unsigned(B_tank_lb));
    B_tank_rb_int <= to_integer(unsigned(B_tank_rb));
    B_tank_tb_int <= to_integer(unsigned(B_tank_tb));
    B_tank_bb_int <= to_integer(unsigned(B_tank_bb));

    A_bullet_lb_int <= to_integer(unsigned(A_bullet_lb));
    A_bullet_rb_int <= to_integer(unsigned(A_bullet_rb));
    A_bullet_tb_int <= to_integer(unsigned(A_bullet_tb));
    A_bullet_bb_int <= to_integer(unsigned(A_bullet_bb));
    B_bullet_lb_int <= to_integer(unsigned(B_bullet_lb));
    B_bullet_lb_int <= to_integer(unsigned(B_bullet_rb));
    B_bullet_lb_int <= to_integer(unsigned(B_bullet_tb));
    B_bullet_lb_int <= to_integer(unsigned(B_bullet_bb));

    clockProcess : PROCESS (clk, rst_n) IS
    BEGIN
        IF (rst_n = '1') THEN
            state <= idle;
            A_hit <= '0';
            B_hit <= '0';
        ELSIF (rising_edge(clk)) THEN
            state <= next_state;
            A_hit <= A_hit_c;
            B_hit <= B_hit_c;
        END IF;
    END PROCESS clockProcess;

    checkCollision : PROCESS (A_tank_lb_int, A_tank_rb_int, A_tank_tb_int, A_tank_bb_int, B_tank_lb_int, B_tank_rb_int, B_tank_tb_int, B_tank_bb_int,A_bullet_tb_int, A_bullet_bb_int, B_bullet_tb, B_bullet_bb) IS
    BEGIN
        --initialize defaults
        next_state <= state;
        A_hit_c <= A_hit;
        B_hit_c <= B_hit;

        CASE state IS
            WHEN idle =>
                IF (start = '1') THEN
                    next_state <= play;
                END IF;

            WHEN play =>
                --check if tank B has been hit
                IF (A_bullet_bb_int >= B_tank_tb_int) THEN
                    IF (A_bullet_lb_int >= B_tank_lb_int AND A_bullet_rb_int <= B_tank_rb_int) THEN
                        B_hit_c <= '1';
                    ELSIF (A_bullet_lb_int >= B_tank_lb_int AND ((A_bullet_lb_int + 10) <= (B_tank_rb_int + 9))) THEN
                        B_hit_c <= '1';
                    ELSIF ((A_bullet_rb_int <= B_tank_rb_int) AND ((A_bullet_rb_int - 10) >= (B_tank_lb_int - 9))) THEN
                        B_hit_c <= '1';
                    ELSE
                        B_hit_c <= '0';
                    END IF;
                ELSE
                    B_hit_c <= '0';
                END IF;

                --check if tank A has been hit
                IF (B_bullet_tb_int <= A_tank_bb_int) THEN
                    IF (B_bullet_lb_int >= A_tank_lb_int AND B_bullet_rb_int <= A_tank_rb_int) THEN
                        A_hit_c <= '1';
                    ELSIF (B_bullet_lb_int >= A_tank_lb_int AND ((B_bullet_lb_int + 10) <= (A_tank_rb_int + 9))) THEN
                        A_hit_c <= '1';
                    ELSIF ((B_bullet_rb_int <= A_tank_rb_int) AND ((B_bullet_rb_int - 10) >= (A_tank_lb_int - 9))) THEN
                        A_hit_c <= '1';
                    ELSE
                        A_hit_c <= '0';
                    END IF;
                ELSE
                    A_hit_c <= '0';
                END IF;

        END CASE;

    END PROCESS checkCollision;
END ARCHITECTURE behavioral_detection;