library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LFSR5 is
    port (
        i_clk   :   in      STD_LOGIC;
        i_reset :   in      STD_LOGIC;
        o_lfsr  :   out     unsigned(4 downto 0) 
    );
end LFSR3;

architecture RTL of LFSR5 is
    signal r_lfsr      :   unsigned(4 downto 0)    :=(others=>'0');
	 signal r_xnor :  STD_LOGIC  :='0';
    begin
        process(i_clk) is
            begin
                if rising_edge(i_clk) then
                    r_lfsr <= r_lfsr(3 downto 0) & r_xnor;
                end if;
            end process;
            o_lfsr <= r_lfsr;
				r_xnor <= r_lfsr(4) xnor r_lfsr(3);
    end RTL;