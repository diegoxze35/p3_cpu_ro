library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SevenSegController is
    Port ( Clk : in STD_LOGIC;
           Value : in STD_LOGIC_VECTOR(15 downto 0); -- Valor binario a mostrar
           Seg : out STD_LOGIC_VECTOR(7 downto 0);
           Anode : out STD_LOGIC_VECTOR(3 downto 0));
end SevenSegController;

architecture Behavioral of SevenSegController is
    signal refresh_counter : unsigned(19 downto 0) := (others => '0');
    signal LED_BCD : integer range 0 to 9;
    signal anode_select : std_logic_vector(1 downto 0);
    
    -- Función simple para Hex o usar "Double Dabble" para Decimal (Usaremos Hex por simplicidad de código)
    function hex_to_7seg(hex : integer) return std_logic_vector is
    begin
        case hex is
            when 0 => return "11000000"; -- 0
            when 1 => return "11111001"; -- 1
            when 2 => return "10100100"; -- 2
            when 3 => return "10110000"; -- 3
            when others => return "11111111"; 
        end case;
    end function;

begin
    process(Clk)
    begin
        if rising_edge(Clk) then
            refresh_counter <= refresh_counter + 1;
        end if;
    end process;
    
    anode_select <= std_logic_vector(refresh_counter(19 downto 18));
    
    process(anode_select, Value)
    begin
        case anode_select is
            when "00" =>
                Anode <= "1110"; -- Digito 1
                LED_BCD <= to_integer(unsigned(Value(3 downto 0)));
            when "01" =>
                Anode <= "1101"; -- Digito 2
                LED_BCD <= to_integer(unsigned(Value(7 downto 4)));
            when "10" =>
                Anode <= "1011"; -- Digito 3
                LED_BCD <= to_integer(unsigned(Value(11 downto 8)));
            when "11" =>
                Anode <= "0111"; -- Digito 4
                LED_BCD <= to_integer(unsigned(Value(15 downto 12)));
            when others =>
                Anode <= "1111";
        end case;
    end process;
    
    -- Decodificar LED_BCD a Seg
    -- Nota: Debes expandir la función hex_to_7seg para cubrir 0-F
    Seg <= hex_to_7seg(LED_BCD); 

end Behavioral;