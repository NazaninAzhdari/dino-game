library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity double_dabble is
    generic (
        g_BINARY_BIT_LIMIT      :   integer     :=8;
        g_DECIMAL_DIGIT_LIMIT   :   integer     :=2
    );
    port (
        i_clk       :   in      STD_LOGIC;
        i_en        :   in      STD_LOGIC;
        i_binary    :   in      unsigned(g_BINARY_BIT_LIMIT -1 downto 0);
        o_BCD_DV    :   out     STD_LOGIC;
        o_BCD       :   out     unsigned(g_DECIMAL_DIGIT_LIMIT*4 -1 downto 0)
    );
end double_dabble;

architecture RTL of double_dabble is
    type t_double_dabble_SM is(IDLE,SHIFT, CHECK_VALUE, CHECK_SHIFT, OVER);
    signal r_SM     :   t_double_dabble_SM                                  :=IDLE;

    signal r_binary         :   unsigned(i_binary'left downto 0)            :=(others=>'0');
    signal r_BCD            :   unsigned(o_BCD'left downto 0)               :=(others=>'0');
    signal r_BCD_index      :   integer range 0 to g_DECIMAL_DIGIT_LIMIT    :=0;
    signal r_shift_index    :   integer range 0 to g_BINARY_BIT_LIMIT       :=0;  
    constant c_BCD_LIMIT    :   integer                                     :=g_DECIMAL_DIGIT_LIMIT;
	 
    begin
        process(i_clk) is
				variable v_LSB    :   natural;
				variable v_BCD 	:	 unsigned(3 downto 0);

            begin
                if rising_edge(i_clk) then
                    case r_SM is
                        when IDLE =>  
                            r_shift_index <= 0;
                            r_bcd_index <= 0;

                            if i_en = '1' then   
                                r_binary <= i_binary;
                                r_BCD <= (others =>'0');
                                r_SM <= SHIFT;
                            end if;
                        
                        when SHIFT =>
                            r_BCD <= r_BCD(r_BCD'left-1 downto 0) & r_binary(r_binary'left);
                            r_binary <= r_binary(r_binary'left-1 downto 0) & '0';
                            r_shift_index <= r_shift_index + 1;

                            r_SM <= CHECK_SHIFT;
									 
						when CHECK_SHIFT =>
                            if r_shift_index < g_BINARY_BIT_LIMIT then
                                r_SM <= CHECK_VALUE;
                            else
                                r_SM <= OVER;
                                r_shift_index <= 0;
                            end if;
                        
                        when CHECK_VALUE =>
                            v_LSB := r_BCD_INDEX*4;
									 v_BCD := r_BCD(v_LSB + 3 downto v_LSB);

                            if r_BCD_index < c_BCD_LIMIT then
                                if v_BCD >= 5 then
                                    v_BCD := v_BCD  + 3;
                                end if;
                                
										  r_BCD(v_LSB + 3 downto v_LSB) <= v_BCD;
                                r_BCD_INDEX <= r_BCD_INDEX + 1;
                                r_SM <= CHECK_VALUE;

                            else
                                r_BCD_INDEX <= 0;
                                r_SM <= SHIFT;
                            end if;

                        when over =>
                            r_SM <= IDLE;
                        
                        when others =>
                            r_SM <= IDLE;

                        end case;
                end if;
            end process;

            o_BCD <= r_BCD;
            o_BCD_DV <= '1' when r_SM = OVER else '0';

    end RTL;