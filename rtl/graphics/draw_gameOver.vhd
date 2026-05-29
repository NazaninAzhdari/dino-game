library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity draw_gameOver is
    port (
        i_x                    :       in      unsigned(pc_GAME_BITS-1 downto 0);
        i_y                    :       in      unsigned(pc_GAME_BITS-1 downto 0);
        o_draw_gameOver_txt    :       out     STD_LOGIC
    );
end draw_gameOver;

architecture RTL of draw_gameOver is
    signal r_x          :   integer range 0 to pc_GAME_WIDTH-1          :=0;
    signal r_y          :   integer range 0 to pc_GAME_HEIGHT-1         :=0;

    begin
        r_x <= to_integer(i_x);
        r_y <= to_integer(i_y);
                            
        o_draw_gameOver_txt <=  pf_draw_letter_G(r_x-40, r_y-30) when r_y >= 30 and r_y <= 36 and r_x >= 40 and r_x <= 44 else
                                pf_draw_letter_A(r_x-50, r_y-30) when r_y >= 30 and r_y <= 36 and r_x >= 50 and r_x <= 54 else
                                pf_draw_letter_M(r_x-60, r_y-30) when r_y >= 30 and r_y <= 36 and r_x >= 60 and r_x <= 64 else
                                pf_draw_letter_E(r_x-70, r_y-30) when r_y >= 30 and r_y <= 36 and r_x >= 70 and r_x <= 74 else

                                pf_draw_letter_O(r_x-90, r_y-30) when r_y >= 30 and r_y <= 36 and r_x >= 90 and r_x <= 94 else
                                pf_draw_letter_V(r_x-100, r_y-30) when r_y >= 30 and r_y <= 36 and r_x >= 100 and r_x <= 104 else
                                pf_draw_letter_E(r_x-110, r_y-30) when r_y >= 30 and r_y <= 36 and r_x >= 110 and r_x <= 114 else
                                pf_draw_letter_R(r_x-120, r_y-30) when r_y >= 30 and r_y <= 36 and r_x >= 120 and r_x <= 124 else
                                '0';
    end RTL;