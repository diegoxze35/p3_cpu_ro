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
    sw : IN std_logic_vector(1 DOWNTO 0);
    leds : OUT std_logic_vector(4 DOWNTO 0);
    segments : OUT std_logic_vector(6 DOWNTO 0); 
    digits : OUT std_logic_vector(3 DOWNTO 0) 
  );

END ENTITY CPU;

ARCHITECTURE Behavioral OF CPU IS
  -- =======================================
  -- REGISTROS DE PROPOSITO GENERAL
  -- =======================================
  TYPE REGISTER_ARRAY IS ARRAY(0 to 3) OF std_logic_vector(15 downto 0);
  SIGNAL r : REGISTER_ARRAY := (0 to 3 => (x"0000"));
  SIGNAL destination : INTEGER RANGE 0 TO 4;
  SIGNAL source : std_logic_vector(15 DOWNTO 0);
  -- =========================================
  -- MAQUINA DE ESTADOS PARA UNIDAD DE CONTROL
  -- =========================================
  TYPE STATE IS (FETCH_MEM, FETCH, DECODE, MEM_SYNC, /*EXECUTE,*/ EXE_MOV, EXE_ALU, EXE_BRAN, EXE_DELAY);
  SIGNAL from_mem : boolean := false;
  SIGNAL flag_branch : std_logic := '0';
  SIGNAL current_state : STATE := FETCH;
  -- =======================================
  -- REGISTROS ESPECIFICOS
  -- =======================================
  SIGNAL PC : INTEGER RANGE 0 TO 255 := 0;
  SIGNAL IR : std_logic_vector(15 DOWNTO 0);
  -- =======================================
  -- SEÑALES ALU
  -- =======================================
  SIGNAL alu_op_code : std_logic_vector(1 DOWNTO 0);
  SIGNAL alu_inA : std_logic_vector(15 DOWNTO 0);
  SIGNAL alu_inB : std_logic_vector(15 DOWNTO 0);
  SIGNAL result : std_logic_vector(15 DOWNTO 0);
  SIGNAL carry, overflow, sign : std_logic;
  -- =======================================
  -- REGISTROS DE MEMORIA
  -- =======================================
  SIGNAL mbr : INTEGER RANGE 0 TO 255 := PC;
  SIGNAL mar : INTEGER RANGE 0 TO 255;
  SIGNAL rom_data : std_logic_vector(15 DOWNTO 0);
  -- =======================================
  -- SEÑALES DISPLAY
  -- =======================================
  SIGNAL display_reset : std_logic := '0';
  SIGNAL display_number : std_logic_vector(15 DOWNTO 0) := x"0000";
  -- =======================================
  -- SEÑALES COMPARADOR
  -- =======================================
  SIGNAL cmp_a, cmp_b : std_logic_vector(15 DOWNTO 0) := x"0000";
  SIGNAL GRE, EQU, LESS : std_logic;
  -- =======================================
  -- SEÑALES INSTRUCCIÓN DE DELAY
  -- =======================================
  SIGNAL counter_delay : INTEGER := 0;
  SIGNAL target_delay : INTEGER := 0;

BEGIN
  -- =======================================
  -- Componentes
  -- =======================================
  MEM : ENTITY work.MAIN_MEMORY
    PORT MAP(
      clk => clk, 
      addr => mbr, 
      dout => rom_data
    );
  CMP : ENTITY work.COMPARATOR
    PORT MAP(
      A => cmp_a,
      B => cmp_b,
      G => GRE,
      E => EQU,
      L => LESS
    );
  ALU : ENTITY work.ARITH_UNIT
    GENERIC MAP(LEN => 16)
    PORT MAP(
      A => alu_inA, 
      B => alu_inB, 
      OP_SEL => alu_op_code, 
      F_ARIT => result, 
      C_OUT => carry, 
      OVF_OUT => overflow, 
      SIGN_OUT => sign
    );
  DISPLAY : ENTITY work.DISPLAY
    GENERIC MAP(clk_freq => 50000)
    PORT MAP(
      clk => clk, 
      reset => display_reset, 
      data_in => display_number, 
      segments => segments, 
      anodes => digits
    );
 
