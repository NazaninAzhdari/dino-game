library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity bat_top is 
    port (
        i_clk25     :   in      STD_LOGIC;
        i_reset     :   in      STD_LOGIC;
        i_run_en    :   in      STD_LOGIC;
        i_x         :   in      unsigned(pc_GAME_BITS -1 downto 0);
        i_y         :   in      unsigned(pc_GAME_BITS -1 downto 0);
        i_wing1_DV  :   in      STD_LOGIC;
		  i_wing2_DV  :   in      STD_LOGIC;
        o_draw_bat  :   out     STD_LOGIC
    );
end bat_top;

architecture RTL of bat_top is
    signal w_x_bat  :    signed(pc_GAME_BITS+1 downto 0)  :=(others=>'0');

    begin

        --------------------------------
        --bat movement
        --------------------------------
        bat_movement: entity work.bat_move
        generic map(
            g_X_INITIAL=> 500
        )
        port map(
            i_clk=> i_clk25,
            i_reset=> i_reset,
            i_run_en=> i_run_en,
            o_x_bat=> w_x_bat
        );

        ---------------------------------
        --draw bat
        ---------------------------------
        drawing_bat: entity work.draw_bat
        port map(
            i_x=> i_x,
            i_y=> i_y,
            i_x_bat=> w_x_bat,
            i_wing1_DV=> i_wing1_DV,
				i_wing2_DV=> i_wing2_DV,
            o_draw_bat=> o_draw_bat
        );


    end RTL;