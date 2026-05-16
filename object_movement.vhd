library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity object_movement is
    generic (
        g_X_INITIAL     :   integer   :=161;                 --initial cordinate of the first object. can not be more than 255
        g_MOVEMENT_SPEED:   integer   :=pc_OBSTACLE_SPEED  --set pc_OBSTACLE_SPEED or pc_CLOUD_SPEED
    );
    port (
        i_clk               :   in      STD_LOGIC;
        i_reset             :   in      STD_LOGIC;
        i_run_en            :   in      STD_LOGIC;
        i_object_width    :   in      integer;
        o_object_DV       :   out     STD_LOGIC;
        o_x_object        :   out     signed(pc_GAME_BITS  downto 0)  --one bit more, bcs its singed
                                                                      --range of x is from -256 to 255. (9 Bits)
    );
end object_movement;

architecture RTL of object_movement is
    signal  r_x_object        :  integer range -256 to g_X_INITIAL         :=g_X_INITIAL;
    signal  r_move_counter      :  integer range 0 to g_MOVEMENT_SPEED      :=0;

    begin
        process(i_clk, i_reset) is
            begin
                if i_reset = '1' then
                    r_x_object <= g_X_INITIAL;
                    r_move_counter <= 0;

                elsif rising_edge(i_clk) then
                    if i_run_en = '1' then

                        if r_move_counter < g_MOVEMENT_SPEED then
                            r_move_counter <= r_move_counter + 1;
                        else
                            r_move_counter <= 0;
                            r_x_object <=  r_x_object -1;
                        end if;

                        if i_object_width = 8 and r_x_object = -8 then      -- when the whole small cactus has moved out from the frame
                            r_x_object <= 161;  --off-screen
							
                        elsif i_object_width = 16 and r_x_object = -16 then -- when the whole big cactus has moved out from the frame
                            r_x_object <= 161;
									 
                        elsif i_object_width = 17 and r_x_object = -17 then -- when the whole 2 small cactuses have moved out from the frame
                            r_x_object <= 161;
									 
                        elsif i_object_width = 32 and r_x_object = -32 then -- when the whole bat has moved out from the frame
                            r_x_object <= 161;
									 
                        elsif r_x_object <= -33 then                          -- when the whole 2 big cactuses have moved out from the frame
                            r_x_object <= 161;
                        end if;
                    end if;
                end if;
            end process;

        o_x_object <= to_signed(r_x_object, o_x_object'length);
         o_object_Dv <= '1' when r_x_object >= 161 else '0';       --when we are in the off-screen the DV is high and type of the object can be determined
                                                                        -- when DV is low, we are in the on-screen and there is no possibility for changing the type of the object
                                                                        --so object remain same from the start to end of the frame.
                                                                        --and it gets updated in the off-screen part.

    end RTL;