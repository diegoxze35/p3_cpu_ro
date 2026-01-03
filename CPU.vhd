LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.instructions.ALL;
USE work.constants.ALL;
USE work.program.ALL;

ENTITY CPU IS
  PORT (
    clk : IN std_logic;
    reset : IN std_logic;
    switch : IN std_logic_vector(1 DOWNTO 0);
    led : OUT std_logic_vector(4 DOWNTO 0);
    seg : OUT std_logic_vector(6 DOWNTO 0); 
    dig : OUT std_logic_vector(3 DOWNTO 0) 
  );
END ENTITY CPU;

ARCHITECTURE Behavioral OF CPU IS
  TYPE REGISTER_ARRAY IS ARRAY(0 to 3) OF std_logic_vector(15 downto 0);
  SIGNAL r : REGISTER_ARRAY := (0 to 3 => (x"0000"));
  SIGNAL destination : INTEGER RANGE 0 TO 4;
  SIGNAL source : std_logic_vector(15 DOWNTO 0);

  TYPE STATE IS (FETCH_MEM, FETCH, DECODE, MEM_SYNC, EXE_MOV, EXE_ALU, EXE_BRAN, EXE_PAUSA, HALT_STATE);
  SIGNAL current_state : STATE := FETCH;
  
  SIGNAL from_mem : boolean := false;
  SIGNAL flag_branch : std_logic := '0';

  SIGNAL PC : INTEGER RANGE 0 TO 255 := 0;
  SIGNAL IR : std_logic_vector(15 DOWNTO 0);

  SIGNAL alu_op_code : std_logic_vector(1 DOWNTO 0);
  SIGNAL alu_inA, alu_inB, result : std_logic_vector(15 DOWNTO 0);
  SIGNAL carry, overflow, sign : std_logic;

  SIGNAL mbr : INTEGER RANGE 0 TO 255 := PC;
  SIGNAL mar : INTEGER RANGE 0 TO 255;
  SIGNAL rom_data : std_logic_vector(15 DOWNTO 0);

  SIGNAL display_reset : std_logic := '0';
  SIGNAL display_number : std_logic_vector(15 DOWNTO 0) := x"0000";

  SIGNAL cmp_a, cmp_b : std_logic_vector(15 DOWNTO 0) := x"0000";
  SIGNAL GRE, EQU, LESS : std_logic;

  SIGNAL counter : INTEGER := 0;
  SIGNAL t : INTEGER := 0;

