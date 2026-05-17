library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity draw_start is
    port (
        i_x             :   in      unsigned(pc_GAME_BITS -1 downto 0);
        i_y             :   in      unsigned(pc_GAME_BITS -1 downto 0);
        o_draw_start    :   out     STD_LOGIC
    );
end draw_start;

architecture RTL of draw_start is
    signal r_x          :   integer range 0 to pc_GAME_WIDTH -1   :=0;
    signal r_y          :   integer range 0 to pc_GAME_HEIGHT -1  :=0;

    begin
        r_x <= to_integer(i_x(pc_GAME_BITS-1 downto 1));
        r_y <= to_integer(i_y(pc_GAME_BITS-1 downto 1));
        
    o_draw_start <= pc_start(r_y -12 )(r_x - 20) when (r_y >= 12 and r_y < 32) and (r_x>= 20 and r_x <60) else '0';

    end RTL;