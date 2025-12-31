LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.instruction_set.ALL;
USE work.registers.ALL;

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
 
  SIGNAL regs : REGISTERS := (OTHERS => (OTHERS => '0'));
  SIGNAL reg_addr : INTEGER RANGE 0 TO 4;
  SIGNAL data_to_load : std_logic_vector(15 DOWNTO 0);

  TYPE STATE IS (FETCH_MEM, FETCH, DECODE, MEM_SYNC, EXECUTE);
  SIGNAL current_state : STATE := FETCH;
  
  SIGNAL PC : INTEGER RANGE 0 TO 255 := 0;
  SIGNAL IR : std_logic_vector(15 DOWNTO 0);
 
  SIGNAL alu_op : std_logic_vector(1 DOWNTO 0);
  SIGNAL alu_inA : std_logic_vector(15 DOWNTO 0);
  SIGNAL alu_inB : std_logic_vector(15 DOWNTO 0);
  SIGNAL alu_res : std_logic_vector(15 DOWNTO 0);
  SIGNAL carry, overflow, sign : std_logic;
 
  SIGNAL mbr : INTEGER RANGE 0 TO 255 := PC;
  SIGNAL addr_operand : INTEGER RANGE 0 TO 255;
  SIGNAL rom_data : std_logic_vector(15 DOWNTO 0);
 
  SIGNAL display_reset : std_logic := '0';
  SIGNAL display_number : std_logic_vector(15 DOWNTO 0) := x"0000";
 
  SIGNAL cmp_a, cmp_b : std_logic_vector(15 DOWNTO 0) := x"0000";
  SIGNAL G, E, L : std_logic;
 
  SIGNAL counter_delay : INTEGER RANGE 0 TO INTEGER'HIGH := 0;
  SIGNAL target_delay : INTEGER RANGE 0 TO INTEGER'HIGH := 0;

BEGIN
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
      G => G,
      E => E,
      L => L
    );
 
  ALU : ENTITY work.ARITH_UNIT
    GENERIC MAP(LEN => 16)
    PORT MAP(
      A => alu_inA, 
      B => alu_inB, 
      OP_SEL => alu_op, 
      F_ARIT => alu_res, 
      C_OUT => carry, 
      OVF_OUT => overflow, 
      SIGN_OUT => sign
    );
 

 
  DISPLAY : ENTITY work.DISPLAY_CONTROLLER
    GENERIC MAP(clk_freq => 50000)
    PORT MAP(
      clk => clk, 
      reset => display_reset, 
      data_in => display_number, 
      segments => segments, 
      anodes => digits
    );
 
