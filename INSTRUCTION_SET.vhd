library ieee;
use ieee.std_logic_1164.all;

package instruction_set is
	
	-- Carga y movimiento
	constant LDA_IMM: std_logic_vector(7 downto 0) := x"01"; -- Carga valor inmediato a acumulador
	constant LDA_MEM: std_logic_vector(7 downto 0) := x"02"; -- Carga valor de memoria a acumulador
	constant MOV_A  : std_logic_vector(7 downto 0) := x"03"; -- Mueve datos de un registro al acumulador
	constant MOV_R  : std_logic_vector(7 downto 0) := x"04"; -- Mueve datos del acumulador a un registro (RA, RB, ...)
	
	-- Aritméticas
	constant ADD    : std_logic_vector(7 downto 0) := x"10"; -- ACC = ACC + Reg
	constant SUBS   : std_logic_vector(7 downto 0) := x"11"; -- ACC = ACC - Reg
	constant MULT   : std_logic_vector(7 downto 0) := x"12"; -- ACC = ACC * Reg
	constant DIV    : std_logic_vector(7 downto 0) := x"13"; -- ACC = ACC / Reg
	constant ADD_IMM: std_logic_vector(7 downto 0) := x"14"; -- ACC = ACC + valor inmediato
	constant SUB_IMM: std_logic_vector(7 downto 0) := x"15"; -- ACC = ACC - valor inmediato
	
	-- Saltos
	constant JMP: std_logic_vector(7 downto 0) := x"30"; -- Salto incondicional a dirección
	constant BNZ: std_logic_vector(7 downto 0) := x"31"; -- Salto si no zero flag
	constant BNS: std_logic_vector(7 downto 0) := x"32"; -- Salto si no sign flag
	constant BNC: std_logic_vector(7 downto 0) := x"33"; -- Salto si no carry flag
	constant BNV: std_logic_vector(7 downto 0) := x"34"; -- Salto si no overflow flag
	
	constant BCE : std_logic_vector(7 downto 0) := x"35"; -- Salto si la bandera EQUAL
	constant BCG : std_logic_vector(7 downto 0) := x"36"; -- Salto si la bandera GREATHER
	constant BCL : std_logic_vector(7 downto 0) := x"37"; -- Salto si la bandera LESS
	constant BCGE: std_logic_vector(7 downto 0) := x"38"; -- Salto si la bandera GREATHER o EQUAL
	constant BCLE: std_logic_vector(7 downto 0) := x"39"; -- Salto si la bandera LESS o EQUAL
	
	-- Control
	constant CMP_IMM: std_logic_vector(7 downto 0) := x"40"; -- Compara ACC con valor inmediato
	constant SLEEP  : std_logic_vector(7 downto 0) := x"41"; -- Suspender ejecución por un tiempo
	constant ON_LED : std_logic_vector(7 downto 0) := x"42";
	constant OFF_LED: std_logic_vector(7 downto 0) := x"43";
	constant ON_LEDR: std_logic_vector(7 downto 0) := x"44";
	constant CMP_REG: std_logic_vector(7 downto 0) := x"45";
	constant DISPLAY: std_logic_vector(7 downto 0) := x"46";
	constant HALT   : std_logic_vector(7 downto 0) := x"FF"; -- Detener ejecución

end package instruction_set;
