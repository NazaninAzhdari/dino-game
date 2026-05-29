library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity make_alive is
    generic (
        g_SPEED     :   integer     :=1000      --speed of changing the frame
    );
    port (
        i_clk       :   in      STD_LOGIC;
        i_run_en    :   in      STD_LOGIC;
        i_reset     :   in      STD_LOGIC;
        o_frame1_DV :   out     STD_LOGIC;
        o_frame2_DV :   out     STD_LOGIC
    );
end make_alive;

architecture RTL of make_alive is
    signal r_counter    :   integer range 0 to g_SPEED :=0;
    signal r_frame1_DV  :   STD_LOGIC   :='1';
    signal r_frame2_DV  :   STD_LOGIC   :='0';

    begin
        --------------------------------------------------------------------------------------------
        --Making the Elements alive by changing the position of the feet for Dino, or wings for Bat
        --------------------------------------------------------------------------------------------
        process(i_clk, i_reset) is
            begin
                if i_reset = '1' then
                    r_counter <= 0;
                    r_frame1_Dv <= '1';
                    r_frame2_DV <= '0';
                    
                elsif rising_edge(i_clk) then
                    if i_run_en = '1' then
                    --Changing the frame of Feet or wings each 0.1 Sec
                            if r_counter < g_SPEED then
                                r_counter <= r_counter + 1;
                            else
                                r_counter <= 0;

                                if r_frame1_DV = '1' then
                                    r_frame1_DV <= '0';
                                    r_frame2_DV <= '1';
                                else
                                    r_frame1_DV <= '1';
                                    r_frame2_DV <= '0';
                                end if;
                            end if;
                        end if;
                    end if;
            end process;

            o_frame1_DV <= r_frame1_DV;
            o_frame2_DV <= r_frame2_DV;

    end RTL;