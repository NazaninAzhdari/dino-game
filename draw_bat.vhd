library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity draw_bat is
    port (
        i_clk               :   in      STD_LOGIC; --25MHz
        i_run_en            :   in      STD_LOGIC;
        i_reset             :   in      STD_LOGIC;
        i_x                 :   in      unsigned(pc_GAME_BITS -1 downto 0);
        i_y                 :   in      unsigned(pc_GAME_BITS -1 downto 0);
        i_x_bat             :   in      signed(pc_GAME_BITS downto 0);      --one bit more, because its signed
        o_draw_top_bat      :   out     STD_LOGIC;
        o_draw_middle_bat   :   out     STD_LOGIC;
        o_draw_buttom_bat   :   out     STD_LOGIC
    );
end draw_bat;

architecture RTL of draw_bat is
    signal      r_x     :   integer range 0 to pc_GAME_WIDTH  - 1   :=0;
    signal      r_y     :   integer range 0 to pc_GAME_HEIGHT - 1   :=0;
    signal      r_x_bat :   integer;

	signal r_bat1_top       :   STD_LOGIC   :='0';
	signal r_bat2_top       :   STD_LOGIC   :='0';
    signal r_bat1_middle    :   STD_LOGIC   :='0';
	signal r_bat2_middle    :   STD_LOGIC   :='0';
    signal r_bat1_buttom    :   STD_LOGIC   :='0';
	signal r_bat2_buttom    :   STD_LOGIC   :='0';
    signal r_wing2_DV       :   STD_LOGIC   :='0';


    begin
        r_x <= to_integer(i_x);
        r_y <= to_integer(i_y);
        r_x_bat <= to_integer(i_x_bat);

        ----------------------------------------------------
        --Drawing Bats in different locations
        ----------------------------------------------------
        --Drawing a bat in the top of the page.
        --width = 32, height = 16

        --Y Start = 65
        --Y End = 65 + 16
        r_bat1_top <= pc_bat1(r_y - pc_Y_TOP_BAT)(r_x - r_x_bat) when ( r_x >= r_x_bat and r_x < r_x_bat + pc_BAT_WIDTH )
                                                            and (r_y >= pc_Y_TOP_BAT and r_y < pc_Y_TOP_BAT + pc_BAT_HEIGHT) else
                                                            '0';

        r_bat2_top <= pc_bat2(r_y - pc_Y_TOP_BAT)(r_x - r_x_bat) when ( r_x >= r_x_bat and r_x < r_x_bat + pc_BAT_WIDTH ) and
                                                            (r_y >= pc_Y_TOP_BAT and r_y < pc_Y_TOP_BAT + pc_BAT_HEIGHT) else
                                                            '0';                                            


        -------------------------------------------
        --Drawing a bat in the middle of the page.
        --width = 32, height = 16

        --Y Start = 70
        --Y End = 70 + 16
        r_bat1_middle <= pc_bat1(r_y - pc_Y_MIDDLE_BAT)(r_x - r_x_bat) when ( r_x >= r_x_bat and r_x < r_x_bat + pc_BAT_WIDTH )
                                                            and (r_y >= pc_Y_MIDDLE_BAT and r_y < pc_Y_MIDDLE_BAT + pc_BAT_HEIGHT) else
                                                            '0';

        r_bat2_middle <= pc_bat2(r_y - pc_Y_MIDDLE_BAT)(r_x - r_x_bat) when ( r_x >= r_x_bat and r_x < r_x_bat + pc_BAT_WIDTH ) and
                                                            (r_y >= pc_Y_MIDDLE_BAT and r_y < pc_Y_MIDDLE_BAT + pc_BAT_HEIGHT) else
                                                            '0';  


        ---------------------------------------------
        --Drawing a bat in the buttom of the page.
        --width = 32, height = 16

        --Y Start = 85
        --Y End = 85 + 16                         
        r_bat1_buttom <= pc_bat1(r_y - pc_Y_BUTTOM_BAT)(r_x - r_x_bat) when ( r_x >= r_x_bat and r_x < r_x_bat + pc_BAT_WIDTH )
                                                            and (r_y >= pc_Y_BUTTOM_BAT and r_y < pc_Y_BUTTOM_BAT + pc_BAT_HEIGHT) else
                                                            '0';

        r_bat2_buttom <= pc_bat2(r_y - pc_Y_BUTTOM_BAT)(r_x - r_x_bat) when ( r_x >= r_x_bat and r_x < r_x_bat + pc_BAT_WIDTH ) and
                                                            (r_y >= pc_Y_BUTTOM_BAT and r_y < pc_Y_BUTTOM_BAT + pc_BAT_HEIGHT) else
                                                            '0';


         ---------------------------------------------------------------------------
        --Making the Bat alive by changing the position of ist wing each 0.2 Sec
        ---------------------------------------------------------------------------                                                   
        generating_enable_signal_for_changing_wings: entity work.make_alive
        generic map(
            g_SPEED => pc_WING_SPEED
        )
        port map(
            i_clk=> i_clk,
            i_run_en=> i_run_en,
            i_reset=> i_reset,
            o_frame1_DV => open,
            o_frame2_DV=> r_wing2_DV
        );

        o_draw_buttom_bat <= r_bat2_buttom when r_wing2_DV= '1' else r_bat1_buttom;
        o_draw_middle_bat <= r_bat2_middle when r_wing2_DV= '1' else r_bat1_middle;
        o_draw_top_bat <= r_bat2_top when r_wing2_DV= '1' else r_bat1_top;

    end RTL;




    