library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity draw_cloud is
    port (
        i_x             :   in      STD_LOGIC;
        i_y             :   in      STD_LOGIC;
        i_x_cloud       :   in      STD_LOGIC;
        o_draw_cloud    :   out     STD_LOGIC;
    );
end draw_cloud;

architecture RTL of draw_cloud is
    signal r_x          :   integer range 0 to pc_GAME_WIDTH -1   :=0;
    signal r_y          :   integer range 0 to pc_GAME_HEIGHT -1  :=0;
    signal r_x_cloud    :   integer;

    begin
        r_x <= to_integer(i_x);
        r_y <= to_integer(i_y);
        r_x_cloud <= to_integer(i_x_cloud);

        o_draw_cloud <= pc_cloud(r_y - pc_Y_CLOUD)(r_x - r_x_cloud)
                                        when (r_y >= pc_Y_CLOUD and r_y < pc_Y_CLOUD + pc_CLOUD_HEIGHT)
                                        and (r_x >= r_x_cloud and r_x < r_x_cloud + pc_CLOUD_WIDTH)
                                        else '0';

    end RTL;