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
        i_alive_en  :   in      STD_LOGIC; --enable of frame IDLE
        i_run1_en   :   in      STD_LOGIC; --enable of frame Run
        i_run2_en   :   in      STD_LOGIC; --enable of frame Run
        i_dead_en   :   in      STD_LOGIC; --enable of frame Collide with cactus
        o_draw_dino :   out     STD_LOGIC
    );
end draw_dino;

architecture RTL of draw_dino is
    signal r_alive_dino    :   STD_LOGIC   :='0';
    signal r_run1_dino     :   STD_LOGIC   :='0';
    signal r_run2_dino     :   STD_LOGIC   :='0';
    signal r_dead_dino     :   STD_LOGIC   :='0';

    begin
    --------------------------------------------------------------------
    --Determine which dino should be drawn based on the frame we are in.
    --------------------------------------------------------------------
    o_draw_dino  <= r_alive_dino when i_alive_en = '1' else
                    r_run1_dino  when i_run1_en = '1'  else
                    r_run2_dino  when i_run2_en = '1'  else   
                    r_dead_dino  when i_dead_en = '1'  else
                    '0';

    ---------------------------------------------------------
    --Draw 4 different frame of dino at certain location
    ---------------------------------------------------------
    r_alive_dino <= pc_alive(r_y - i_y_dino, r_x - pc_X_DINO) 
                    when (r_x>= pc_X_DINO and r_x<= pc_X_DINO + pc_DINO_SIZE) 
                    and  (r_y>= r_y_dino  and r_y<= r_y_dino  + pc_DINO_SIZE) else '0';

    r_run1_dino  <= pc_run1(r_y - i_y_dino, r_x - pc_X_DINO) 
                    when (r_x>= pc_X_DINO and r_x<= pc_X_DINO + pc_DINO_SIZE) 
                    and  (r_y>= r_y_dino  and r_y<= r_y_dino  + pc_DINO_SIZE) else '0';
    
    r_run2_dino  <= pc_run2(r_y - i_y_dino, r_x - pc_X_DINO) 
                    when (r_x>= pc_X_DINO and r_x<= pc_X_DINO + pc_DINO_SIZE) 
                    and  (r_y>= r_y_dino  and r_y<= r_y_dino  + pc_DINO_SIZE) else '0';

    r_dead_dino <= pc_dead(r_y - i_y_dino, r_x - pc_X_DINO) 
                    when (r_x>= pc_X_DINO and r_x<= pc_X_DINO + pc_DINO_SIZE) 
                    and  (r_y>= r_y_dino  and r_y<= r_y_dino  + pc_DINO_SIZE) else '0';                

    end RTL;