LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY ARITH_UNIT IS
  GENERIC (LEN : NATURAL := 10);
  PORT (
    A : IN STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
    OP_SEL : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    F_ARIT : OUT STD_LOGIC_VECTOR(LEN - 1 DOWNTO 0);
    C_OUT : OUT STD_LOGIC;
    OVF_OUT : OUT STD_LOGIC;
    SIGN_OUT : OUT STD_LOGIC
  );
END ENTITY ARITH_UNIT;
ARCHITECTURE Behavioral OF ARITH_UNIT IS
  FUNCTION multiplication_overflow(res_full : signed; res_msb : STD_LOGIC)
    RETURN BOOLEAN IS
    VARIABLE v_ovf : BOOLEAN := false;
  BEGIN
    FOR i IN LEN TO (2 * LEN) - 1 LOOP
      IF res_full(i) /= res_msb THEN
        v_ovf := true;
        EXIT;
      END IF;
    END LOOP;
    RETURN v_ovf;
  END FUNCTION;
BEGIN
  ARITH : PROCESS (A, B, OP_SEL)
    VARIABLE res_add_sub : signed(LEN DOWNTO 0);
    VARIABLE res_mul : signed((2 * LEN) - 1 DOWNTO 0);
    VARIABLE res_div : signed(LEN - 1 DOWNTO 0);
    VARIABLE v_ovf : BOOLEAN;
    CONSTANT MIN_INT : signed(LEN - 1 DOWNTO 0) := (LEN - 1 => '1', OTHERS => '0');
  BEGIN
    F_ARIT <= (OTHERS => '0');
    C_OUT <= '1';
    OVF_OUT <= '1';
    SIGN_OUT <= '1';
    CASE OP_SEL IS
      WHEN "00" =>
        res_add_sub := ('0' & signed(A)) + ('0' & signed(B));
        F_ARIT <= STD_LOGIC_VECTOR(res_add_sub(LEN - 1 DOWNTO 0));
        C_OUT <= NOT res_add_sub(LEN);
        v_ovf := (A(LEN - 1) = B(LEN - 1)) AND (A(LEN - 1) /= res_add_sub(LEN - 1));
        IF v_ovf THEN
          OVF_OUT <= '0';
        END IF;
        IF res_add_sub(LEN - 1) = '1' THEN
          SIGN_OUT <= '0';
        END IF;
      WHEN "01" =>
        res_add_sub := ('0' & signed(A)) - ('0' & signed(B));
        F_ARIT <= STD_LOGIC_VECTOR(res_add_sub(LEN - 1 DOWNTO 0));
        C_OUT <= NOT res_add_sub(LEN);
        v_ovf := (A(LEN - 1) /= B(LEN - 1)) AND (B(LEN - 1) = res_add_sub(LEN - 1));
        IF v_ovf THEN
          OVF_OUT <= '0';
        END IF;
        IF res_add_sub(LEN - 1) = '1' THEN
          SIGN_OUT <= '0';
        END IF;
      WHEN "10" =>
        res_mul := signed(A) * signed(B);
        F_ARIT <= STD_LOGIC_VECTOR(res_mul(LEN - 1 DOWNTO 0));
        C_OUT <= '1';
        v_ovf := multiplication_overflow(res_mul, res_mul(LEN - 1));
        IF v_ovf THEN
          OVF_OUT <= '0';
        END IF;
        IF res_mul(LEN - 1) = '1' THEN
          SIGN_OUT <= '0';
        END IF;
      WHEN "11" =>
        C_OUT <= '1';
        IF signed(B) = 0 THEN
          OVF_OUT <= '0';
          F_ARIT <= (OTHERS => '0');
          SIGN_OUT <= '1';
        ELSIF signed(A) = MIN_INT AND signed(B) =- 1 THEN
          OVF_OUT <= '0';
          F_ARIT <= STD_LOGIC_VECTOR(MIN_INT);
          SIGN_OUT <= '0';
        ELSE
          res_div := signed(A) / signed(B);
          F_ARIT <= STD_LOGIC_VECTOR(res_div);
          IF res_div(LEN - 1) = '1' THEN
            SIGN_OUT <= '0';
          END IF;
        END IF;
      WHEN OTHERS =>
        F_ARIT <= (OTHERS => '0');
        C_OUT <= '1';
        OVF_OUT <= '1';
        SIGN_OUT <= '1';
    END CASE;
  END PROCESS ARITH;
END ARCHITECTURE Behavioral;