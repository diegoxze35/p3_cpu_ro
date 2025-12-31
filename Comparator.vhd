LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY COMPARATOR IS
  PORT (
    A, B : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    G, E, L : OUT STD_LOGIC
  );
END COMPARATOR;
ARCHITECTURE Structural OF COMPARATOR IS
  SIGNAL A_offset, B_offset : STD_LOGIC_VECTOR(15 DOWNTO 0);
  COMPONENT COMPARATOR_1_BIT IS
    PORT (
      A, B, Gin, Ein, Lin : IN STD_LOGIC;
      Gout, Eout, Lout : OUT STD_LOGIC
    );
  END COMPONENT;
  SIGNAL Greater, Equal, Less : STD_LOGIC_VECTOR(16 DOWNTO 0);
BEGIN
  A_offset <= (NOT A(15)) & A(14 DOWNTO 0);
  B_offset <= (NOT B(15)) & B(14 DOWNTO 0);
  Greater(0) <= '0';
  Equal(0) <= '1';
  Less(0) <= '0';
  GEN_COMP : FOR i IN 0 TO 15 GENERATE
    Cx : COMPARATOR_1_BIT
    PORT MAP(
      A => A_offset(i), B => B_offset(i),
      Gin => Greater(i), Ein => Equal(i), Lin => Less(i),
      Gout => Greater(i + 1), Eout => Equal(i + 1), Lout => Less(i + 1)
    );
  END GENERATE;
  G <= Greater(16);
  E <= Equal(16);
  L <= Less(16);
END Structural;