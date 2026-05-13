library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;


entity draw_cactus is
    port (
        i_clk       :   in      STD_LOGIC;
        i_x_div_4   :   in      unsigned(pc_GAME_BITS - 1 downto 0);
        i_y_div_4   :   in      unsigned(pc_GAME_BITS - 1 downto 0);
        i_x_cactus  :   in      signed(pc_GAME_BITS  downto 0); --one bit more
        i_lfsr      :   in      unsigned(2 downto 0);
        i_cactus_DV :   in      STD_LOGIC;
        o_cactus_ID:    out      unsigned(1 downto 0);
        o_draw_cactus:   out      STD_LOGIC
    );
end draw_cactus;

architecture RTL of draw_cactus is
    signal r_big_cactus     :   STD_LOGIC   :='0';
    signal r_2_big_cactus   :   STD_LOGIC   :='0';
    signal r_small_cactus   :   STD_LOGIC   :='0';
    signal r_2_small_cactus :   STD_LOGIC   :='0';

    signal   r_x   : integer  :=0;
    signal   r_y_div_4   : integer  :=0;
    signal   r_y_div_8   : integer  :=0;
    signal   r_x_cactus   : integer  :=0;
	 
	 signal r_cactus_ID  :  unsigned(1 downto 0)   :=(others=>'0');
     

    begin
    o_draw_cactus <=r_big_cactus when r_cactus_ID = "00" else
                    r_2_small_cactus when r_cactus_ID = "01" else
                    r_2_big_cactus when r_cactus_ID = "10" else
                    r_small_cactus;    
    
    process(i_clk) is
        begin
            if rising_edge(i_clk) then
                if i_cactus_DV = '1' then
                    r_cactus_ID <= i_lfsr(1 downto 0);
                end if;
            end if;
        end process;

        o_cactus_ID <= r_cactus_ID;

    r_x <= to_integer(i_x_div_4);
    r_y_div_4 <= to_integer(i_y_div_4);
    r_y_div_8 <= to_integer(i_y_div_4(i_y_div_4'left downto 1));
    r_x_cactus <= to_integer(i_x_cactus);


    --Drawing small cactus
    --width = 16
    --height = 16
    r_small_cactus <= pc_cactus (r_y_div_4 - 102)(r_x - r_x_cactus) when (r_y_div_4>= 102 and r_y_div_4 <= 117) 
                                                    and (r_x >= r_x_cactus and r_x < r_x_cactus + pc_CACTUS_WIDTH)										 
                                                    else '0';

    --Drawing Big cactus
    --width = 16
    --height = 32
    r_big_cactus <= pc_cactus(r_y_div_8 - 43)(r_x - r_x_cactus) when (r_y_div_8>= 43 and r_y_div_8 <= 58) 
                                            and r_x >= r_x_cactus and r_x < r_x_cactus + pc_CACTUS_WIDTH 							  
                                            else '0';

    --Drawing 2 small cactuses
    --width = 32
    --height = 16
    r_2_small_cactus <= pc_cactus (r_y_div_4 - 102)(r_x - r_x_cactus) when ((r_y_div_4>= 102 and r_y_div_4 <= 117) 
                                                        and ( r_x >= r_x_cactus and r_x < r_x_cactus + pc_CACTUS_WIDTH ))
                                                        else 
                        pc_cactus (r_y_div_4 - 102)(r_x - r_x_cactus - 17) when ((r_y_div_4>= 102 and r_y_div_4 <= 117) 
                                                        and (r_x >= r_x_cactus + 17 and r_x < r_x_cactus +17 + pc_CACTUS_WIDTH ))
                                                        else '0';

    --Drawing 2 big cactuses
    --width = 32
    --height = 32
    r_2_big_cactus <= pc_cactus (r_y_div_8 - 43)(r_x - r_x_cactus) when((r_y_div_8>= 43 and r_y_div_8 <= 58) 
                                                and (r_x >= r_x_cactus and r_x < r_x_cactus + pc_CACTUS_WIDTH ))
                                                else 
                        pc_cactus (r_y_div_8 - 43)(r_x - r_x_cactus - 17) when ((r_y_div_8>= 43 and r_y_div_8 <= 58) 
                                                and( r_x >= r_x_cactus + 17 and r_x < r_x_cactus+ 17 + pc_CACTUS_WIDTH ))
                                                else '0';

    
    end RTL;