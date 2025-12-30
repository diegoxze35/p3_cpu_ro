library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.instruction_set.all;
use work.registers.all;

entity PROGRAM_MEMORY is port(
	addr: in  integer range 0 to 255;
	dout: out std_logic_vector(15 downto 0)
);

end entity PROGRAM_MEMORY;
	
architecture Behavioral of PROGRAM_MEMORY is

	type ROM is array (0 to 255) of std_logic_vector(15 downto 0);
	
	constant ADDR_W: integer := 200;
	constant ADDR_X: integer := 201;
	constant ADDR_Y: integer := 202;
	constant ADDR_Z: integer := 203;
	
	constant mem: ROM := (
	   -- ECUACIÓN 1
		0   => LDA_MEM & std_logic_vector(to_unsigned(ADDR_X, 8)),
		1   => MOV_R   & std_logic_vector(to_unsigned(REG_B,  8)),
		2   => LDA_IMM & x"11", --17
		3   => MULT    & std_logic_vector(to_unsigned(REG_B,  8)),  -- ACC = ACC * REG_B
		4   => MOV_R   & std_logic_vector(to_unsigned(REG_A,  8)),  -- REG_A <- ACC (17X)
		5   => LDA_MEM & std_logic_vector(to_unsigned(ADDR_Y, 8)),  -- ACC <- Y
		6   => MOV_R   & std_logic_vector(to_unsigned(REG_B,  8)), 
		7   => LDA_IMM & x"19", --25
		8   => MULT    & std_logic_vector(to_unsigned(REG_B,  8)),
		9   => MOV_R   & std_logic_vector(to_unsigned(REG_B,  8)),  -- REG_B <- 25Y
		10  => MOV_A   & std_logic_vector(to_unsigned(REG_A,  8)),
		11  => ADD     & std_logic_vector(to_unsigned(REG_B,  8)),  -- 17X + 25Y -> ACC
		12  => MOV_R   & std_logic_vector(to_unsigned(REG_A,  8)),  -- REG_A <- 17X + 25Y
		13  => LDA_IMM & x"04", -- 4
		14  => MOV_R   & std_logic_vector(to_unsigned(REG_B,  8)),  -- REG_B <- 4
		15  => LDA_MEM & std_logic_vector(to_unsigned(ADDR_W, 8)),
		16  => DIV     & std_logic_vector(to_unsigned(REG_B,  8)),  -- ACC <- W / 4
		17  => MOV_R   & std_logic_vector(to_unsigned(REG_B,  8)),  -- REG_B <- W / 4
		18  => MOV_A   & std_logic_vector(to_unsigned(REG_A,  8)),
		19  => SUBS    & std_logic_vector(to_unsigned(REG_B,  8)),
		20  => JMP     & std_logic_vector(to_unsigned(150,    8)),  -- Salto incondicional a la rutina de leds
		-- ECUACIÓN 1
		
		-- ECUACIÓN 2
		21  => LDA_MEM & std_logic_vector(to_unsigned(ADDR_X, 8)),
		22  => MOV_R   & std_logic_vector(to_unsigned(REG_B,  8)), -- REG_B <- X
		23  => MULT    & std_logic_vector(to_unsigned(REG_B,  8)), -- ACC <- X * X
		24  => MOV_R   & std_logic_vector(to_unsigned(REG_B,  8)), -- REG_B <- X^2
		25  => LDA_IMM & x"0A", --10
		26  => MULT    & std_logic_vector(to_unsigned(REG_B,  8)), -- ACC <- 10 * X^2
		27  => MOV_R   & std_logic_vector(to_unsigned(REG_A,  8)), -- REG_A <- 10 * X^2
		28  => LDA_MEM & std_logic_vector(to_unsigned(ADDR_X, 8)), -- ACC <- X
		29  => MOV_R   & std_logic_vector(to_unsigned(REG_B,  8)), -- REG_B <- X
		30  => LDA_IMM & x"1E", --30
		31  => MULT    & std_logic_vector(to_unsigned(REG_B,  8)), -- ACC <- 30 * X
		32  => MOV_R   & std_logic_vector(to_unsigned(REG_B,  8)), -- REG_B <- 30 * X
		33  => MOV_A   & std_logic_vector(to_unsigned(REG_A,  8)), -- ACC <- REG_A (10 * X^2)
		34  => ADD     & std_logic_vector(to_unsigned(REG_B,  8)), -- ACC <- 10 * X^2 + 30 * X
		35  => MOV_R   & std_logic_vector(to_unsigned(REG_A,  8)), -- REG_A <- ACC
		36  => LDA_IMM & x"02", --2
		37  => MOV_R   & std_logic_vector(to_unsigned(REG_B,  8)), -- REG_B <- 2
		38  => LDA_MEM & std_logic_vector(to_unsigned(ADDR_Z, 8)), -- ACC <- Z,
		39  => DIV     & std_logic_vector(to_unsigned(REG_B,  8)), -- ACC <- Z / REG_B (2)
		40  => MOV_R   & std_logic_vector(to_unsigned(REG_B,  8)), -- REG_B <- Z / 2
		41  => MOV_A   & std_logic_vector(to_unsigned(REG_A,  8)), -- ACC <- REG_A (10 * X^2 + 30 * X)
		42  => SUBS    & std_logic_vector(to_unsigned(REG_B,  8)),
		43  => JMP     & std_logic_vector(to_unsigned(150,    8)), -- Salto incondicional a la rutina de leds
		-- ECUACIÓN 2
		
		-- ECUACIÓN 3
		44  => LDA_MEM & std_logic_vector(to_unsigned(ADDR_X, 8)), -- ACC <- X
		45  => MOV_R   & std_logic_vector(to_unsigned(REG_B,  8)), -- REG_B <- X
		46  => MULT    & std_logic_vector(to_unsigned(REG_B,  8)), -- ACC <- X * X
		47  => MOV_R   & std_logic_vector(to_unsigned(REG_B,  8)), -- REG_B <- ACC (X^2)
		48  => LDA_MEM & std_logic_vector(to_unsigned(ADDR_X, 8)), -- ACC <- X
		49  => MULT    & std_logic_vector(to_unsigned(REG_B,  8)), -- ACC <- X * X^2
		50  => MOV_R   & std_logic_vector(to_unsigned(REG_B,  8)), -- REG_B <- ACC (X^3)
		51  => LDA_IMM & x"00", --0
		52  => SUBS    & std_logic_vector(to_unsigned(REG_B,  8)), -- ACC <- 0 - X^3
		53  => MOV_R   & std_logic_vector(to_unsigned(REG_A,  8)), -- REG_A <- -X^3
		54  => LDA_IMM & x"07", --7
		55  => MOV_R   & std_logic_vector(to_unsigned(REG_B,  8)), -- REG_B <- 7
		56  => LDA_MEM & std_logic_vector(to_unsigned(ADDR_Z, 8)), -- ACC <- Z
		57  => MULT    & std_logic_vector(to_unsigned(REG_B,  8)), -- ACC <- Z * 7
		58  => MOV_R   & std_logic_vector(to_unsigned(REG_B,  8)), -- REG_B <- 7*Z
		59  => MOV_A   & std_logic_vector(to_unsigned(REG_A,  8)), -- ACC <- REG_A -(X^3)
		60  => SUBS    & std_logic_vector(to_unsigned(REG_B,  8)), -- ACC <- -(X^3) - 7*Z
		61  => MOV_R   & std_logic_vector(to_unsigned(REG_A,  8)), -- REG_A <- -(X^3) - 7*Z
		62  => LDA_IMM & x"0A",
		63  => MOV_R   & std_logic_vector(to_unsigned(REG_B,  8)), -- REG_B <- 10
		64  => LDA_MEM & std_logic_vector(to_unsigned(ADDR_W, 8)), -- ACC <- W
		65  => DIV     & std_logic_vector(to_unsigned(REG_B,  8)), -- ACC <- W / REG_B (10)
		66  => MOV_R   & std_logic_vector(to_unsigned(REG_B,  8)), -- REG_B <- W/10
		67  => MOV_A   & std_logic_vector(to_unsigned(REG_A,  8)), -- ACC <- REG_A (-(X^3) - (7*Z))
		68  => ADD     & std_logic_vector(to_unsigned(REG_B,  8)), -- ACC <- -(X^3) - 7*Z + W / 10
		69  => JMP     & std_logic_vector(to_unsigned(150,    8)), -- Salto incondicional a la rutina de leds
		-- ECUACIÓN 3
		
		150 => DISPLAY & x"FF",
		151 => SLEEP   & std_logic_vector(to_unsigned(10,     8)),  -- dormir 10 segundos
		152 => CMP_IMM & std_logic_vector(to_unsigned(100,    8)),  -- comparar ACC con 100
		153 => BCGE    & std_logic_vector(to_unsigned(162,    8)),  -- SI ACC >= 100 saltar a dirección 161
		154 => CMP_IMM & std_logic_vector(to_unsigned(60,     8)),  -- comparar ACC con 60
		155 => BCGE    & std_logic_vector(to_unsigned(165,    8)),  -- SI ACC >= 60 saltar a dirección 164
		156 => CMP_IMM & std_logic_vector(to_unsigned(25,     8)),  -- comparar ACC con 25
		157 => BCG     & std_logic_vector(to_unsigned(168,    8)),  -- SI ACC > 25 saltar a dirección 167
		158 => BCE     & std_logic_vector(to_unsigned(171,    8)),  -- SI ACC = 25 salta a dirección 170
		159 => CMP_IMM & std_logic_vector(to_unsigned(0,      8)),  -- comparar ACC con 0
		160 => BCGE    & std_logic_vector(to_unsigned(171,    8)),  -- SI ACC >= 0 salta a dirección 170
		161 => BCL     & std_logic_vector(to_unsigned(174,    8)),  -- SI ACC < 0 salta a dirección 173
		
		162 => LDA_IMM & x"02", -- T = 2
		163 => MOV_R   & std_logic_vector(to_unsigned(REG_C,   8)), -- REG_C <- 2;
		164 => JMP     & std_logic_vector(to_unsigned(176,     8)),
		165 => LDA_IMM & x"03", -- T = 3
		166 => MOV_R   & std_logic_vector(to_unsigned(REG_C,   8)), -- REG_C <- 3
		167 => JMP     & std_logic_vector(to_unsigned(176,     8)),
		168 => LDA_IMM & x"04", -- T = 4
		169 => MOV_R   & std_logic_vector(to_unsigned(REG_C,   8)), -- REG_C <- 4
		170 => JMP     & std_logic_vector(to_unsigned(176,     8)),
		171 => LDA_IMM & x"01", -- T = 1
		172 => MOV_R   & std_logic_vector(to_unsigned(REG_C,   8)), -- REG_C <- 1
		173 => JMP     & std_logic_vector(to_unsigned(176,     8)),
		174 => LDA_IMM & x"05", -- T = 5
		175 => MOV_R   & std_logic_vector(to_unsigned(REG_C,   8)), -- REG_C <- 5
		
		176 => LDA_IMM & x"00",                                     -- ACC <- 0
		177 => DISPLAY & x"FF",
		178 => MOV_R   & std_logic_vector(to_unsigned(REG_A,   8)), -- REG_A <- ACC (0)
		179 => ON_LED  & std_logic_vector(to_unsigned(0,       8)), -- LOOP 1
		180 => OFF_LED & std_logic_vector(to_unsigned(1,       8)), 
		181 => OFF_LED & std_logic_vector(to_unsigned(2,       8)), 
		182 => OFF_LED & std_logic_vector(to_unsigned(3,       8)), 
		183 => OFF_LED & std_logic_vector(to_unsigned(4,       8)),
		184 => LDA_IMM & x"00",                                     -- ACC <- 0
		185 => SLEEP   & std_logic_vector(to_unsigned(1,       8)), -- Dormir 1 segundo (LOOP 2)
		186 => ADD_IMM & x"01", 										      -- ACC += 1
		187 => ON_LEDR & std_logic_vector(to_unsigned(ACC,     8)), -- Prender led ACC
		188 => CMP_REG & std_logic_vector(to_unsigned(REG_C,   8)), -- Comparar ACC con REG_C (T)
		189 => BCL     & std_logic_vector(to_unsigned(185,     8)), -- SI ACC < T salta a dirección 185 (LOOP 2)
		190 => MOV_A   & std_logic_vector(to_unsigned(REG_A,   8)), -- ACC <- REG_A
		191 => ADD_IMM & std_logic_vector(to_unsigned(1,       8)), -- ACC += 1
		192 => DISPLAY & x"FF",
		193 => MOV_R   & std_logic_vector(to_unsigned(REG_A,   8)), -- REG_A <- ACC
		194 => CMP_IMM & std_logic_vector(to_unsigned(30,      8)), -- Comparar ACC con 30
		195 => BCLE    & std_logic_vector(to_unsigned(179,     8)), -- SI ACC <= 30 salta a dirección 179 (LOOP 1)
		196 => HALT    & x"FF",

		-- Variables
		200 => x"FFDC", -- W = -36
		201 => x"FFFE", -- X = -2
      202 => x"0005", -- Y = 5
		203 => x"0008", -- Z = 8
		others => x"FFFF"
	);
	
begin
	dout <= mem(addr);
end architecture Behavioral;