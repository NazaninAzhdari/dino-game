library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity dino_SM is
    port (
        i_clk           :   in      STD_LOGIC; --25MHz 
        i_reset         :   in      STD_LOGIC;
        i_start         :   in      STD_LOGIC;
        i_jump_button_L :   in      STD_LOGIC;
        i_crawl_button_L:   in      STD_LOGIC;
        o_stand_en      :   out     STD_LOGIC;
        o_dead_en       :   out     STD_LOGIC;
        o_jump_en       :   out     STD_LOGIC;
        o_run_en        :   out     STD_LOGIC;
        o_crawl_en      :   out     STD_LOGIC;
        o_reset_game    :   out     STD_LOGIC;

        --input ports for detecting the collision
		i_x_obstacle        :   in      signed(pc_GAME_BITS downto 0);
		i_y_obstacle        :   in      integer;
		i_obstacle_width    :   in      integer;
        i_obstacle_height   :   in      integer;
		i_y_dino            :   in      unsigned(pc_GAME_BITS -1 downto 0)
    );
end dino_SM;

architecture RTL of dino_SM is
    type state_machine is (IDLE ,RUN, GAME_OVER);
    signal r_SM         :   state_machine   :=IDLE;
    signal r_start      :   STD_LOGIC       :='0';
    signal r_reset      :   STD_LOGIC       :='0';
               
	signal r_y_dino     :  integer range 0 to pc_GAME_HEIGHT -1 :=0;
	signal r_x_obstacle :  integer;
    signal r_y_end_obstacle : integer;
    signal r_x_end_obstacle : integer;

    begin
        r_y_dino <= to_integer(i_y_dino);
        r_x_obstacle <= to_integer(i_x_obstacle);
        r_y_end_obstacle <= i_y_obstacle + i_obstacle_height;
        r_x_end_obstacle <= r_x_obstacle + i_obstacle_width;

        -----------------------------------------------------------------------
        --Registering reset and start switches for detecting the falling edge
        -----------------------------------------------------------------------
        process(i_clk) is
            begin
                if rising_edge(i_clk ) then
                    r_reset <= i_reset;
                    r_start <= i_start;
                end if;
            end process;

        ------------------------------    
        --Dino Game State Machine
        ------------------------------
        process(i_clk, i_reset, r_reset) is
            begin
                if i_reset = '0' and r_reset = '1' then  --by falling edge of reset switch, the game gets reset
                    r_SM <= IDLE;
                    o_reset_game <= '1';                 --a reset signal to drive into other modules

                elsif rising_edge(i_clk) then 
                    case r_SM is
                        when IDLE => 
							o_reset_game <= '0';		 
                            if i_start = '0' and r_start = '1' then  --by falling edge of start switch, the game starts
                                r_SM <= RUN;
                            end if;

                        when RUN =>
                            if i_crawl_button_L = '0' then
                                --When Crawling:
                                --Dino can collide with cactus from front side
                                --Dino can collide with bat from front side

                                if  ((r_x_obstacle>= pc_X_START_COL_AREA and r_x_obstacle <= pc_X_END_COL_AREA) and
                                     ((i_y_obstacle >= pc_Y_CRAWL and i_y_obstacle <= pc_Y_CRAWL + pc_CRAWL_HEIGHT) or
					                  (r_y_end_obstacle  >= pc_Y_CRAWL  and r_y_end_obstacle <= pc_Y_CRAWL + pc_CRAWL_HEIGHT ))) then
                                        r_SM <= GAME_OVER;
                                end if;
										  
							elsif i_jump_button_L = '0' or r_y_dino /= pc_Y_START then
                                --When Jumping:
                                --Dino can collide with cactus from front side, buttom side, back side.
                                --Dino can collide with bats from front, buttom. back, top side.

                                if (((r_x_obstacle>= pc_X_START_COL_AREA and r_x_obstacle <= pc_X_END_COL_AREA) or
                                     (r_x_end_obstacle >= pc_X_START_COL_AREA and r_x_end_obstacle <= pc_X_END_COL_AREA)) and
                                    (( i_y_obstacle >= r_y_dino  and i_y_obstacle  <= r_y_dino + pc_DINO_SIZE) or
                                     (r_y_end_obstacle  >= r_y_dino  and r_y_end_obstacle <= r_y_dino + pc_DINO_SIZE ))) then
                                        r_SM <= GAME_OVER;
                                end if;

                            else
                                --When Running:
                                --Dino can collide with cactus from front side
                                --Dino can collide with bat from front side

                                if ((r_x_obstacle>= pc_X_START_COL_AREA and r_x_obstacle <= pc_X_END_COL_AREA) and
                                    (i_y_obstacle >= pc_Y_START and i_y_obstacle <= pc_Y_START + pc_DINO_SIZE)) then
                                        r_SM <= GAME_OVER;
                                end if;
                            end if;

                        when GAME_OVER =>
                            if i_start = '0' and r_start = '1' then
                                r_SM <= IDLE;
								o_reset_game <= '1';
                            end if;

                        when others =>
                            r_SM <= IDLE;
                        end case;
                    end if;
            end process;

        -----------------------------------------------------------
        --Generating enable signals based on the frame we are in.
        -----------------------------------------------------------
        o_stand_en <= '1' when r_SM = IDLE else '0';
        o_dead_en  <= '1' when r_SM = GAME_OVER else '0';
        o_run_en   <= '1' when r_SM = RUN else '0';
        o_jump_en  <= '1' when i_jump_button_L = '0' and r_SM = RUN else '0';
        o_crawl_en <= '1' when i_crawl_button_L = '0' and r_SM = RUN else '0';

    end RTL;