BEGIN
  -- (Las instanciaciones MEM, CMP, ALU, DISPLAY)
  MEM : ENTITY work.MAIN_MEMORY PORT MAP(clk => clk, addr => mbr, dout => rom_data);
  CMP : ENTITY work.COMPARATOR PORT MAP(A => cmp_a, B => cmp_b, G => GRE, E => EQU, L => LESS);
  ALU : ENTITY work.ARITH_UNIT GENERIC MAP(LEN => 16) PORT MAP(A => alu_inA, B => alu_inB, OP_SEL => alu_op_code, F_ARIT => result, C_OUT => carry, OVF_OUT => overflow, SIGN_OUT => sign);
  DISPLAY : ENTITY work.DISPLAY GENERIC MAP(clk_freq => 50000) PORT MAP(clk => clk, reset => display_reset, data_in => display_number, segments => seg, anodes => dig);

  U_CONTROL: PROCESS (clk, reset)
    VARIABLE op_code : std_logic_vector(7 DOWNTO 0);
    VARIABLE operand : std_logic_vector(7 DOWNTO 0);
    VARIABLE index : INTEGER RANGE 0 TO 4;
    CONSTANT CLK_FREQ : INTEGER := 50000000;
  BEGIN
    IF NOT reset THEN 
      current_state <= FETCH_MEM;
      led <= (OTHERS => '0');
      display_reset <= '0';
      t <= 0;
      counter <= 0;
      r <= (0 to 3 => (x"0000"));
      -- Lógica de selección de programa igual...
      IF NOT switch = "00" THEN PC <= EQ1_ADDR;
      ELSIF NOT switch = "01" THEN PC <= EQ2_ADDR;
      ELSIF NOT switch = "10" THEN PC <= EQ3_ADDR;
      ELSE PC <= 255; END IF;

    ELSIF rising_edge(clk) THEN
      CASE current_state IS
        WHEN FETCH_MEM => 
          current_state <= FETCH;
        WHEN FETCH => 
          IR <= rom_data;
          PC <= PC + 1;
          current_state <= DECODE;
        WHEN DECODE => 
          op_code := IR(15 DOWNTO 8);
          operand := IR(7 DOWNTO 0);
          CASE op_code IS
            -- CARGAS Y MOVIMIENTOS
            WHEN CAR_MEM => 
              destination <= AX;
              mar <= to_integer(unsigned(operand));
              current_state <= MEM_SYNC;
            WHEN MOV_REG => 
              destination <= to_integer(unsigned(operand));
              source <= r(AX);
              current_state <= EXE_MOV;
            WHEN MOV_ACU => 
              destination <= AX;
              source <= r(to_integer(unsigned(operand)));
              current_state <= EXE_MOV;
            WHEN CAR_INM => 
              destination <= AX;
              source <= std_logic_vector(resize(signed(operand), 16));
              current_state <= EXE_MOV;
            
            -- ARITMÉTICA
            WHEN SUM => 
              destination <= AX; alu_op_code <= "00";
              alu_inA <= r(AX); alu_inB <= r(to_integer(unsigned(operand)));
              current_state <= EXE_ALU;
            WHEN RES => 
              destination <= AX; alu_op_code <= "01";
              alu_inA <= r(AX); alu_inB <= r(to_integer(unsigned(operand)));
              current_state <= EXE_ALU;
            WHEN MUL => 
              destination <= AX; alu_op_code <= "10";
              alu_inA <= r(AX); alu_inB <= r(to_integer(unsigned(operand)));
              current_state <= EXE_ALU;
            WHEN DIV => 
              destination <= AX; alu_op_code <= "11";
              alu_inA <= r(AX); alu_inB <= r(to_integer(unsigned(operand)));
              current_state <= EXE_ALU;
            WHEN SUM_INM => 
              destination <= AX; alu_op_code <= "00";
              alu_inA <= r(AX); alu_inB <= std_logic_vector(resize(signed(operand), 16));
              current_state <= EXE_ALU;
            WHEN RES_INM => 
              destination <= AX; alu_op_code <= "01";
              alu_inA <= r(AX); alu_inB <= std_logic_vector(resize(signed(operand), 16));
              current_state <= EXE_ALU;

            -- COMPARACIONES Y SALTOS
            WHEN CMP_INM => 
              cmp_a <= r(AX);
              cmp_b <= std_logic_vector(resize(signed(operand), 16));
              current_state <= FETCH_MEM;
            WHEN CMP_REG => 
              cmp_a <= r(AX);
              cmp_b <= r(to_integer(unsigned(operand)));
              current_state <= FETCH_MEM;
            WHEN SALT => 
              PC <= to_integer(unsigned(operand));
              current_state <= FETCH_MEM;
            WHEN SI_IG => 
              flag_branch <= EQU;
              current_state <= EXE_BRAN;
            WHEN SI_MY => 
              flag_branch <= GRE;
              current_state <= EXE_BRAN;
            WHEN SI_MN => 
              flag_branch <= LESS;
              current_state <= EXE_BRAN;
            WHEN SI_MYI => 
              flag_branch <= GRE OR EQU;
              current_state <= EXE_BRAN;
            WHEN SI_MNI => 
              flag_branch <= LESS OR EQU;
              current_state <= EXE_BRAN;

            -- PERIFÉRICOS
            WHEN PAUSA => 
              t <= CLK_FREQ * to_integer(unsigned(operand));
              current_state <= EXE_PAUSA;
            WHEN ENC_LED => 
              index := to_integer(unsigned(operand));
              led(index) <= '1';
              current_state <= FETCH_MEM;
            WHEN APA_LED => 
              index:= to_integer(unsigned(operand));
              led(index) <= '0';
              current_state <= FETCH_MEM;
            WHEN ENC_LEDR => 
              index := to_integer(unsigned(r(to_integer(unsigned(operand)))));
              led(index) <= '1';
              current_state <= FETCH_MEM;
            WHEN MOSTRAR => 
              display_reset <= '1';
              display_number <= r(AX);
              current_state <= FETCH_MEM;
            WHEN PARAR => 
              led <= (OTHERS => '0');
              display_number <= x"0000";
              current_state <= HALT_STATE;
            WHEN OTHERS => NULL;
        END CASE;

        -- CICLOS DE EJECUCIÓN
        WHEN MEM_SYNC =>
          from_mem <= true;
          current_state <= EXE_MOV;
        WHEN EXE_MOV =>
          IF from_mem THEN r(destination) <= rom_data;
          ELSE r(destination) <= source; END IF;
          from_mem <= false;
          current_state <= FETCH_MEM;
        WHEN EXE_ALU =>
          r(destination) <= result;
          current_state <= FETCH_MEM;
        WHEN EXE_BRAN =>
          IF flag_branch THEN PC <= to_integer(unsigned(operand)); END IF;
          current_state <= FETCH_MEM;
        WHEN EXE_PAUSA =>
          IF counter < t THEN
            counter <= counter + 1;
            current_state <= EXE_PAUSA;
          ELSE
            counter <= 0;
            current_state <= FETCH_MEM;
          END IF;
        WHEN HALT_STATE =>  -- Se queda aquí
          current_state <= HALT_STATE;
      END CASE;
    END IF;
  END PROCESS U_CONTROL;
 
  mbr <= PC WHEN current_state = FETCH_MEM OR current_state = FETCH ELSE mar;
END ARCHITECTURE Behavioral;