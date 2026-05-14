library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity dino_SM is
    port (
        i_clk       :   in      STD_LOGIC; --25
        i_reset     :   in      STD_LOGIC;
        i_start     :   in      STD_LOGIC;
        i_button_L  :   in      STD_LOGIC;
        o_stand_dino: out  STD_LOGIC;
        o_runner1_dino: out  STD_LOGIC;
        o_runner2_dino: out  STD_LOGIC;
        o_dead_dino: out  STD_LOGIC;
        o_jump_en: out  STD_LOGIC;
		  i_x_cactus  :  in  signed(pc_GAME_BITS downto 0);
		  i_y_cactus  :  in  integer;
		  i_cactus_width  : in  integer;
		  i_y_dino   :   in   unsigned(pc_GAME_BITS -1 downto 0);
		  o_reset  :   out   STD_LOGIC
    );
end dino_SM;

architecture RTL of dino_SM is
    type state_machine is (IDLE ,RUN, GAME_OVER);
    signal r_SM     :   state_machine   :=IDLE;

    signal r_start  :   STD_LOGIC       :='0';
    signal r_reset  :   STD_LOGIC       :='0';
    signal r_waiting_counter  :  integer range 0 to pc_RUNNING_SPEED :=0;
    signal r_run1_DV : STD_LOGIC   :='1';
    signal r_run2_DV : STD_LOGIC   :='0';
                                    
	signal r_y_dino   :  integer;
	signal r_x_cactus :  integer;
    begin
	 
	 r_y_dino <= to_integer(i_y_dino);
	 r_x_cactus <= to_integer(i_x_cactus);
	 
        process(i_clk, i_reset, r_reset) is
            begin
                if i_reset = '0' and r_reset = '1' then  --by falling edge of reset switch, the game gets reset
                    --reset 
                    r_SM <= IDLE;
                    r_run1_DV <= '1';
                    r_run2_DV <= '0';

                elsif rising_edge(i_clk) then 
                    

                    case r_SM is
                        when IDLE =>
                            --start text in the top
                            --draw dino with nornal head and normal foot
                            --if start button pressed
									 o_reset <= '0';
                            if i_start = '0' and r_start = '1' then  --by falling edge of start switch, the game does start
                                r_SM <= RUN;
                            end if;


                        when RUN =>
                            --normal head, changable foots
                            --if button pressed
                            --r_SM <= jump
                            --if while running collide with something
                            --r_SM <= collide
                            if r_waiting_counter < pc_RUNNING_SPEED then  --0.2 sec
                                r_waiting_counter <= r_waiting_counter + 1;
                            else
                                r_waiting_counter <= 0;

                                if r_run1_DV = '1' then
                                    r_run1_DV <= '0';
                                    r_run2_DV <= '1';
                                else
                                    r_run1_DV <= '1';
                                    r_run2_DV <= '0';
                                end if;
                            end if;

                            --                                          end of cactus
                            if ((r_x_cactus>= 1 and r_x_cactus <= 23) or (r_x_cactus + i_cactus_width >= 4 and r_x_cactus + i_cactus_width <= 32)) then
                                if r_y_dino + 26 > i_y_cactus  then
                                    r_SM <= GAME_OVER;
                                end if;
                            end if;


                        when GAME_OVER =>
                            --game over text

                            if i_start = '0' and r_start = '1' then
                                r_SM <= IDLE;
										  o_reset <= '1';
                            end if;

                        when others =>
                            r_SM <= IDLE;
                        end case;
                    end if;
            end process;
				
				
				process(i_clk) is
					begin
					if rising_edge(i_clk ) then
						r_reset <= i_reset;
                    r_start <= i_start;
					end if;
					
					end process;


        o_stand_dino <= '1' when r_SM = IDLE else '0';
        o_dead_dino <= '1' when r_SM = GAME_OVER else '0';
        o_runner1_dino <= r_run1_DV when r_SM = RUN and i_button_L = '1' else '0';
        o_runner2_dino <= r_run2_DV when r_SM = RUN and i_button_L = '1' else '0';
        o_jump_en <= '1' when i_button_L = '0' and r_SM = RUN else '0';

    end RTL;