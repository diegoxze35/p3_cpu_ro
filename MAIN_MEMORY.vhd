LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.instructions.ALL;

ENTITY MAIN_MEMORY IS
  PORT (
    clk : IN std_logic;
    addr : IN INTEGER RANGE 0 TO 255;
    dout : OUT std_logic_vector(15 DOWNTO 0)
  );
END ENTITY MAIN_MEMORY;

ARCHITECTURE Behavioral OF MAIN_MEMORY IS
  CONSTANT AX : std_logic_vector(7 downto 0) := x"00";
  CONSTANT BX : std_logic_vector(7 downto 0) := x"01";
  CONSTANT CX : std_logic_vector(7 downto 0) := x"02";
  CONSTANT DX : std_logic_vector(7 downto 0) := x"03";

  TYPE MEM IS ARRAY (0 TO 255) OF std_logic_vector(15 DOWNTO 0);
  
  CONSTANT w : INTEGER := 0;
  CONSTANT x : INTEGER := 1;
  CONSTANT y : INTEGER := 2;
  CONSTANT z : INTEGER := 3;

  CONSTANT main_memory : MEM := (
    -- VARIABLES
    0 => x"0064", -- W = 100
    1 => x"FFFF", -- X = -1
    2 => x"000F", -- Y = 15
    3 => x"001A", -- Z = 26
  
    -- PROGRAMA
    -- ECUACIÓN 1: 17X + 25Y - W/4
    4  => CAR_MEM & std_logic_vector(to_unsigned(x, 8)),
    5  => MOV_REG & BX,
    6  => CAR_INM & x"11", -- 17
    7  => MUL     & BX,
    8  => MOV_REG & CX,    -- Guardar 17X en CX
    9  => CAR_MEM & std_logic_vector(to_unsigned(y, 8)),
    10 => MOV_REG & BX,
    11 => CAR_INM & x"19", -- 25
    12 => MUL     & BX,
    13 => MOV_REG & BX,    -- Guardar 25Y en BX
    14 => MOV_ACU & CX,
    15 => SUM     & BX,    -- 17X + 25Y
    16 => MOV_REG & CX,
    17 => CAR_INM & x"04", -- 4
    18 => MOV_REG & BX,
    19 => CAR_MEM & std_logic_vector(to_unsigned(w, 8)),
    20 => DIV     & BX,    -- W / 4
    21 => MOV_REG & BX,
    22 => MOV_ACU & CX,
    23 => RES     & BX,    -- (17X + 25Y) - (W/4)
    24 => SALT    & std_logic_vector(to_unsigned(150, 8)), 

    -- ECUACIÓN 2
    25 => CAR_MEM & std_logic_vector(to_unsigned(x, 8)),
    26 => MOV_REG & BX,
    27 => MUL     & BX,    -- X^2
    28 => MOV_REG & BX,
    29 => CAR_INM & x"0A", -- 10
    30 => MUL     & BX,    -- 10 * X^2
    31 => MOV_REG & CX,
    32 => CAR_MEM & std_logic_vector(to_unsigned(x, 8)),
    33 => MOV_REG & BX,
    34 => CAR_INM & x"1E", -- 30
    35 => MUL     & BX,    -- 30 * X
    36 => MOV_REG & BX,
    37 => MOV_ACU & CX,
    38 => SUM     & BX,
    39 => MOV_REG & CX,
    40 => CAR_INM & x"02", -- 2
    41 => MOV_REG & BX,
    42 => CAR_MEM & std_logic_vector(to_unsigned(z, 8)),
    43 => DIV     & BX,    -- Z / 2
    44 => MOV_REG & BX,
    45 => MOV_ACU & CX,
    46 => RES     & BX,
    47 => SALT    & std_logic_vector(to_unsigned(150, 8)),

    -- ECUACIÓN 3
    48 => CAR_MEM & std_logic_vector(to_unsigned(x, 8)),
    49 => MOV_REG & BX,
    50 => MUL     & BX,
    51 => MOV_REG & BX,    -- X^2
    52 => CAR_MEM & std_logic_vector(to_unsigned(x, 8)),
    53 => MUL     & BX,
    54 => MOV_REG & BX,    -- X^3
    55 => CAR_INM & x"00",
    56 => RES     & BX,    -- -X^3
    57 => MOV_REG & CX,
    58 => CAR_INM & x"07",
    59 => MOV_REG & BX,
    60 => CAR_MEM & std_logic_vector(to_unsigned(z, 8)),
    61 => MUL     & BX,    -- 7*Z
    62 => MOV_REG & BX,
    63 => MOV_ACU & CX,
    64 => RES     & BX,    -- -X^3 - 7Z
    65 => MOV_REG & CX,
    66 => CAR_INM & x"0A",
    67 => MOV_REG & BX,
    68 => CAR_MEM & std_logic_vector(to_unsigned(w, 8)),
    69 => DIV     & BX,    -- W / 10
    70 => MOV_REG & BX,
    71 => MOV_ACU & CX,
    72 => SUM     & BX,
    73 => SALT    & std_logic_vector(to_unsigned(150, 8)),

    -- RUTINA DE LEDS
    150 => MOSTRAR & x"FF",
    151 => PAUSA   & std_logic_vector(to_unsigned(10, 8)),
    152 => CMP_INM & std_logic_vector(to_unsigned(100, 8)),
    153 => SI_MYI  & std_logic_vector(to_unsigned(162, 8)), -- >= 100
    154 => CMP_INM & std_logic_vector(to_unsigned(60, 8)),
    155 => SI_MYI  & std_logic_vector(to_unsigned(165, 8)), -- >= 60
    156 => CMP_INM & std_logic_vector(to_unsigned(25, 8)),
    157 => SI_MY   & std_logic_vector(to_unsigned(168, 8)), -- > 25
    158 => SI_IG   & std_logic_vector(to_unsigned(171, 8)), -- = 25
    159 => CMP_INM & std_logic_vector(to_unsigned(0, 8)),
    160 => SI_MYI  & std_logic_vector(to_unsigned(171, 8)), -- >= 0
    161 => SI_MN   & std_logic_vector(to_unsigned(174, 8)), -- < 0
    
    -- Configurar T (en CX)
    162 => CAR_INM & x"02", 
    163 => MOV_REG & CX,
    164 => SALT    & std_logic_vector(to_unsigned(176, 8)),
    
    165 => CAR_INM & x"03",
    166 => MOV_REG & CX,
    167 => SALT    & std_logic_vector(to_unsigned(176, 8)),
    
    168 => CAR_INM & x"04",
    169 => MOV_REG & CX,
    170 => SALT    & std_logic_vector(to_unsigned(176, 8)),
    
    171 => CAR_INM & x"01",
    172 => MOV_REG & CX,
    173 => SALT    & std_logic_vector(to_unsigned(176, 8)),
    
    174 => CAR_INM & x"05",
    175 => MOV_REG & CX,
    
    -- Ciclo de parpadeo
    176 => CAR_INM & x"00",
    177 => MOSTRAR & x"FF",
    178 => MOV_REG & DX,
    
    -- LOOP 1: Apagar LEDs
    179 => ENC_LED & std_logic_vector(to_unsigned(0, 8)),
    180 => APA_LED & std_logic_vector(to_unsigned(1, 8)),
    181 => APA_LED & std_logic_vector(to_unsigned(2, 8)),
    182 => APA_LED & std_logic_vector(to_unsigned(3, 8)),
    183 => APA_LED & std_logic_vector(to_unsigned(4, 8)),
    184 => CAR_INM & x"00",
    
    -- LOOP 2: Contador
    185 => PAUSA    & std_logic_vector(to_unsigned(1, 8)),
    186 => SUM_INM  & x"01",
    187 => ENC_LEDR & AX, -- Prender LED indicado por AX
    188 => CMP_REG  & CX, -- Comparar con T
    189 => SI_MN    & std_logic_vector(to_unsigned(185, 8)),
    
    -- Control final
    190 => MOV_ACU & DX,
    191 => SUM_INM & std_logic_vector(to_unsigned(1, 8)),
    192 => MOSTRAR & x"FF",
    193 => MOV_REG & DX,
    194 => CMP_INM & std_logic_vector(to_unsigned(30, 8)),
    195 => SI_MNI  & std_logic_vector(to_unsigned(179, 8)), -- Si <= 30 repetir
    196 => PARAR   & x"FF",
    
    OTHERS => PARAR & x"FF"
  );

BEGIN
  PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      dout <= main_memory(addr);
    END IF;
  END PROCESS;
END ARCHITECTURE Behavioral;