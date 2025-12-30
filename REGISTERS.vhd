library ieee;
use ieee.std_logic_1164.all;

package registers is

	-- Registros
	type REGISTERS is array (0 to 4) of std_logic_vector(15 downto 0);
	
	constant ACC  : integer := 0;
	constant REG_A: integer := 1;
	constant REG_B: integer := 2;
	constant REG_C: integer := 3;
	constant REG_D: integer := 4;
	
end package registers;