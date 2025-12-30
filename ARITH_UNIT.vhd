library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ARITH_UNIT is
    generic (LEN : natural := 10);
    port (
        -- Entradas
        A       : in  std_logic_vector(LEN - 1 downto 0);
        B       : in  std_logic_vector(LEN - 1 downto 0);
        OP_SEL  : in  std_logic_vector(1 downto 0);  -- Selector de operación
        -- Salidas
        F_ARIT  : out std_logic_vector(LEN - 1 downto 0);
		  -- Banderas (Activas en bajo)
        C_OUT   : out std_logic;                     -- Bit de acarreo
        OVF_OUT : out std_logic;                     -- Overflow
        SIGN_OUT: out std_logic                      -- Signo (Negativo)
    );
end entity ARITH_UNIT;

architecture Behavioral of ARITH_UNIT is
    
    -- Función para detectar overflow en multiplicación
    function multiplication_overflow(res_full : signed; res_msb: std_logic) 
        return boolean is
        variable v_ovf : boolean := false;
    begin
        for i in LEN to (2*LEN)-1 loop
            if res_full(i) /= res_msb then
                v_ovf := true;
                exit;
            end if;
        end loop;
        return v_ovf;
    end function;

begin

    -- Proceso combinacional
    ARITH : process (A, B, OP_SEL)
        
        variable res_add_sub : signed(LEN downto 0);
        variable res_mul     : signed((2 * LEN) - 1 downto 0);
		  variable res_div     : signed(LEN - 1 downto 0); -- Variable para división
        variable v_ovf       : boolean;
		  
		  -- Constante para detectar MIN_INT (100...0)
        constant MIN_INT     : signed(LEN - 1 downto 0) := (LEN - 1 => '1', others => '0');
        
    begin
        -- Inicializar salidas por defecto (activas en ALTO = '1' = inactivo)
        F_ARIT   <= (others => '0');
        C_OUT    <= '1';
        OVF_OUT  <= '1'; -- No hay overflow
        SIGN_OUT <= '1'; -- Positivo
        
        -- case para seleccionar la operación
        case OP_SEL is
            
            -- "00" : SUMA (A + B)
            when "00" =>
                res_add_sub := ('0' & signed(A)) + ('0' & signed(B));
                F_ARIT      <= std_logic_vector(res_add_sub(LEN - 1 downto 0));
                C_OUT       <= not res_add_sub(LEN); 

                -- Detección de Overflow (Suma)
                v_ovf := (A(LEN-1) = B(LEN-1)) and (A(LEN-1) /= res_add_sub(LEN-1));
                
                if v_ovf then
                    OVF_OUT <= '0';
                end if;
					 
                -- Detección de Signo (Suma):
                -- El MSB del resultado es '1' (negativo)
                if res_add_sub(LEN-1) = '1' then
                    SIGN_OUT <= '0'; -- '0' = Resultado Negativo
                end if;

            -- "01" : RESTA (A - B)
            when "01" =>
                res_add_sub := ('0' & signed(A)) - ('0' & signed(B));
                F_ARIT      <= std_logic_vector(res_add_sub(LEN - 1 downto 0));
                C_OUT       <= not res_add_sub(LEN);

                -- Detección de Overflow (Resta)
                v_ovf := (A(LEN-1) /= B(LEN-1)) and (B(LEN-1) = res_add_sub(LEN-1));

                if v_ovf then
                    OVF_OUT <= '0';
                end if;

                -- Detección de Signo (Resta)
                if res_add_sub(LEN-1) = '1' then
                    SIGN_OUT <= '0'; -- '0' = Resultado Negativo
                end if;

            -- "10" : MULTIPLICACIÓN (A * B)
            when "10" =>
                res_mul := signed(A) * signed(B);
                F_ARIT  <= std_logic_vector(res_mul(LEN - 1 downto 0));
                C_OUT   <= '1';

                -- Detección de Overflow (Multiplicación)
                v_ovf := multiplication_overflow(res_mul, res_mul(LEN-1));
                
                if v_ovf then
                    OVF_OUT <= '0'; -- '0' = Overflow detectado
                end if;
					 
                -- Detección de Signo (Multiplicación):
                -- Es '0' (activo) si el MSB del resultado truncado es '1' (negativo)
                if res_mul(LEN-1) = '1' then
                    SIGN_OUT <= '0'; -- '0' = Resultado Negativo
                end if;
					 
				-- "11" : DIVISIÓN (A / B)
            when "11" =>
                C_OUT <= '1'; -- No aplica Carry en división

                -- Caso 1: División por Cero
                if signed(B) = 0 then
                    OVF_OUT <= '0';       -- Flag de Overflow indica Error
                    F_ARIT  <= (others => '0'); -- Resultado por defecto
                    SIGN_OUT <= '1';

                -- Caso 2: Overflow Signed (MIN_INT / -1)
                elsif signed(A) = MIN_INT and signed(B) = -1 then
                    OVF_OUT <= '0';       -- El resultado sería positivo fuera de rango
                    F_ARIT  <= std_logic_vector(MIN_INT); -- Resultado indefinido/truncado
                    SIGN_OUT <= '0';      -- Técnicamente el resultado real es positivo, pero el truncado es negativo

                -- Caso 3: División Normal
                else
                    res_div := signed(A) / signed(B);
                    F_ARIT  <= std_logic_vector(res_div);
                    
                    -- Detección de Signo (División)
                    if res_div(LEN-1) = '1' then
                        SIGN_OUT <= '0';
                    end if;
                end if;

            -- Caso por defecto (selector inválido)
            when others =>
                F_ARIT   <= (others => '0');
                C_OUT    <= '1';
                OVF_OUT  <= '1';
                SIGN_OUT <= '1';
                
        end case;
        
    end process ARITH;

end architecture Behavioral;
