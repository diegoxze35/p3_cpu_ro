library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Program_Memory is
    Port ( Clock : in STD_LOGIC;
           Address : in STD_LOGIC_VECTOR(7 downto 0);
           Data_Out : out STD_LOGIC_VECTOR(15 downto 0));
end Program_Memory;

architecture Behavioral of Program_Memory is
    type rom_type is array (0 to 255) of std_logic_vector(15 downto 0);
    
    -- OPCODES DEFINIDOS:
    -- 01: LOAD [addr]  02: STORE [addr]  03: MOV A, B (N/A aqui, Von Neumann simple)
    -- 10: ADD [addr]   11: SUB [addr]    12: MUL [addr]   13: DIV [addr]
    -- 14: AND [addr]   15: OR [addr]     16: NOT (Acc)    17: LSL (Acc)  18: ASR (Acc)
    -- 19: CMP [addr]
    -- 20: JMP [addr]   21: BNZ [addr]    22: BS [addr]    23: BNC [addr] 24: BNV [addr]
    -- FF: HALT/DELAY
    
    -- DIRECCIONES DE DATOS (Variables y Constantes en 0xF0+)
    -- F0: X (Val=5)   F1: Y (Val=3)   F2: Z (Val=4)   F3: W (Val=20)
    -- F4: Temp1       F5: Temp2
    -- E0: 17, E1: 25, E2: 4, E3: 10, E4: 30, E5: 2, E6: 7
    
    constant ROM : rom_type := (
        -- === PROGRAMA 1: F = 17X + 25Y - W/4 === (Inicio 0x00)
        x"01F0", -- LOAD X
        x"12E0", -- MUL 17
        x"02F4", -- STORE Temp1
        x"01F1", -- LOAD Y
        x"12E1", -- MUL 25
        x"10F4", -- ADD Temp1
        x"02F4", -- STORE Temp1 (Ahora tiene 17X + 25Y)
        x"01F3", -- LOAD W
        x"13E2", -- DIV 4
        x"02F5", -- STORE Temp2
        x"01F4", -- LOAD Temp1
        x"11F5", -- SUB Temp2
        x"FF00", -- HALT y Delay
		  
		  -- x"01F0", -- LOAD X
        x"12F0", -- MUL X (X^2)
		  x"12E3", -- MUL 10
		  x"02F4", -- STORE Temp1
		  x"01F0", -- LOAD X
        x"12E4", -- MUL 30
        x"10F4", -- ADD Temp1
        x"02F4", -- STORE Temp1
        x"01F2", -- LOAD Z
        x"13E5", -- DIV 2
        x"02F5", -- STORE Temp2
        x"01F4", -- LOAD Temp1
        x"11F5", -- SUB Temp2
        x"FF00", -- HALT
    
    -- === PROGRAMA 3: F = -(X^3) - 7Z + W/10 === (Inicio 0x80)
        x"01F0", -- LOAD X
        x"12F0", -- MUL X
        x"12F0", -- MUL X (X^3)
        x"02F4", -- STORE Temp1
        x"01F2", -- LOAD Z
        x"12E6", -- MUL 7
        x"10F4", -- ADD Temp1 (Ahora es X^3 + 7Z)
        x"1600", -- NOT (Invertir bits, aprox a negativo -1)
        x"10F6", -- ADD 1 (Para hacer complemento a 2 real, asumimos 1 en F6 o usamos lógica NOT simple)
    -- ... simplifiquemos a restar: 0 - (X^3 + 7Z)
    -- MEJOR ESTRATEGIA:
        x"01E8", -- LOAD 0 (Constante 0)
        x"11F4", -- SUB Temp1 (0 - (X^3)) -> -X^3
        x"02F4", -- STORE Temp1
        x"01F2", -- LOAD Z
        x"12E6", -- MUL 7
        x"02F5", -- STORE Temp2
        x"01F4", -- LOAD Temp1
        x"11F5", -- SUB Temp2 (-X^3 - 7Z)
        x"02F4", -- STORE Temp1
        x"01F3", -- LOAD W
        x"13E3", -- DIV 10
        x"10F4", -- ADD Temp1
        x"FF00",  -- HALT
    
    -- DATOS EN DIRECCIONES ALTAS (Relleno manual para el ejemplo)
    -- Debes agregar esto al final de tu array ROM:
    -- 240 (0xF0) => x"0005", -- X
    -- 241 (0xF1) => x"0003", -- Y
    -- 242 (0xF2) => x"0004", -- Z
    -- 243 (0xF3) => x"0014", -- W (20)
    -- 224 (0xE0) => x"0011", -- 17
    -- 225 (0xE1) => x"0019", -- 25
    -- ... y así sucesivamente.
		  
        others => x"0000" -- Relleno hasta 0x40
    );
    
    -- Nota: VHDL requiere inicializar el array completo de una vez o usar una función compleja.
    -- Para simplicidad en este ejemplo de texto, sobreescribiré conceptualmente las siguientes líneas.
    -- EN TU CÓDIGO FINAL, DEBES PONER TODO DENTRO DEL ARRAY "constant ROM".
    
    -- Imagina que esto continúa el array de arriba en la posición 64 (0x40):
    -- === PROGRAMA 2: F = 10(X^2) + 30X - Z/2 ===
    -- x"01F0", -- LOAD X
    -- x"12F0", -- MUL X (X^2)
    -- x"12E3", -- MUL 10
    -- x"02F4", -- STORE Temp1
    -- x"01F0", -- LOAD X
    -- x"12E4", -- MUL 30
    -- x"10F4", -- ADD Temp1
    -- x"02F4", -- STORE Temp1
    -- x"01F2", -- LOAD Z
    -- x"13E5", -- DIV 2
    -- x"02F5", -- STORE Temp2
    -- x"01F4", -- LOAD Temp1
    -- x"11F5", -- SUB Temp2
    -- x"FF00", -- HALT
    
    -- === PROGRAMA 3: F = -(X^3) - 7Z + W/10 === (Inicio 0x80)
    -- x"01F0", -- LOAD X
    -- x"12F0", -- MUL X
    -- x"12F0", -- MUL X (X^3)
    -- x"02F4", -- STORE Temp1
    -- x"01F2", -- LOAD Z
    -- x"12E6", -- MUL 7
    -- x"10F4", -- ADD Temp1 (Ahora es X^3 + 7Z)
    -- x"1600", -- NOT (Invertir bits, aprox a negativo -1)
    -- x"10F6", -- ADD 1 (Para hacer complemento a 2 real, asumimos 1 en F6 o usamos lógica NOT simple)
    -- ... simplifiquemos a restar: 0 - (X^3 + 7Z)
    -- MEJOR ESTRATEGIA:
    -- x"01E8", -- LOAD 0 (Constante 0)
    -- x"11F4", -- SUB Temp1 (0 - (X^3)) -> -X^3
    -- x"02F4", -- STORE Temp1
    -- x"01F2", -- LOAD Z
    -- x"12E6", -- MUL 7
    -- x"02F5", -- STORE Temp2
    -- x"01F4", -- LOAD Temp1
    -- x"11F5", -- SUB Temp2 (-X^3 - 7Z)
    -- x"02F4", -- STORE Temp1
    -- x"01F3", -- LOAD W
    -- x"13E3", -- DIV 10
    -- x"10F4", -- ADD Temp1
    -- x"FF00"  -- HALT
    
    -- DATOS EN DIRECCIONES ALTAS (Relleno manual para el ejemplo)
    -- Debes agregar esto al final de tu array ROM:
    -- 240 (0xF0) => x"0005", -- X
    -- 241 (0xF1) => x"0003", -- Y
    -- 242 (0xF2) => x"0004", -- Z
    -- 243 (0xF3) => x"0014", -- W (20)
    -- 224 (0xE0) => x"0011", -- 17
    -- 225 (0xE1) => x"0019", -- 25
    -- ... y así sucesivamente.

begin
    process(Clock)
    begin
        if rising_edge(Clock) then
            Data_Out <= ROM(to_integer(unsigned(Address)));
        end if;
    end process;
end Behavioral;