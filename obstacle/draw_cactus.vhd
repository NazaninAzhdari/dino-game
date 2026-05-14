library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;


entity draw_cactus is
    port (
        i_clk                   :   in       STD_LOGIC;
        i_x                     :   in       unsigned(pc_GAME_BITS - 1 downto 0);
        i_y                     :   in       unsigned(pc_GAME_BITS - 1 downto 0);
        i_x_cactus              :   in       signed(pc_GAME_BITS  downto 0);       --one bit more, BCS its signed
        o_draw_small_cactus     :   out      STD_LOGIC;
        o_draw_sbig_cactus      :   out      STD_LOGIC;
        o_draw_2_small_cactus   :   out      STD_LOGIC;
        o_draw_2_big_cactus     :   out      STD_LOGIC
    );
end draw_cactus;

architecture RTL of draw_cactus is
    signal   r_x                      :   integer range 0 to pc_GAME_WIDTH  -1     :=0;
    signal   r_y                      :   integer range 0 to pc_GAME_HEIGHT -1     :=0; 
    signal   r_x_cactus               :   integer     :=0;
    signal   r_x_second_small_cactus  :   integer     :=0;
    signal   r_x_second_big_cactus    :   integer     :=0;
    
    begin

        r_x <= to_integer(i_x);
        r_y<= to_integer(i_y);
        r_x_cactus <= to_integer(i_x_cactus);

        ---------------------------------------------
        --Drawing different size of Cactuses
        ---------------------------------------------
        --Drawing an small cactus.
        --width = 8
        --height = 16
        o_draw_small_cactus <= pc_small_cactus (r_y - pc_Y_SMALL_CACTUS)(r_x - r_x_cactus) when 
                                                        (r_y>= pc_Y_SMALL_CACTUS and r_y < pc_Y_SMALL_CACTUS + pc_SMALL_CACTUS_HEIGHT) 
                                                        and (r_x >= r_x_cactus and r_x < r_x_cactus + pc_SMALL_CACTUS_WIDTH )										 
                                                        else '0';

        ----------------------------------------------
        --Drawing a Big cactus.
        --width = 16
        --height = 32
        o_draw_big_cactus <= pc_big_cactus(r_y - pc_Y_BIG_CACTUS)(r_x - r_x_cactus) when 
                                                (r_y>= pc_Y_BIG_CACTUS and r_y < pc_Y_BIG_CACTUS + pc_BIG_CACTUS_HEIGHT) 
                                                and (r_x >= r_x_cactus and r_x < r_x_cactus + pc_BIG_CACTUS_WIDTH ) 							  
                                                else '0';

        -----------------------------------------------
        --Drawing 2 small cactuses.
        --width of each  = 8,  Total width  = 17
        --height of each = 16, Total height = 16
        o_draw_2_small_cactus <= pc_small_cactus (r_y - pc_Y_SMALL_CACTUS)(r_x - r_x_cactus) when (
                                                        (r_y>= pc_Y_SMALL_CACTUS and r_y < pc_Y_SMALL_CACTUS + pc_SMALL_CACTUS_HEIGHT) 
                                                        and ( r_x >= r_x_cactus and r_x < r_x_cactus + pc_SMALL_CACTUS_WIDTH ))
                                                        else 
                            pc_small_cactus (r_y - pc_Y_SMALL_CACTUS)(r_x - r_x_second_small_cactus) when (
                                                        (r_y>= pc_Y_SMALL_CACTUS and r_y < pc_Y_SMALL_CACTUS + pc_SMALL_CACTUS_HEIGHT) 
                                                        and (r_x >= r_x_second_small_cactus and r_x < r_x_second_small_cactus + pc_SMALL_CACTUS_WIDTH )) --9 +8 = 17
                                                        else '0';

        r_x_second_small_cactus <= r_x_cactus + pc_SMALL_CACTUS_WIDTH + 1;  --1 added for space between two cactuses                                              

        ----------------------------------------------
        --Drawing 2 big cactuses.
        --width of each  = 16, Total width  = 33
        --height of each = 32, Total height = 32
        o_draw_2_big_cactus <= pc_big_cactus (r_y - pc_Y_BIG_CACTUS)(r_x - r_x_cactus) when(
                                                    (r_y>= pc_Y_BIG_CACTUS and r_y< pc_Y_BIG_CACTUS + pc_BIG_CACTUS_HEIGHT) 
                                                    and (r_x >= r_x_cactus and r_x < r_x_cactus + pc_BIG_CACTUS_WIDTH ))
                                                    else 
                            pc_big_cactus (r_y - pc_Y_BIG_CACTUS)(r_x - r_x_second_big_cactus) when (
                                                    (r_y>= pc_Y_BIG_CACTUS and r_y< pc_Y_BIG_CACTUS + pc_BIG_CACTUS_HEIGHT) 
                                                    and( r_x >= r_x_second_big_cactus and r_x < r_x_second_big_cactus + pc_BIG_CACTUS_WIDTH ))
                                                    else '0';

        r_x_second_big_cactus <= r_x_cactus + pc_BIG_CACTUS_WIDTH + 1;  --1 added for space between two cactuses                                          
    
    end RTL;



 