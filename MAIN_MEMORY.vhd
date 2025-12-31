LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.instructions.ALL;

ENTITY MAIN_MEMORY IS
  PORT (
    clk : IN std_logic;
    addr : IN INTEGER RANGE 0 TO 255;
    dout : OUT std_logic_vector(15 DOWNTO 0) -- Dato leído
  );
END ENTITY MAIN_MEMORY;

ARCHITECTURE Behavioral OF MAIN_MEMORY IS

  CONSTANT AX : std_logic_vector(7 downto 0) := x"00";
  CONSTANT BX : std_logic_vector(7 downto 0) := x"01";
  CONSTANT CX : std_logic_vector(7 downto 0) := x"02";
  CONSTANT DX : std_logic_vector(7 downto 0) := x"03";

  TYPE MEM IS ARRAY (0 TO 255) OF std_logic_vector(15 DOWNTO 0);
  
  -- Definición de direcciones de variables (Simplificadas)
  CONSTANT w : INTEGER := 0;
  CONSTANT x : INTEGER := 1;
  CONSTANT y : INTEGER := 2;
  CONSTANT z : INTEGER := 3;
  
  SIGNAL main_memory : MEM := (
  
    -- ==========================================
    -- VARIABLES
    -- ==========================================
    0 => x"0064", -- W = 100 (dir 0)
    1 => x"FFFF", -- X = -1  (dir 1)
    2 => x"000F", -- Y = 15  (dir 2)
    3 => x"001A", -- Z = 26  (dir 3)
  
    -- ==========================================
    -- INSTRUCCIONES
    -- ==========================================

    -- ECUACIÓN 1 (Indices desplazados +4 respecto al original)
    4  => LDA_MEM & std_logic_vector(to_unsigned(x, 8)),
    5  => MOV_R & BX,
    6  => LDA_IMM & x"11", -- 17
    7  => MULT & BX, -- AX = AX * BX
    8  => MOV_R & CX, -- CX <- AX (17X)
    9  => LDA_MEM & std_logic_vector(to_unsigned(y, 8)), -- AX <- Y
    10 => MOV_R & BX,
    11 => LDA_IMM & x"19", -- 25
    12 => MULT & BX,
    13 => MOV_R & BX, -- BX <- 25Y
    14 => MOV_A & CX,
    15 => ADD & BX, -- 17X + 25Y -> AX
    16 => MOV_R & CX, -- CX <- 17X + 25Y
    17 => LDA_IMM & x"04", -- 4
    18 => MOV_R & BX, -- BX <- 4
    19 => LDA_MEM & std_logic_vector(to_unsigned(w, 8)),
    20 => DIV & BX, -- AX <- W / 4
    21 => MOV_R & BX, -- BX <- W / 4
    22 => MOV_A & CX,
    23 => SUBS & BX,
    24 => JMP & std_logic_vector(to_unsigned(150, 8)), -- Salto aL programa de los leds
    -- FIN ECUACIÓN 1

    -- ECUACIÓN 2
    25 => LDA_MEM & std_logic_vector(to_unsigned(x, 8)),
    26 => MOV_R & BX, -- BX <- X
    27 => MULT & BX, -- AX <- X * X
    28 => MOV_R & BX, -- BX <- X^2
    29 => LDA_IMM & x"0A", -- 10
    30 => MULT & BX, -- AX <- 10 * X^2
    31 => MOV_R & CX, -- CX <- 10 * X^2
    32 => LDA_MEM & std_logic_vector(to_unsigned(x, 8)), -- AX <- X
    33 => MOV_R & BX, -- BX <- X
    34 => LDA_IMM & x"1E", -- 30
    35 => MULT & BX, -- AX <- 30 * X
    36 => MOV_R & BX, -- BX <- 30 * X
    37 => MOV_A & CX, -- AX <- CX (10 * X^2)
    38 => ADD & BX, -- AX <- 10 * X^2 + 30 * X
    39 => MOV_R & CX, -- AX <- ACC
    40 => LDA_IMM & x"02", -- 2
    41 => MOV_R & BX, -- BX <- 2
    42 => LDA_MEM & std_logic_vector(to_unsigned(z, 8)), -- AX <- Z
    43 => DIV & BX, -- AX <- Z / BX (2)
    44 => MOV_R & BX, -- BX <- Z / 2
    45 => MOV_A & CX, -- AX <- CX (10 * X^2 + 30 * X)
    46 => SUBS & BX,
    47 => JMP & std_logic_vector(to_unsigned(150, 8)), -- Salto a rutina de leds
    -- FIN ECUACIÓN 2

    -- ECUACIÓN 3
    48 => LDA_MEM & std_logic_vector(to_unsigned(x, 8)), -- AX <- X
    49 => MOV_R & BX, -- BC <- X
    50 => MULT & BX, -- AX <- X * X
    51 => MOV_R & BX, -- BX <- ACC (X^2)
    52 => LDA_MEM & std_logic_vector(to_unsigned(x, 8)), -- AX <- X
    53 => MULT & BX, -- AX <- X * X^2
    54 => MOV_R & BX, -- BX <- AX (X^3)
    55 => LDA_IMM & x"00", -- 0
    56 => SUBS & BX, -- AX <- 0 - X^3
    57 => MOV_R & CX, -- AX <- -X^3
    58 => LDA_IMM & x"07", -- 7
    59 => MOV_R & BX, -- BX <- 7
    60 => LDA_MEM & std_logic_vector(to_unsigned(z, 8)), -- AX <- Z
    61 => MULT & BX, -- AX <- Z * 7
    62 => MOV_R & BX, -- BX <- 7*Z
    63 => MOV_A & CX, -- AX <- CX -(X^3)
    64 => SUBS & BX, -- AX <- -(X^3) - 7*Z
    65 => MOV_R & CX, -- AX <- -(X^3) - 7*Z
    66 => LDA_IMM & x"0A",
    67 => MOV_R & BX, -- BX <- 10
    68 => LDA_MEM & std_logic_vector(to_unsigned(w, 8)), -- AX <- W
    69 => DIV & BX, -- AX <- W / REG_B (10)
    70 => MOV_R & BX, -- BX <- W/10
    71 => MOV_A & CX, -- AX <- CX (-(X^3) - (7*Z))
    72 => ADD & BX, -- AX <- -(X^3) - 7*Z + W / 10
    73 => JMP & std_logic_vector(to_unsigned(150, 8)), -- Salto a rutina de leds
    -- FIN ECUACIÓN 3

    -- ==========================================
    -- PROCESO DE LEDS
    -- ==========================================
    150 => PRINT & x"FF",
    151 => DELAY & std_logic_vector(to_unsigned(10, 8)), -- dormir 10 segundos
    152 => CMP_IMM & std_logic_vector(to_unsigned(100, 8)), -- comparar ACC con 100
    153 => BCGE & std_logic_vector(to_unsigned(162, 8)), -- SI ACC >= 100 saltar a dirección 162
    154 => CMP_IMM & std_logic_vector(to_unsigned(60, 8)), -- comparar ACC con 60
    155 => BCGE & std_logic_vector(to_unsigned(165, 8)), -- SI ACC >= 60 saltar a dirección 165
    156 => CMP_IMM & std_logic_vector(to_unsigned(25, 8)), -- comparar ACC con 25
    157 => BCG & std_logic_vector(to_unsigned(168, 8)), -- SI ACC > 25 saltar a dirección 168
    158 => BCE & std_logic_vector(to_unsigned(171, 8)), -- SI ACC = 25 salta a dirección 171
    159 => CMP_IMM & std_logic_vector(to_unsigned(0, 8)), -- comparar ACC con 0
    160 => BCGE & std_logic_vector(to_unsigned(171, 8)), -- SI ACC >= 0 salta a dirección 171
    161 => BCL & std_logic_vector(to_unsigned(174, 8)), -- SI ACC < 0 salta a dirección 174
    
    162 => LDA_IMM & x"02", -- T = 2
    163 => MOV_R & CX, -- CX <- 2;
    164 => JMP & std_logic_vector(to_unsigned(176, 8)),
    
    165 => LDA_IMM & x"03", -- T = 3
    166 => MOV_R & CX, -- CX <- 3
    167 => JMP & std_logic_vector(to_unsigned(176, 8)),
    
    168 => LDA_IMM & x"04", -- T = 4
    169 => MOV_R & CX, -- CX <- 4
    170 => JMP & std_logic_vector(to_unsigned(176, 8)),
    
    171 => LDA_IMM & x"01", -- T = 1
    172 => MOV_R & CX, -- CX <- 1
    173 => JMP & std_logic_vector(to_unsigned(176, 8)),
    
    174 => LDA_IMM & x"05", -- T = 5
    175 => MOV_R & CX, -- CX <- 5
    
    176 => LDA_IMM & x"00", -- AX <- 0
    177 => PRINT & x"FF",
    178 => MOV_R & DX, -- DX <- 0
    
    -- LOOP 1
    179 => ON_LED & std_logic_vector(to_unsigned(0, 8)), 
    180 => OFF_LED & std_logic_vector(to_unsigned(1, 8)),
    181 => OFF_LED & std_logic_vector(to_unsigned(2, 8)),
    182 => OFF_LED & std_logic_vector(to_unsigned(3, 8)),
    183 => OFF_LED & std_logic_vector(to_unsigned(4, 8)),
    184 => LDA_IMM & x"00", -- AX <- 0
    
    -- LOOP 2 (Inicio)
    185 => DELAY & std_logic_vector(to_unsigned(1, 8)), -- Dormir 1 segundo
    186 => ADD_IMM & x"01", -- AX += 1
    187 => ON_LEDR & AX, -- Prender led AX
    188 => CMP_REG & CX, -- Comparar AX con CX (T)
    189 => BCL & std_logic_vector(to_unsigned(185, 8)), -- SI ACC < T salta a dirección 185 (LOOP 2)
    -- Fin Loop 2
    
    190 => MOV_A & DX, -- AX <- DX
    191 => ADD_IMM & std_logic_vector(to_unsigned(1, 8)), -- AX += 1
    192 => PRINT & x"FF",
    193 => MOV_R & DX, -- AX <- DX
    194 => CMP_IMM & std_logic_vector(to_unsigned(30, 8)), -- Comparar ACC con 30
    195 => BCLE & std_logic_vector(to_unsigned(179, 8)), -- SI AX <= 30 salta a dirección 179 (LOOP 1)
    196 => HALT & x"FF",
    
    -- Resto de la memoria
    OTHERS => HALT & x"FF"
  );

BEGIN
  PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      -- Lectura síncrona
      dout <= main_memory(addr);
    END IF;
  END PROCESS;
END ARCHITECTURE Behavioral;