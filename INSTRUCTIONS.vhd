LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE instructions IS
  -- =======================================================
  -- SET DE INSTRUCCIONES
  -- =======================================================
  
  -- Carga y Movimiento
  CONSTANT CAR_INM : std_logic_vector(7 DOWNTO 0) := x"01"; -- Carga Inmediato
  CONSTANT CAR_MEM : std_logic_vector(7 DOWNTO 0) := x"02"; -- Carga de Memoria
  CONSTANT MOV_ACU : std_logic_vector(7 DOWNTO 0) := x"03"; -- Mover a Acumulador
  CONSTANT MOV_REG : std_logic_vector(7 DOWNTO 0) := x"04"; -- Mover a Registro

  -- Aritmética Básica
  CONSTANT SUM     : std_logic_vector(7 DOWNTO 0) := x"10";
  CONSTANT RES     : std_logic_vector(7 DOWNTO 0) := x"11";
  CONSTANT MUL     : std_logic_vector(7 DOWNTO 0) := x"12";
  CONSTANT DIV     : std_logic_vector(7 DOWNTO 0) := x"13";
  CONSTANT SUM_INM : std_logic_vector(7 DOWNTO 0) := x"14"; -- Suma Inmediata
  CONSTANT RES_INM : std_logic_vector(7 DOWNTO 0) := x"15"; -- Resta Inmediata

  -- Saltos y Control de Flujo
  CONSTANT SALT    : std_logic_vector(7 DOWNTO 0) := x"30"; -- Salto Incondicional
  CONSTANT SNZ     : std_logic_vector(7 DOWNTO 0) := x"31"; -- Salto si No Cero
  CONSTANT SNS     : std_logic_vector(7 DOWNTO 0) := x"32"; -- Salto si No Signo
  CONSTANT SNA     : std_logic_vector(7 DOWNTO 0) := x"33"; -- Salto si No Acarreo
  CONSTANT SND     : std_logic_vector(7 DOWNTO 0) := x"34"; -- Salto si No Desborde
  
  -- Saltos Condicionales (Comparaciones)
  CONSTANT SI_IG   : std_logic_vector(7 DOWNTO 0) := x"35"; -- Salto si Igual (Equal)
  CONSTANT SI_MY   : std_logic_vector(7 DOWNTO 0) := x"36"; -- Salto si Mayor (Greater)
  CONSTANT SI_MN   : std_logic_vector(7 DOWNTO 0) := x"37"; -- Salto si Menor (Less)
  CONSTANT SI_MYI  : std_logic_vector(7 DOWNTO 0) := x"38"; -- Salto si Mayor o Igual
  CONSTANT SI_MNI  : std_logic_vector(7 DOWNTO 0) := x"39"; -- Salto si Menor o Igual

  -- Comparaciones y Periféricos
  CONSTANT CMP_INM  : std_logic_vector(7 DOWNTO 0) := x"40"; -- Comparar Inmediato
  CONSTANT PAUSA    : std_logic_vector(7 DOWNTO 0) := x"41";  
  CONSTANT ENC_LED  : std_logic_vector(7 DOWNTO 0) := x"42"; 
  CONSTANT APA_LED  : std_logic_vector(7 DOWNTO 0) := x"43"; 
  CONSTANT ENC_LEDR : std_logic_vector(7 DOWNTO 0) := x"44"; -- Encender LED por Registro
  CONSTANT CMP_REG  : std_logic_vector(7 DOWNTO 0) := x"45"; -- Comparar Registro
  CONSTANT MOSTRAR  : std_logic_vector(7 DOWNTO 0) := x"46"; 

  -- Control del Sistema
  CONSTANT PARAR    : std_logic_vector(7 DOWNTO 0) := x"FF";
  
END PACKAGE instructions;