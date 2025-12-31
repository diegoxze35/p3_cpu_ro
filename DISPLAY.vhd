LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
ENTITY DISPLAY IS
  GENERIC (clk_freq : integer := 50000);
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    data_in : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
    segments : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
    anodes : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
  );
END DISPLAY;
ARCHITECTURE Behavioral OF DISPLAY IS
  SIGNAL refresh_counter : INTEGER RANGE 0 TO clk_freq := 0;
  SIGNAL digit_sel : INTEGER RANGE 0 TO 3 := 0;
  SIGNAL nibble_to_show : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
  PROCESS (clk, reset)
  BEGIN
    IF NOT reset THEN
      refresh_counter <= 0;
      digit_sel <= 0;
    ELSIF rising_edge(clk) THEN
      IF refresh_counter = clk_freq THEN
        refresh_counter <= 0;
        IF digit_sel = 3 THEN
          digit_sel <= 0;
        ELSE
          digit_sel <= digit_sel + 1;
        END IF;
      ELSE
        refresh_counter <= refresh_counter + 1;
      END IF;
    END IF;
  END PROCESS;
  PROCESS (digit_sel, data_in)
  BEGIN
    CASE digit_sel IS
      WHEN 0 => nibble_to_show <= data_in(3 DOWNTO 0);
      WHEN 1 => nibble_to_show <= data_in(7 DOWNTO 4);
      WHEN 2 => nibble_to_show <= data_in(11 DOWNTO 8);
      WHEN 3 => nibble_to_show <= data_in(15 DOWNTO 12);
      WHEN OTHERS => nibble_to_show <= "0000";
    END CASE;
  END PROCESS;
  PROCESS (nibble_to_show)
  BEGIN
    CASE nibble_to_show IS
      WHEN "0000" => segments <= "1000000";
      WHEN "0001" => segments <= "1111001";
      WHEN "0010" => segments <= "0100100";
      WHEN "0011" => segments <= "0110000";
      WHEN "0100" => segments <= "0011001";
      WHEN "0101" => segments <= "0010010";
      WHEN "0110" => segments <= "0000010";
      WHEN "0111" => segments <= "1111000";
      WHEN "1000" => segments <= "0000000";
      WHEN "1001" => segments <= "0010000";
      WHEN "1010" => segments <= "0001000";
      WHEN "1011" => segments <= "0000011";
      WHEN "1100" => segments <= "1000110";
      WHEN "1101" => segments <= "0100001";
      WHEN "1110" => segments <= "0000110";
      WHEN "1111" => segments <= "0001110";
      WHEN OTHERS => segments <= "1111111";
    END CASE;
  END PROCESS;
  PROCESS (digit_sel)
  BEGIN
    CASE digit_sel IS
      WHEN 0 => anodes <= "1110";
      WHEN 1 => anodes <= "1101";
      WHEN 2 => anodes <= "1011";
      WHEN 3 => anodes <= "0111";
      WHEN OTHERS => anodes <= "1111";
    END CASE;
  END PROCESS;
END Behavioral;