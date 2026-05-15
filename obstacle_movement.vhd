library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity obstacle_movement is
    generic (
        g_X_INITIAL     :   integer   :=161   --initial cordinate of the first obstacle. Put it to be off-screen
    );
    port (
        i_clk               :   in      STD_LOGIC;
        i_reset             :   in      STD_LOGIC;
        i_run_en            :   in      STD_LOGIC;
        i_obstacle_width    :   in      integer;
        o_obstacle_DV       :   out     STD_LOGIC;
        o_x_obstacle        :   out     signed(pc_GAME_BITS  downto 0)  --one bit more, bcs its singed
    );
end obstacle_movement;

architecture RTL of obstacle_movement is
    signal  r_x_obstacle        :  integer range -34 to g_X_INITIAL         :=g_X_INITIAL;
    signal  r_move_counter      :  integer range 0 to pc_OBSTACLE_SPEED     :=0;

    begin
        process(i_clk, i_reset) is
            begin
                if i_reset = '1' then
                    r_x_obstacle <= g_X_INITIAL;
                    r_move_counter <= 0;

                elsif rising_edge(i_clk) then
                    if i_run_en = '1' then

                        if r_move_counter < pc_OBSTACLE_SPEED then
                            r_move_counter <= r_move_counter + 1;
                        else
                            r_move_counter <= 0;
                            r_x_obstacle <=  r_x_obstacle -1;
                        end if;

                        if i_obstacle_width = 8 and r_x_obstacle = -8 then      -- when the whole small cactus has moved out from the frame
                            r_x_obstacle <= 161;  --off-screen
							
                        elsif i_obstacle_width = 16 and r_x_obstacle = -16 then -- when the whole big cactus has moved out from the frame
                            r_x_obstacle <= 161;
									 
                        elsif i_obstacle_width = 17 and r_x_obstacle = -17 then -- when the whole 2 small cactuses have moved out from the frame
                            r_x_obstacle <= 161;
									 
                        elsif i_obstacle_width = 32 and r_x_obstacle = -32 then -- when the whole bat has moved out from the frame
                            r_x_obstacle <= 161;
									 
                        elsif r_x_obstacle <= -33 then                          -- when the whole 2 big cactuses have moved out from the frame
                            r_x_obstacle <= 161;
                        end if;
                    end if;
                end if;
            end process;

        o_x_obstacle <= to_signed(r_x_obstacle, o_x_obstacle'length);
         o_obstacle_Dv <= '1' when r_x_obstacle >= 161 else '0';       --when we are in the off-screen the DV is high and type of the obstacle can be determined
                                                                        -- when DV is low, we are in the on-screen and there is no possibility for changing the type of the obstacle
                                                                        --so obstacle remain same from the start to end of the frame.
                                                                        --and it gets updated in the off-screen part.

    end RTL;