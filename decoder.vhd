library IEEE;
use IEEE.std_logic_1164.all;
--Additional standard or custom libraries go here if needed

package decoder is
    COMPONENT leddcd is
        PORT( 
            --enter the port declaration of your led decoder here
            data_in : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            segments_out : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
        );
    end COMPONENT;

    -- For each module, which you want to add to this package, you will
    -- place their COMPONENT declarations here one by one, in this case we
    -- just have one module


end package decoder;

package body decoder is
--Subroutine declarations (if there are any such as functions and procedures)
-- go here
end package body decoder;