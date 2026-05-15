library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity draw_dino is
    port (
        i_clk       :   in      STD_LOGIC;  --25MHz
        i_reset     :   in      STD_LOGIC;
        i_x         :   in      unsigned(pc_GAME_BITS -1 downto 0);
        i_y         :   in      unsigned(pc_GAME_BITS -1 downto 0);
        i_y_dino    :   in      unsigned(pc_GAME_BITS -1 downto 0);
        i_stand_en  :   in      STD_LOGIC; --enable of standing frame
        i_run_en    :   in      STD_LOGIC; --enable of Run frame
        i_dead_en   :   in      STD_LOGIC; --enable of dead frame
		i_jump_en 	:	in 	    STD_LOGIC; --enable of jump frame
        i_crawl_en  :   in      STD_LOGIC; --enable of crawl frame
        o_draw_dino :   out     STD_LOGIC
    );
end draw_dino;

architecture RTL of draw_dino is
    --Different frames of Dino
    signal r_stand_dino    :   STD_LOGIC   :='0';
    signal r_runner_dino	:	STD_LOGIC 	:='0';
    signal r_crawling_dino	:	STD_LOGIC 	:='0';
    signal r_dead_dino     :   STD_LOGIC   :='0';

    signal r_run1_dino     :   STD_LOGIC   :='0';
    signal r_run2_dino     :   STD_LOGIC   :='0';
    signal r_crawl1_dino   :   STD_LOGIC   :='0';    
    signal r_crawl2_dino   :   STD_LOGIC   :='0';
    signal r_run1_DV       :   STD_LOGIC   :='0';

	signal r_x              :  integer range 0 to pc_GAME_WIDTH -1  :=0;
	signal r_y              :  integer range 0 to pc_GAME_HEIGHT-1  :=0;
	signal r_y_dino         :  integer range 0 to pc_GAME_HEIGHT-1  :=0;
	signal i, j             :  integer                              :=0;
    signal i_crwl, j_crwl   :  integer                              :=0;
	
    begin
	    r_x <= to_integer(i_x);
	    r_y <= to_integer(i_y);
	    r_y_dino <= to_integer(i_y_dino);
        --------------------------------------------------------------------
        --Determine which dino should be drawn based on the frame we are in.
        --------------------------------------------------------------------
        o_draw_dino  <= r_dead_dino     when i_dead_en = '1'  else 
                        r_stand_dino    when i_stand_en = '1' or i_jump_en = '1' or r_y_dino /= pc_Y_START else
                        r_crawling_dino when i_crawl_en = '1' else 
                        r_runner_dino;
                        
        --NB for myself! 
        --Regarding this condition "i_jump_en = '1' or r_y_dino /= pc_Y_START"
        --we press jump button once, and then take our finger, but jumping takes more time. 
        --so even though i_jump_en is not 1, but dino y position is higher than ground, so we stay in the stand frame.


        ---------------------------------------------------------
        --Draw 6 different frame of dino at certain location
        ---------------------------------------------------------
        i <= r_y - r_y_dino;
        j <= r_x - pc_X_DINO;
        
        r_stand_dino <= pc_stand(i)(j) 
                        when (r_x>= pc_X_DINO and r_x< pc_X_DINO + pc_DINO_SIZE) 
                        and  (r_y>= r_y_dino  and r_y< r_y_dino  + pc_DINO_SIZE) else '0';

        r_dead_dino <= pc_dead(i)(j)
                        when (r_x>= pc_X_DINO and r_x< pc_X_DINO + pc_DINO_SIZE) 
                        and  (r_y>= r_y_dino  and r_y< r_y_dino  + pc_DINO_SIZE) else '0'; 

        r_run1_dino  <= pc_run1(i)(j) 
                        when (r_x>= pc_X_DINO and r_x< pc_X_DINO + pc_DINO_SIZE) 
                        and  (r_y>= r_y_dino  and r_y< r_y_dino  + pc_DINO_SIZE) else '0';
        
        r_run2_dino  <= pc_run2(i)(j)
                        when (r_x>= pc_X_DINO and r_x< pc_X_DINO + pc_DINO_SIZE) 
                        and  (r_y>= r_y_dino  and r_y< r_y_dino  + pc_DINO_SIZE) else '0';

        i_crwl <= r_y - pc_Y_CRAWL;
        j_crwl <= r_x - pc_X_DINO;
                        
        r_crawl1_dino <= pc_crawl1(i_crwl)(j_crwl)
                        when (r_x>= pc_X_DINO and r_x< pc_X_DINO + pc_CRAWL_WIDTH) 
                        and  (r_y>= pc_Y_CRAWL  and r_y< pc_Y_CRAWL + pc_CRAWL_HEIGHT) else '0';

        r_crawl2_dino <= pc_crawl2(i_crwl)(j_crwl)
                        when (r_x>= pc_X_DINO and r_x< pc_X_DINO + pc_CRAWL_WIDTH) 
                        and  (r_y>= pc_Y_CRAWL  and r_y< pc_Y_CRAWL + pc_CRAWL_HEIGHT) else '0';
        

        ---------------------------------------------------------------------------
        --Making the Dino alive by changing the position of the feet each 0.1 Sec
        ---------------------------------------------------------------------------
        generating_enable_signal_for_changing_feet: entity work.make_alive
        generic map(
            g_SPEED => pc_RUNNING_SPEED
        )
        port map(
            i_clk=> i_clk,
            i_run_en=> i_run_en,
            i_reset=> i_reset,
            o_frame1_DV => r_run1_DV,
            o_frame2_DV=> open
        );

        r_runner_dino <= r_run1_dino when r_run1_DV = '1' else r_run2_dino;
        r_crawling_dino <= r_crawl1_dino when r_run1_DV = '1' else r_crawl2_dino;

    end RTL;