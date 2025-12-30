library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity COMPARATOR is
    Port ( A, B    : in STD_LOGIC_VECTOR(15 downto 0);
           G, E, L : out STD_LOGIC );
end COMPARATOR;

architecture Structural of COMPARATOR is

	signal A_offset, B_offset : STD_LOGIC_VECTOR(15 downto 0);

    component Comp1Bit is
        Port ( A, B, Gin, Ein, Lin : in STD_LOGIC;
               Gout, Eout, Lout : out STD_LOGIC);
    end component;
    
    signal g_wire, e_wire, l_wire : STD_LOGIC_VECTOR(16 downto 0);
begin

	 -- Invertimos el MSB para "engañar" al comparador
    -- Esto convierte el rango [-32768, 32767] a [0, 65535]
    A_offset <= (not A(15)) & A(14 downto 0);
    B_offset <= (not B(15)) & B(14 downto 0);

    -- Inicialización de cascada (bits menos significativos)
    -- Asumimos igualdad al inicio (E=1, G=0, L=0)
    g_wire(0) <= '0';
    e_wire(0) <= '1';
    l_wire(0) <= '0';

    -- Generar 16 instancias
    GEN_COMP: for i in 0 to 15 generate
        Cx: Comp1Bit port map (
            A => A_offset(i), B => B_offset(i), --A => A(i), B => B(i),
            Gin => g_wire(i), Ein => e_wire(i), Lin => l_wire(i),
            Gout => g_wire(i + 1), Eout => e_wire(i + 1), Lout => l_wire(i + 1)
        );
    end generate;

    -- Salida final (Bit más significativo arrastra el resultado)
    G <= g_wire(16);
    E <= e_wire(16);
    L <= l_wire(16);
end Structural;