library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity draw_bat is
    port (
        i_x         :   in      unsigned(pc_GAME_BITS -1 downto 0);
        i_y         :   in      unsigned(pc_GAME_BITS -1 downto 0);
        i_x_bat     :   in      signed(pc_GAME_BITS+1 downto 0);  --one bit more because signed
        i_wing1_DV  :   in      STD_LOGIC;
		  i_wing2_DV  :   in      STD_LOGIC;
        o_draw_bat  :   out     STD_LOGIC
    );
end draw_bat;

architecture RTL of draw_bat is
    signal      r_x     :   integer;
    signal      r_y     :   integer;
    signal      r_x_bat :   integer;
	signal r_draw_bat1  :   STD_LOGIC   :='0';
	signal r_draw_bat2  :   STD_LOGIC   :='0';
    begin
        r_x <= to_integer(i_x);
        r_y <= to_integer(i_y);
        r_x_bat <= to_integer(i_x_bat);

        o_draw_bat <= r_draw_bat1 when i_wing1_DV= '1' else 
							r_draw_bat2 when i_wing2_DV = '1' else
							'0';

        r_draw_bat1 <= pc_bat1(r_y - 20)(r_x - r_x_bat) when ( r_x >= r_x_bat and r_x < r_x_bat + pc_BAT_WIDTH )
                                                        and (r_y >= 20 and r_y <=35) else
                                                        '0';

        r_draw_bat2 <= pc_bat2(r_y - 20)(r_x - r_x_bat) when ( r_x >= r_x_bat and r_x < r_x_bat + pc_BAT_WIDTH ) and
                                                        (r_y >= 20 and r_y <=35) else
                                                        '0';
    end RTL;