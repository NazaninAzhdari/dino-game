library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SevenSeg_display is
    port (
        i_clk       :       in      STD_LOGIC;
        i_BCD       :       in      unsigned(3 downto 0);
        i_en        :       in      STD_LOGIC;
        o_7seg      :       out     unsigned(6 downto 0)
    );
end SevenSeg_display;

architecture RTL of SevenSeg_display is
    signal r_7seg   :   unsigned(o_7seg'left downto 0)      :=(others=>'0');

    begin
        process(i_clk) is
            begin
                if rising_edge(i_clk) then
                    if i_en = '1' then
                        case i_BCD is
                            when "0000" =>
                                r_7seg <= "1111110";

                            when "0001" =>
                                r_7seg <= "0110000";

                            when "0010" =>
                                r_7seg <= "1101101";

                            when "0011" =>
                                r_7seg <= "1111001";

                            when "0100" =>
                                r_7seg <= "0110011";

                            when "0101" =>
                                r_7seg <= "1011011";

                            when "0110" =>
                                r_7seg <= "1011111";

                            when "0111" =>
                                r_7seg <= "1110000";

                            when "1000" =>
                                r_7seg <= "1111111";

                            when "1001" =>
                                r_7seg <= "1111011";

                            when "1010" =>
                                r_7seg <= "1110111";

                            when "1011" =>
                                r_7seg <= "0011111";

                            when "1100" =>
                                r_7seg <= "1001110";

                            when "1101" =>
                                r_7seg <= "0111101";

                            when "1110" =>
                                r_7seg <= "1001111";

                            when "1111" =>
                                r_7seg <= "1000111";

                            when others =>
                                r_7seg <= "0000000";
                        end case;
                    end if;
                end if;
            end process;

            o_7seg <= r_7seg;
    end RTL;