U_CONTROL: PROCESS (clk, reset)
  VARIABLE op_code : std_logic_vector(7 DOWNTO 0);
  VARIABLE operand : std_logic_vector(7 DOWNTO 0);
  VARIABLE led : INTEGER RANGE 0 TO 4;
  CONSTANT CLK_FREQ : INTEGER := 50000000;
  BEGIN
    IF NOT reset THEN 
      current_state <= FETCH_MEM;
      CASE NOT sw IS
        WHEN "00" => PC <= EQ1_ADDR; 
        WHEN "01" => PC <= EQ2_ADDR; 
        WHEN "10" => PC <= EQ3_ADDR; 
        WHEN OTHERS => PC <= 255;
      END CASE;
      leds <= (OTHERS => '0');
      display_reset <= '0';
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
            WHEN LDA_MEM => 
              destination <= AX;
              mar <= to_integer(unsigned(operand));
				  current_state <= MEM_SYNC;
            WHEN MOV_R => 
              destination <= to_integer(unsigned(operand));
              source <= r(AX);
				  current_state <= EXE_MOV;
            WHEN MOV_A => 
              destination <= AX;
              source <= r(to_integer(unsigned(operand)));
				  current_state <= EXE_MOV;
            WHEN LDA_IMM => 
              destination <= AX;
              source <= std_logic_vector(resize(signed(operand), 16));
				  current_state <= EXE_MOV;
            WHEN ADD => 
              destination <= AX;
              alu_op_code <= "00";
              alu_inA <= r(AX);
              alu_inB <= r(to_integer(unsigned(operand)));
				  current_state <= EXE_ALU;
            WHEN SUBS => 
              destination <= AX;
              alu_op_code <= "01";
              alu_inA <= r(AX);
              alu_inB <= r(to_integer(unsigned(operand)));
				  current_state <= EXE_ALU;
            WHEN MULT => 
              destination <= AX;
              alu_op_code <= "10";
              alu_inA <= r(AX);
              alu_inB <= r(to_integer(unsigned(operand)));
				  current_state <= EXE_ALU;
            WHEN DIV => 
              destination <= AX;
              alu_op_code <= "11";
              alu_inA <= r(AX);
              alu_inB <= r(to_integer(unsigned(operand)));
				  current_state <= EXE_ALU;
            WHEN ADD_IMM => 
              destination <= AX;
              alu_op_code <= "00";
              alu_inA <= r(AX);
              alu_inB <= std_logic_vector(resize(signed(operand), 16));
				  current_state <= EXE_ALU;
            WHEN SUB_IMM => 
              destination <= AX;
              alu_op_code <= "01";
              alu_inA <= r(AX);
              alu_inB <= std_logic_vector(resize(signed(operand), 16));
				  current_state <= EXE_ALU;
            WHEN CMP_IMM => 
              cmp_a <= r(AX);
              cmp_b <= std_logic_vector(resize(signed(operand), 16));
              current_state <= FETCH_MEM;
            WHEN CMP_REG => 
              cmp_a <= r(AX);
              cmp_b <= r(to_integer(unsigned(operand)));
              current_state <= FETCH_MEM;
            WHEN JMP => 
              PC <= to_integer(unsigned(operand));
              current_state <= FETCH_MEM;
            WHEN BCE => 
				  flag_branch <= EQU;
				  current_state <= EXE_BRAN;
            WHEN BCG => 
				  flag_branch <= GRE;
				  current_state <= EXE_BRAN;
            WHEN BCL => 
				  flag_branch <= LESS;
				  current_state <= EXE_BRAN;
            WHEN BCGE => 
				  flag_branch <= GRE OR EQU;
				  current_state <= EXE_BRAN;
            WHEN BCLE => 
				  flag_branch <= LESS OR EQU;
				  current_state <= EXE_BRAN;
            WHEN DELAY => 
              target_delay <= CLK_FREQ * to_integer(unsigned(operand));
				  current_state <= EXE_DELAY;
            WHEN ON_LED => 
              led := to_integer(unsigned(operand));
              leds(led) <= '1';
              current_state <= FETCH_MEM;
            WHEN OFF_LED => 
              led := to_integer(unsigned(operand));
              leds(led) <= '0';
              current_state <= FETCH_MEM;
            WHEN ON_LEDR => 
              led := to_integer(unsigned(r(to_integer(unsigned(operand)))));
              leds(led) <= '1';
              current_state <= FETCH_MEM;
            WHEN PRINT => 
              display_reset <= '1';
              display_number <= r(AX);
              current_state <= FETCH_MEM;
            WHEN HALT => 
              leds <= (OTHERS => '0');
              display_number <= x"0000";
              current_state <= DECODE;
            WHEN OTHERS => NULL;
        END CASE;
		  WHEN MEM_SYNC =>
          from_mem <= true;
          current_state <= EXE_MOV;
		  WHEN EXE_MOV =>
		    IF from_mem THEN
			   r(destination) <= rom_data;
			 ELSE
			   r(destination) <= source;
			 END IF;
			 from_mem <= false;
			 current_state <= FETCH_MEM;
		  WHEN EXE_ALU =>
		    r(destination) <= result;
          current_state <= FETCH_MEM;
		  WHEN EXE_BRAN =>
		    IF flag_branch THEN
			   PC <= to_integer(unsigned(operand));
			 END IF;
			 current_state <= FETCH_MEM;
		  WHEN EXE_DELAY =>
		    IF counter_delay < target_delay THEN
            counter_delay <= counter_delay + 1;
            current_state <= EXE_DELAY;
          ELSE
            counter_delay <= 0;
            current_state <= FETCH_MEM;
          END IF;
      END CASE;
    END IF;
  END PROCESS U_CONTROL;
 
  mbr <= PC WHEN current_state = FETCH_MEM OR current_state = FETCH ELSE mar;
 
END ARCHITECTURE Behavioral;