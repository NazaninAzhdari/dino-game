library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity cloud_top is
    port (
        i_clk       :   in      STD_LOGIC;
        i_reset     :   in      STD_LOGIC;
        i_run_en    :   in      STD_LOGIC;
        i_x         :   in      unsigned(pc_GAME_BITS -1 downto 0);
        i_y         :   in      unsigned(pc_GAME_BITS -1 downto 0);
        o_draw_cloud:   out     STD_LOGIC
    );
end cloud_top;

architecture RTL of cloud_top is
    signal w_x_cloud    :   signed(pc_GAME_BITS downto 0)   :=(others=>'0');

    begin
        --------------------------------
        -- Clouds movement
        --------------------------------
        move_clouds: entity work.object_movement
        generic map(
            g_X_INITIAL=> 200,
            g_MOVEMENT_SPEED=> pc_CLOUD_SPEED
        )
        port map(
            i_clk=> i_clk,
            i_reset=> i_reset,
            i_run_en=> i_run_en,
            i_object_width=> pc_CLOUD_WIDTH,
            o_object_DV=> open,
            o_x_object=> w_x_cloud
        );

        --------------------------------
        -- Drawing the clouds
        --------------------------------
        draw_clouds: entity work.draw_cloud
        port map(
            i_x => i_x,
            i_y => i_y,
            i_x_cloud => w_x_cloud,
            o_draw_cloud=> o_draw_cloud
        );

    end RTL;