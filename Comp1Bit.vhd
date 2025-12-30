library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Comp1Bit is
    Port ( A, B : in STD_LOGIC;
           Gin, Ein, Lin : in STD_LOGIC; -- Entradas de cascada (Greater, Equal, Less)
           Gout, Eout, Lout : out STD_LOGIC);
end Comp1Bit;

architecture Structural of Comp1Bit is
begin
    Gout <= (A and not B) or ((A xnor B) and Gin);
    Eout <= (A xnor B) and Ein;
    Lout <= (not A and B) or ((A xnor B) and Lin);
end Structural;