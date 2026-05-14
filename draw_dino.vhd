library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity draw_dino is
    port (
        i_x         :   in      unsigned(pc_GAME_BITS -1 downto 0);
        i_y         :   in      unsigned(pc_GAME_BITS -1 downto 0);
        i_y_dino    :   in      unsigned(pc_GAME_BITS -1 downto 0);
        i_stand_en  :   in      STD_LOGIC; --enable of standing frame
        i_run1_en   :   in      STD_LOGIC; --enable of frame Run
        i_run2_en   :   in      STD_LOGIC; --enable of frame Run
        i_dead_en   :   in      STD_LOGIC; --enable of frame Collide with cactus
		i_jump_en 	:	in 	STD_LOGIC;
        o_draw_dino :   out     STD_LOGIC
    );
end draw_dino;

architecture RTL of draw_dino is
    signal r_stand_dino    :   STD_LOGIC   :='0';
    signal r_run1_dino     :   STD_LOGIC   :='0';
    signal r_run2_dino     :   STD_LOGIC   :='0';
    signal r_dead_dino     :   STD_LOGIC   :='0';
	signal r_x   :  integer range 0 to pc_GAME_WIDTH-1  :=0;
	signal r_y   :  integer range 0 to pc_GAME_HEIGHT-1  :=0;
	signal r_y_dino   :  integer range 0 to pc_GAME_HEIGHT-1  :=0;
	signal i, j   :   integer  :=0;
	
    begin
	 r_x <= to_integer(i_x);
	 r_y <= to_integer(i_y);
	 r_y_dino <= to_integer(i_y_dino);
    --------------------------------------------------------------------
    --Determine which dino should be drawn based on the frame we are in.
    --------------------------------------------------------------------
    o_draw_dino  <= r_dead_dino  when i_dead_en = '1'  else
							r_stand_dino when i_stand_en = '1' else
							r_stand_dino when i_jump_en = '1' or r_y_dino /= pc_Y_START else
                    r_run1_dino  when i_run1_en = '1' else
                    r_run2_dino  when i_run2_en = '1'  else   
                    r_dead_dino  when i_dead_en = '1'  else
                    '0';

    ---------------------------------------------------------
    --Draw 4 different frame of dino at certain location
    ---------------------------------------------------------
	 i <= r_y - r_y_dino;
	 j <= r_x - pc_X_DINO;
	 
    r_stand_dino <= pc_stand(i)(j) 
                    when (r_x>= pc_X_DINO and r_x< pc_X_DINO + pc_DINO_SIZE) 
                    and  (r_y>= r_y_dino  and r_y< r_y_dino  + pc_DINO_SIZE) else '0';

    r_run1_dino  <= pc_run1(i)(j) 
                    when (r_x>= pc_X_DINO and r_x< pc_X_DINO + pc_DINO_SIZE) 
                    and  (r_y>= r_y_dino  and r_y< r_y_dino  + pc_DINO_SIZE) else '0';
    
    r_run2_dino  <= pc_run2(i)(j)
                    when (r_x>= pc_X_DINO and r_x< pc_X_DINO + pc_DINO_SIZE) 
                    and  (r_y>= r_y_dino  and r_y< r_y_dino  + pc_DINO_SIZE) else '0';

    r_dead_dino <= pc_dead(i)(j)
                    when (r_x>= pc_X_DINO and r_x< pc_X_DINO + pc_DINO_SIZE) 
                    and  (r_y>= r_y_dino  and r_y< r_y_dino  + pc_DINO_SIZE) else '0';                

    end RTL;