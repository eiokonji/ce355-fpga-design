LIBRARY STD;
LIBRARY IEEE;
--Additional standard or custom libraries go here
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;
USE work.calc_const.ALL;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY testbench IS
END ENTITY testbench;

ARCHITECTURE behavioral OF testbench IS
    --Entity (as component) and input ports (as signals) go here
    COMPONENT calculator IS
        PORT (--Inputs
            DIN1 : IN STD_LOGIC_VECTOR (DIN1_WIDTH - 1 DOWNTO 0);
            DIN2 : IN STD_LOGIC_VECTOR (DIN2_WIDTH - 1 DOWNTO 0);
            operation : IN STD_LOGIC_VECTOR (OP_WIDTH - 1 DOWNTO 0);
            --Outputs
            DOUT : OUT STD_LOGIC_VECTOR (DOUT_WIDTH - 1 DOWNTO 0);
            sign : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL din1_tb : STD_LOGIC_VECTOR (DIN1_WIDTH - 1 DOWNTO 0) := (others => '0');
    SIGNAL din2_tb : STD_LOGIC_VECTOR (DIN2_WIDTH - 1 DOWNTO 0) := (others => '0');
    SIGNAL op_tb : STD_LOGIC_VECTOR (OP_WIDTH - 1 DOWNTO 0) := (others => '0');
    SIGNAL dout_tb : STD_LOGIC_VECTOR (DOUT_WIDTH - 1 DOWNTO 0) := (others => '0');
    SIGNAL sign_tb : STD_LOGIC := '0';

BEGIN
--     --component declaration and stimuli processes go here
    dut : calculator
    PORT MAP(
        DIN1 => din1_tb,
        DIN2 => din2_tb,
        operation => op_tb,
        --Outputs
        DOUT => dout_tb,
        sign => sign_tb
    );

    PROCESS IS

        -- VARIABLE int: integer;
        CONSTANT ADD : std_logic_vector(OP_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(3,OP_WIDTH));
        CONSTANT MULTIPLY : std_logic_vector(OP_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(1,OP_WIDTH));
        CONSTANT SUBTRACT : std_logic_vector(OP_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(2,OP_WIDTH));
        -- subtype myvec is std_logic_vector(DIN1_WIDTH-1 downto 0);
        -- VARIABLE temp1 : STD_LOGIC_VECTOR(DIN1_WIDTH-1 DOWNTO 0);
        -- VARIABLE temp2 : STD_LOGIC_VECTOR(DIN2_WIDTH-1 DOWNTO 0);
        -- VARIABLE op : STD_LOGIC_VECTOR(OP_WIDTH-1 DOWNTO 0);
         VARIABLE char : character;
        -- VARIABLE index : INTEGER;
        -- variable i : integer;
        -- variable str : string (0 to 3);

        VARIABLE read_line : line; -- a buffer for what was read
        VARIABLE write_line : line; -- a buffer for what was written
        FILE infile : text OPEN read_mode IS "cal16.in";
        FILE outfile : text OPEN write_mode IS "cal16.out";
        variable temp1 : integer;
        variable temp2 : integer;


        -- function to_myvec(char : character) return myvec is
        --     begin
        --       return myvec(to_unsigned(character'pos(char), DIN1_WIDTH));
        -- end function;

    BEGIN
        WHILE NOT (endfile(infile)) LOOP
            -- read in both operands and operations
            readline(infile, read_line);
            read(read_line, temp1);
            din1_tb <= std_logic_vector(to_signed(temp1, DIN1_WIDTH));

            readline(infile, read_line);
            read(read_line, temp2);
            din2_tb <= std_logic_vector(to_signed(temp2, DIN2_WIDTH));
            
            -- write operand one
            write(write_line, temp1);
            write(write_line, STRING'(" "));

            readline(infile, read_line);
            read(read_line, char);

            -- write in the operation
            if (char = '+') THEN
                write(write_line, STRING'("+ "));
                op_tb <= std_logic_vector(to_unsigned(3,OP_WIDTH));                
            elsif (char = '*') then
                write(write_line, STRING'("* "));
                op_tb <= std_logic_vector(to_unsigned(1,OP_WIDTH)); 
            elsif (char = '-') then
                write(write_line, STRING'("- "));
                op_tb <= std_logic_vector(to_unsigned(2,OP_WIDTH)); 
            else
                write(write_line, STRING'("invalid"));
                op_tb <= std_logic_vector(to_unsigned(0,OP_WIDTH)); 
            end if;

            -- write operand two
            write(write_line, temp2);
            write(write_line, STRING'(" = "));

            WAIT FOR 5 ns;

            --calculator answer
            IF (sign_tb = '1') THEN
                write(write_line, STRING'("-"));
            END IF;
            write(write_line, to_integer(unsigned(dout_tb)));
            writeline (outfile, write_line);


        END LOOP;

        -- WAIT;
    END PROCESS;

END ARCHITECTURE behavioral;

        -- --checking positive values
        -- din1_tb <= std_logic_vector(to_signed(12, DIN1_WIDTH));
        -- din2_tb <= std_logic_vector(to_unsigned(4, DIN2_WIDTH));
        -- op_tb <= std_logic_vector(to_unsigned(0, OP_WIDTH));
        -- wait for 50ns;
        -- din1_tb <= std_logic_vector(to_unsigned(8, DIN1_WIDTH));
        -- din2_tb <= std_logic_vector(to_unsigned(4, DIN2_WIDTH));
        -- op_tb <= std_logic_vector(to_unsigned(1, OP_WIDTH));
        -- wait FOR 50ns;
        -- din1_tb <= std_logic_vector(to_unsigned(12, DIN1_WIDTH));
        -- din2_tb <= std_logic_vector(to_UNsigned(4, DIN2_WIDTH));
        -- op_tb <= std_logic_vector(to_unsigned(2, OP_WIDTH));
        -- wait for 50ns;

        -- --checking negative values/edge cases
        -- din1_tb <= std_logic_vector(to_signed(12, DIN1_WIDTH));
        -- din2_tb <= std_logic_vector(to_signed(-4, DIN2_WIDTH));
        -- op_tb <= std_logic_vector(to_signed(0, OP_WIDTH));
        -- wait for 50ns;
        -- din1_tb <= std_logic_vector(to_signed(-8, DIN1_WIDTH));
        -- din2_tb <= std_logic_vector(to_signed(4, DIN2_WIDTH));
        -- op_tb <= std_logic_vector(to_signed(1, OP_WIDTH));
        -- wait FOR 50ns;
        -- din1_tb <= std_logic_vector(to_signed(-12, DIN1_WIDTH));
        -- din2_tb <= std_logic_vector(to_signed(-4, DIN2_WIDTH));
        -- op_tb <= std_logic_vector(to_signed(1, OP_WIDTH));
        -- wait for 50ns;
        -- din1_tb <= std_logic_vector(to_signed(-12, DIN1_WIDTH));
        -- din2_tb <= std_logic_vector(to_signed(-4, DIN2_WIDTH));
        -- op_tb <= std_logic_vector(to_signed(2, OP_WIDTH));
        -- wait for 50ns;
        -- wait;

        

            -- IF (index = 1) THEN
            --     -- read(read_line, int);
            --     -- report "temp2 = " & character'val(int);
            --     -- temp2 := std_logic_vector(to_unsigned(int, 2));
            --     -- read(read_line, temp2); -- temp2 expects std_logic_vector type but reads char
            --     for i in read_line'range loop
                    

            --         read(read_line, char);                
            --     temp2 := std_logic_vector(RESIZE(signed(to_myvec(char)), DIN2_WIDTH));
            --     index := index + 1;
            --     din2_tb <= temp2;
            --     -- report "temp2 = " & integer'image(to_integer(unsigned(temp2)));
            -- ELSIF (index = 0) THEN
            --     -- read(read_line, temp1);
            --     read(read_line, char);                
            --     temp1 := std_logic_vector(RESIZE(signed(to_myvec(char)), DIN1_WIDTH));
            --     write(write_line, to_integer(signed(temp1)));
            --     write(write_line, STRING'(" "));
            --     index := index + 1;
            --     din1_tb <= temp1;
            -- ELSIF (index = 2) THEN
            --     -- read(read_line, temp1);
            --     read(read_line, char);                
            --     op := std_logic_vector(RESIZE(unsigned(to_myvec(char)), OP_WIDTH));
            --     -- write(write_line, op);
            --     if (op = ADD) THEN
            --         write(write_line, STRING'("+"));
            --     elsif (op = MULTIPLY) then
            --         write(write_line, STRING'("*"));
            --     elsif (op = SUBTRACT) then
            --         write(write_line, STRING'("-"));
            --     else
            --         write(write_line, STRING'("invalid"));
            --     end if;
            --     op_tb <= op;
            --     write(write_line, STRING'(" "));
            --     write(write_line, to_integer(signed(temp2)));

            --     WAIT FOR 50 ns;

            --     --calculator answer
            --     IF (sign_tb = '1') THEN
            --         write(write_line, STRING'("-"));
            --     END IF;
            --     write(write_line, to_integer(unsigned(dout_tb)));
            --     writeline (outfile, write_line);
            --     index := 0;
            --     dout_tb <= dout_tb;
            --     sign_tb <= sign_tb;