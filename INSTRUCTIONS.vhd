LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
PACKAGE instructions IS
  -- Carga y movimiento
  CONSTANT LDA_IMM : std_logic_vector(7 DOWNTO 0) := x"01"; -- Carga valor inmediato a acumulador
  CONSTANT LDA_MEM : std_logic_vector(7 DOWNTO 0) := x"02"; -- Carga valor de memoria a acumulador
  CONSTANT MOV_A : std_logic_vector(7 DOWNTO 0) := x"03"; -- Mueve datos de un registro al acumulador
  CONSTANT MOV_R : std_logic_vector(7 DOWNTO 0) := x"04"; -- Mueve datos del acumulador a un registro (RA, RB, ...)
  -- Aritméticas
  CONSTANT ADD : std_logic_vector(7 DOWNTO 0) := x"10"; -- ACC = ACC + Reg
  CONSTANT SUBS : std_logic_vector(7 DOWNTO 0) := x"11"; -- ACC = ACC - Reg
  CONSTANT MULT : std_logic_vector(7 DOWNTO 0) := x"12"; -- ACC = ACC * Reg
  CONSTANT DIV : std_logic_vector(7 DOWNTO 0) := x"13"; -- ACC = ACC / Reg
  CONSTANT ADD_IMM : std_logic_vector(7 DOWNTO 0) := x"14"; -- ACC = ACC + valor inmediato
  CONSTANT SUB_IMM : std_logic_vector(7 DOWNTO 0) := x"15"; -- ACC = ACC - valor inmediato
  -- Saltos
  CONSTANT JMP : std_logic_vector(7 DOWNTO 0) := x"30"; -- Salto incondicional a dirección
  CONSTANT BNZ : std_logic_vector(7 DOWNTO 0) := x"31"; -- Salto si no zero flag
  CONSTANT BNS : std_logic_vector(7 DOWNTO 0) := x"32"; -- Salto si no sign flag
  CONSTANT BNC : std_logic_vector(7 DOWNTO 0) := x"33"; -- Salto si no carry flag
  CONSTANT BNV : std_logic_vector(7 DOWNTO 0) := x"34"; -- Salto si no overflow flag
  CONSTANT BCE : std_logic_vector(7 DOWNTO 0) := x"35"; -- Salto si la bandera EQUAL
  CONSTANT BCG : std_logic_vector(7 DOWNTO 0) := x"36"; -- Salto si la bandera GREATHER
  CONSTANT BCL : std_logic_vector(7 DOWNTO 0) := x"37"; -- Salto si la bandera LESS
  CONSTANT BCGE : std_logic_vector(7 DOWNTO 0) := x"38"; -- Salto si la bandera GREATHER o EQUAL
  CONSTANT BCLE : std_logic_vector(7 DOWNTO 0) := x"39"; -- Salto si la bandera LESS o EQUAL
  -- Control
  CONSTANT CMP_IMM : std_logic_vector(7 DOWNTO 0) := x"40"; -- Compara ACC con valor inmediato
  CONSTANT DELAY : std_logic_vector(7 DOWNTO 0) := x"41"; -- Suspender ejecución por un tiempo
  CONSTANT ON_LED : std_logic_vector(7 DOWNTO 0) := x"42";
  CONSTANT OFF_LED : std_logic_vector(7 DOWNTO 0) := x"43";
  CONSTANT ON_LEDR : std_logic_vector(7 DOWNTO 0) := x"44";
  CONSTANT CMP_REG : std_logic_vector(7 DOWNTO 0) := x"45";
  CONSTANT PRINT : std_logic_vector(7 DOWNTO 0) := x"46";
  CONSTANT HALT : std_logic_vector(7 DOWNTO 0) := x"FF"; -- Detener ejecución
END PACKAGE instructions;