PROCESS (clk, reset)
  VARIABLE op_code : std_logic_vector(7 DOWNTO 0);
  VARIABLE operand : std_logic_vector(7 DOWNTO 0);
  VARIABLE led : INTEGER RANGE 0 TO 4;
  CONSTANT CLK_FREQ : INTEGER := 50000000;
  BEGIN
    IF NOT reset THEN 
      current_state <= FETCH_MEM;
      CASE sw IS
        WHEN "00" => PC <= 0; 
        WHEN "01" => PC <= 30; 
        WHEN "10" => PC <= 70; 
        WHEN OTHERS => PC <= 196;
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
              reg_addr <= ACC;
              addr_operand <= to_integer(unsigned(operand));
				  current_state <= MEM_SYNC;
            WHEN MOV_R => 
              reg_addr <= to_integer(unsigned(operand));
              data_to_load <= regs(ACC);
              current_state <= EXECUTE;
            WHEN MOV_A => 
              reg_addr <= ACC;
              data_to_load <= regs(to_integer(unsigned(operand)));
              current_state <= EXECUTE;
            WHEN LDA_IMM => 
              reg_addr <= ACC;
              data_to_load <= std_logic_vector(resize(signed(operand), 16));
              current_state <= EXECUTE;
            WHEN ADD => 
              reg_addr <= ACC;
              alu_op <= "00";
              alu_inA <= regs(ACC);
              alu_inB <= regs(to_integer(unsigned(operand)));
              current_state <= EXECUTE;
            WHEN SUBS => 
              reg_addr <= ACC;
              alu_op <= "01";
              alu_inA <= regs(ACC);
              alu_inB <= regs(to_integer(unsigned(operand)));
              current_state <= EXECUTE;
            WHEN MULT => 
              reg_addr <= ACC;
              alu_op <= "10";
              alu_inA <= regs(ACC);
              alu_inB <= regs(to_integer(unsigned(operand)));
              current_state <= EXECUTE;
            WHEN DIV => 
              reg_addr <= ACC;
              alu_op <= "11";
              alu_inA <= regs(ACC);
              alu_inB <= regs(to_integer(unsigned(operand)));
              current_state <= EXECUTE;
            WHEN ADD_IMM => 
              reg_addr <= ACC;
              alu_op <= "00";
              alu_inA <= regs(ACC);
              alu_inB <= std_logic_vector(resize(signed(operand), 16));
              current_state <= EXECUTE;
            WHEN SUB_IMM => 
              reg_addr <= ACC;
              alu_op <= "01";
              alu_inA <= regs(ACC);
              alu_inB <= std_logic_vector(resize(signed(operand), 16));
              current_state <= EXECUTE;
            WHEN CMP_IMM => 
              cmp_a <= regs(ACC);
              cmp_b <= std_logic_vector(resize(signed(operand), 16));
              current_state <= FETCH_MEM;
            WHEN CMP_REG => 
              cmp_a <= regs(ACC);
              cmp_b <= regs(to_integer(unsigned(operand)));
              current_state <= FETCH_MEM;
            WHEN JMP => 
              PC <= to_integer(unsigned(operand));
              current_state <= FETCH_MEM;
            WHEN BCE => 
              IF E THEN
                PC <= to_integer(unsigned(operand));
              END IF;
              current_state <= FETCH_MEM;
            WHEN BCG => 
              IF G THEN
                PC <= to_integer(unsigned(operand));
              END IF;
              current_state <= FETCH_MEM;
            WHEN BCL => 
              IF L THEN
                PC <= to_integer(unsigned(operand));
              END IF;
              current_state <= FETCH_MEM;
            WHEN BCGE => 
              IF G OR E THEN
                PC <= to_integer(unsigned(operand));
              END IF;
              current_state <= FETCH_MEM;
            WHEN BCLE => 
              IF L OR E THEN
                PC <= to_integer(unsigned(operand));
              END IF;
              current_state <= FETCH_MEM;
            WHEN SLEEP => 
              target_delay <= CLK_FREQ * to_integer(unsigned(operand)); 
              current_state <= EXECUTE;
            WHEN ON_LED => 
              led := to_integer(unsigned(operand));
              leds(led) <= '1';
              current_state <= FETCH_MEM;
            WHEN OFF_LED => 
              led := to_integer(unsigned(operand));
              leds(led) <= '0';
              current_state <= FETCH_MEM;
            WHEN ON_LEDR => 
              led := to_integer(unsigned(regs(to_integer(unsigned(operand)))));
              leds(led) <= '1';
              current_state <= FETCH_MEM;
            WHEN DISPLAY => 
              display_reset <= '1';
              display_number <= regs(ACC);
              current_state <= FETCH_MEM;
            WHEN HALT => 
              leds <= (OTHERS => '0');
              display_number <= x"0000";
              current_state <= DECODE;
            WHEN OTHERS => NULL;
        END CASE;
		  WHEN MEM_SYNC =>
		    current_state <= EXECUTE;
        WHEN EXECUTE => 
          CASE op_code IS
            WHEN LDA_MEM => 
				  regs(reg_addr) <= rom_data;
              current_state <= FETCH_MEM;
            WHEN ADD | SUBS | MULT | DIV | ADD_IMM | SUB_IMM => 
				  regs(reg_addr) <= alu_res;
              current_state <= FETCH_MEM;
            WHEN SLEEP => 
              IF counter_delay < target_delay THEN
                counter_delay <= counter_delay + 1;
                current_state <= EXECUTE;
              ELSE
                counter_delay <= 0;
                current_state <= FETCH_MEM;
              END IF;
            WHEN OTHERS => 
				  regs(reg_addr) <= data_to_load;
              current_state <= FETCH_MEM;
        END CASE;
      END CASE;
    END IF;
  END PROCESS;
 
  mbr <= PC WHEN current_state = FETCH_MEM OR current_state = FETCH ELSE addr_operand;
 
END ARCHITECTURE Behavioral;