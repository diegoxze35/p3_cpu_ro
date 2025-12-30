library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DISPLAY_CONTROLLER is
    Port (
        clk     : in STD_LOGIC; -- 50 MHz
        reset   : in STD_LOGIC;
        data_in : in STD_LOGIC_VECTOR (15 downto 0); -- Numero de 16 bits a mostrar (Hex)
        segments: out STD_LOGIC_VECTOR (6 downto 0); -- a,b,c,d,e,f,g
        anodes  : out STD_LOGIC_VECTOR (3 downto 0)  -- Dig 1, 2, 3, 4
    );
end DISPLAY_CONTROLLER;

architecture Behavioral of DISPLAY_CONTROLLER is
    signal refresh_counter: integer range 0 to 50000 := 0; -- Divisor para barrido (~1kHz)
    signal digit_sel      : integer range 0 to 3 := 0;     -- Selector de digito actual
    signal nibble_to_show : std_logic_vector(3 downto 0);
begin

    -- 1. Divisor de frecuencia para el multiplexado
    process(clk, reset)
    begin
        if not reset then
            refresh_counter <= 0;
            digit_sel <= 0;
        elsif rising_edge(clk) then
            if refresh_counter = 50000 then -- Ajustar velocidad de refresco si parpadea
                refresh_counter <= 0;
                if digit_sel = 3 then
                    digit_sel <= 0;
                else
                    digit_sel <= digit_sel + 1;
                end if;
            else
                refresh_counter <= refresh_counter + 1;
            end if;
        end if;
    end process;

    -- 2. Multiplexor de Datos (Elige qué 4 bits mostrar según el dígito activo)
    process(digit_sel, data_in)
    begin
        case digit_sel is
            when 0 => nibble_to_show <= data_in(3 downto 0);   -- Digito derecho (LSB)
            when 1 => nibble_to_show <= data_in(7 downto 4);
            when 2 => nibble_to_show <= data_in(11 downto 8);
            when 3 => nibble_to_show <= data_in(15 downto 12); -- Digito izquierdo (MSB)
            when others => nibble_to_show <= "0000";
        end case;
    end process;

    -- 3. Decodificador Hexadecimal a 7 Segmentos (Ánodo Común -> 0 prende)
    -- Formato: gfedcba (bit 6 a 0)
    process(nibble_to_show)
    begin
        case nibble_to_show is         -- gfedcba
            when "0000" => segments <= "1000000"; -- 0
            when "0001" => segments <= "1111001"; -- 1
            when "0010" => segments <= "0100100"; -- 2
            when "0011" => segments <= "0110000"; -- 3
            when "0100" => segments <= "0011001"; -- 4
            when "0101" => segments <= "0010010"; -- 5
            when "0110" => segments <= "0000010"; -- 6
            when "0111" => segments <= "1111000"; -- 7
            when "1000" => segments <= "0000000"; -- 8
            when "1001" => segments <= "0010000"; -- 9
            when "1010" => segments <= "0001000"; -- A
            when "1011" => segments <= "0000011"; -- b
            when "1100" => segments <= "1000110"; -- C
            when "1101" => segments <= "0100001"; -- d
            when "1110" => segments <= "0000110"; -- E
            when "1111" => segments <= "0001110"; -- F
            when others => segments <= "1111111"; -- Apagado
        end case;
    end process;

    -- 4. Control de Ánodos (Activo Bajo: 0 prende el digito)
    process(digit_sel)
    begin
        case digit_sel is
            when 0 => anodes <= "1110"; -- Prende Digito 0 (Derecha)
            when 1 => anodes <= "1101";
            when 2 => anodes <= "1011";
            when 3 => anodes <= "0111"; -- Prende Digito 3 (Izquierda)
            when others => anodes <= "1111";
        end case;
    end process;

end Behavioral;