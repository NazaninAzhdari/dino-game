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
        o_draw_cactus:   out      STD_LOGIC;
        o_y_cactus : out   integer;
        o_cactus_width  : out   integer
    );
end draw_cactus;

architecture RTL of draw_cactus is
    signal r_big_cactus     :   STD_LOGIC   :='0';
    signal r_2_big_cactus   :   STD_LOGIC   :='0';
    signal r_small_cactus   :   STD_LOGIC   :='0';
    signal r_2_small_cactus :   STD_LOGIC   :='0';

    signal   r_x   : integer  :=0;
    signal   r_y   : integer  :=0;
    
    signal   r_x_cactus   : integer  :=0;
	 
	 signal r_cactus_ID  :  unsigned(1 downto 0)   :=(others=>'0');
     

    begin
    o_draw_cactus <=r_small_cactus when r_cactus_ID = "00" else
                    r_big_cactus when r_cactus_ID = "01" else
                    r_2_small_cactus when r_cactus_ID = "10" else
                    r_2_big_cactus;   

    o_cactus_width <= 8 when r_cactus_ID = "00" else
                    16 when r_cactus_ID = "01" else
                    17 when r_cactus_ID = "01" else
                    33;

    o_y_cactus <= 102 when r_cactus_ID = "00" or r_cactus_ID = "10" else  --not completed
                    86;
    
    process(i_clk) is
        begin
            if rising_edge(i_clk) then
                if i_cactus_DV = '1' then
                    r_cactus_ID <= i_lfsr(1 downto 0);
                end if;
            end if;
        end process;

    

    r_x <= to_integer(i_x_div_4);
    r_y<= to_integer(i_y_div_4);
    
    r_x_cactus <= to_integer(i_x_cactus);


    --Drawing small cactus x=8 y=16
    --width = 8
    --height = 16
    r_small_cactus <= pc_small_cactus (r_y - 102)(r_x - r_x_cactus) when (r_y>= 102 and r_y <= 117) 
                                                    and (r_x >= r_x_cactus and r_x < r_x_cactus + 8 )										 
                                                    else '0';

    --Drawing Big cactus x=16 y=32
    --width = 16
    --height = 32
    r_big_cactus <= pc_big_cactus(r_y - 86)(r_x - r_x_cactus) when (r_y>= 86 and r_y <= 117) 
                                            and (r_x >= r_x_cactus and r_x < r_x_cactus + 16 ) 							  
                                            else '0';

    --Drawing 2 small cactuses, each  X= 8 y=16
                            -- total  X= 17 y=16
    --width = 17
    --height = 16
    r_2_small_cactus <= pc_small_cactus (r_y - 102)(r_x - r_x_cactus) when ((r_y>= 102 and r_y <= 117) 
                                                        and ( r_x >= r_x_cactus and r_x < r_x_cactus + 8 ))
                                                        else 
                        pc_small_cactus (r_y - 102)(r_x - r_x_cactus - 9) when ((r_y>= 102 and r_y <= 117) 
                                                        and (r_x >= r_x_cactus + 9 and r_x < r_x_cactus +17 )) --9 +8 = 17
                                                        else '0';

    --Drawing 2 big cactuses, each  X=16 y=32
                            --total x=33 y=32
    --width = 33
    --height = 32
    r_2_big_cactus <= pc_big_cactus (r_y - 86)(r_x - r_x_cactus) when((r_y>= 86 and r_y<= 117) 
                                                and (r_x >= r_x_cactus and r_x < r_x_cactus + 16 ))
                                                else 
                        pc_big_cactus (r_y - 86)(r_x - r_x_cactus - 17) when ((r_y>= 86 and r_y <= 117) 
                                                and( r_x >= r_x_cactus + 17 and r_x < r_x_cactus+ 33 ))
                                                else '0';

    
    end RTL;