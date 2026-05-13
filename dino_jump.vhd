library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity dino_jump is
    port (
        i_clk       :   in      STD_LOGIC;
        i_reset     :   in      STD_LOGIC; 
        i_jump_en   :   in      STD_LOGIC;
		  i_run_en    :   in      STD_LOGIC;
        o_y_dino    :   out     unsigned(pc_GAME_BITS -1 downto 0)
    );
end dino_jump;

architecture RTL of dino_jump is
    signal r_y_dino          :  integer                     :=pc_Y_START;  --Top point of Dino
    signal r_velocity        :  integer                     :=0;
    signal r_waiting_counter :  integer range 0 to pc_SPEED :=0;

    begin

        ---------------------------------------------------
        --Jumping logic of dino - Keep track of y position
        ---------------------------------------------------
        process(i_clk, i_reset) is
            begin
                if i_reset = '1' then
                    r_y_dino <= pc_Y_START;
                    r_velocity <= 0;

                elsif rising_edge(i_clk) then 
                    if i_jump_en = '1' and r_y_dino = pc_Y_START  then
                        r_velocity <= -7;
                    end if;
						  
							if i_run_en = '1' then
							  if r_waiting_counter < pc_SPEED then
									r_waiting_counter <= r_waiting_counter + 1;
							  else
									r_waiting_counter <= 0;
									r_velocity <= r_velocity + 1;
									r_y_dino <= r_y_dino + r_velocity;

									if r_y_dino > pc_Y_START  then
										 r_velocity <= 0;
										 r_y_dino <= pc_Y_START;
								end if;
                        end if;
                    end if;
                end if;
            end process;

            o_y_dino <= to_unsigned(r_y_dino, o_y_dino'length);
    

    end RTL;