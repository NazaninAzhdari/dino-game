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
        o_reset_game    :   out     STD_LOGIC

		--i_x_cactus  :  in  signed(pc_GAME_BITS downto 0);
		--i_y_cactus  :  in  integer;
		--i_cactus_width  : in  integer;
		--i_y_dino   :   in   unsigned(pc_GAME_BITS -1 downto 0);
		--i_x_bat        :   in      signed(pc_GAME_BITS +1 downto 0)
    );
end dino_SM;

architecture RTL of dino_SM is
    type state_machine is (IDLE ,RUN, GAME_OVER);
    signal r_SM     :   state_machine   :=IDLE;
    signal r_start  :   STD_LOGIC       :='0';
    signal r_reset  :   STD_LOGIC       :='0';
    
                 
	--signal r_y_dino   :  integer;
	--signal r_x_cactus :  integer;
    --signal r_x_bat :  integer;

    begin
	 
        --r_y_dino <= to_integer(i_y_dino);
        --r_x_cactus <= to_integer(i_x_cactus);
        --r_x_bat <= to_integer(i_x_bat);

        --Registering reset and start switches
        process(i_clk) is
            begin
                if rising_edge(i_clk ) then
                    r_reset <= i_reset;
                    r_start <= i_start;
                end if;
            end process;

	 
        --Dino Game State Machine
        process(i_clk, i_reset, r_reset) is
            begin
                if i_reset = '0' and r_reset = '1' then  --by falling edge of reset switch, the game gets reset
                    r_SM <= IDLE;
                    o_reset_game <= '1';

                elsif rising_edge(i_clk) then 
                    case r_SM is
                        when IDLE =>
                            --DINO GAME text in the top  
							o_reset_game <= '0';		 
                            if i_start = '0' and r_start = '1' then  --by falling edge of start switch, the game does start
                                r_SM <= RUN;
                            end if;

                        when RUN =>
                            

                            --collision with cactus                           end of cactus
                            --if ((r_x_cactus>= 1 and r_x_cactus <= 23) or (r_x_cactus + i_cactus_width >= 7 and r_x_cactus + i_cactus_width <= 32)) then
                            --    if r_y_dino + 26 > i_y_cactus  then
                            --        r_SM <= GAME_OVER;
                            --    end if;
                            --end if;

                            --collision with bat
                            --if ((r_x_bat >= 1 and r_x_bat <= 32) or (r_x_bat + pc_BAT_WIDTH >= 7 and r_x_bat + pc_BAT_WIDTH <= 32)) then
                            --    if r_y_dino + 10 <= 35 then
                            --        r_SM <= GAME_OVER;
                            --    end if;
                            --end if;

                        when GAME_OVER =>
                            --GAME OVER text
                            if i_start = '0' and r_start = '1' then
                                r_SM <= IDLE;
								o_reset_game <= '1';
                            end if;

                        when others =>
                            r_SM <= IDLE;
                        end case;
                    end if;
            end process;
				
				
        

            --check these signals and also draw_dino mdule
            --then dino top
            --then collision


        o_stand_en <= '1' when r_SM = IDLE else '0';
        o_dead_en  <= '1' when r_SM = GAME_OVER else '0';
        o_run_en   <= '1' when r_SM = RUN else '0';
        o_jump_en  <= '1' when i_jump_button_L = '0' and r_SM = RUN else '0';
        o_crawl_en <= '1' when i_crawl_button_L = '0' and r_SM = RUN else '0';

        



    end RTL;