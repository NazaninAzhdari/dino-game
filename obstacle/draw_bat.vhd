library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity draw_bat is
    port (
        i_x                 :   in      unsigned(pc_GAME_BITS -1 downto 0);
        i_y                 :   in      unsigned(pc_GAME_BITS -1 downto 0);
        i_x_bat             :   in      signed(pc_GAME_BITS downto 0);      --one bit more, because its signed
        i_wing1_DV          :   in      STD_LOGIC;
		i_wing2_DV          :   in      STD_LOGIC;
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

    begin
        r_x <= to_integer(i_x);
        r_y <= to_integer(i_y);
        r_x_bat <= to_integer(i_x_bat);

        ----------------------------------------------------
        --Drawing Bats in different locations
        ----------------------------------------------------
        --Drawing a bat in the top of the page.
        --width = 32, height = 16

        --Y Start = 80
        --Y End = 95
        o_draw_bat_top <= r_bat2_top when i_wing2_DV= '1' else 
                                r_bat1_top;

        r_bat1_top <= pc_bat1(r_y - pc_Y_TOP_BAT)(r_x - r_x_bat) when ( r_x >= r_x_bat and r_x < r_x_bat + pc_BAT_WIDTH )
                                                            and (r_y >= pc_Y_TOP_BAT and r_y < pc_Y_TOP_BAT + pc_BAT_HEIGHT) else
                                                            '0';

        r_bat2_top <= pc_bat2(r_y - pc_Y_TOP_BAT)(r_x - r_x_bat) when ( r_x >= r_x_bat and r_x < r_x_bat + pc_BAT_WIDTH ) and
                                                            (r_y >= pc_Y_TOP_BAT and r_y < pc_Y_TOP_BAT + pc_BAT_HEIGHT) else
                                                            '0';                                            


        -------------------------------------------
        --Drawing a bat in the middle of the page.
        --width = 32, height = 16

        --Y Start = 96
        --Y End = 111
        o_draw_bat_middle <= r_bat2_middle when i_wing2_DV= '1' else 
                                r_bat1_middle;

        r_bat1_middle <= pc_bat1(r_y - pc_Y_MIDDLE_BAT)(r_x - r_x_bat) when ( r_x >= r_x_bat and r_x < r_x_bat + pc_BAT_WIDTH )
                                                            and (r_y >= pc_Y_MIDDLE_BAT and r_y < pc_Y_MIDDLE_BAT + pc_BAT_HEIGHT) else
                                                            '0';

        r_bat2_middle <= pc_bat2(r_y - pc_Y_MIDDLE_BAT)(r_x - r_x_bat) when ( r_x >= r_x_bat and r_x < r_x_bat + pc_BAT_WIDTH ) and
                                                            (r_y >= pc_Y_MIDDLE_BAT and r_y < pc_Y_MIDDLE_BAT + pc_BAT_HEIGHT) else
                                                            '0';  


        ---------------------------------------------
        --Drawing a bat in the buttom of the page.
        --width = 32, height = 16

        --Y Start = 102
        --Y End = 117                         
        o_draw_bat_buttom <= r_bat2_buttom when i_wing2_DV= '1' else 
                                r_bat1_buttom;

        r_bat1_buttom <= pc_bat1(r_y - pc_Y_BUTTOM_BAT)(r_x - r_x_bat) when ( r_x >= r_x_bat and r_x < r_x_bat + pc_BAT_WIDTH )
                                                            and (r_y >= pc_Y_BUTTOM_BAT and r_y < pc_Y_BUTTOM_BAT + pc_BAT_WIDTH) else
                                                            '0';

        r_bat2_buttom <= pc_bat2(r_y - pc_Y_BUTTOM_BAT)(r_x - r_x_bat) when ( r_x >= r_x_bat and r_x < r_x_bat + pc_BAT_WIDTH ) and
                                                            (r_y >= pc_Y_BUTTOM_BAT and r_y < pc_Y_BUTTOM_BAT + pc_BAT_HEIGHT) else
                                                            '0';
    end RTL;




    