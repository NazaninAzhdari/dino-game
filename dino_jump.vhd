library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dino_jump is
    port (
        i_clk   :   in      STD_LOGIC;
        i_reset :   in      STD_LOGIC; 
        o_y_dino:   out     unsigned()
    );
end dino_jump;

architecture RTL of dino_jump is
    signal r_y_dino          :  integer                     :=pc_Y_START;  --Top point of Dino
    signal r_velocity        :  integer                     :=-1;
    signal r_waiting_counter :  integer range 0 to pc_SPEED :=0;

    begin

        ---------------------------------------------------
        --Jumping logic of dino - Keep track of y position
        ---------------------------------------------------
        process(i_clk, i_reset) then
            begin
                if i_reset = '1' then
                    r_y_dino <= pc_Y_START;
                    r_velocity <= -1;

                elsif rising_edge(i_clk) then 
                    if i_jump_en = '1' and r_y_dino = pc_Y_START  then
                        r_velocity <= -10;
                    end if;

                    if r_waiting_counter < pc_SPEED then
                        r_waiting_counter <= r_waiting_counter + 1;
                    else
                        r_y_dino <= pf_y_dino(r_velocity, r_y_dino);
                        if r_y_dino = pc_Y_START  then
                            r_velocity <= -1;
                        end if;
                    end if;
                end if;
            end process;

            o_y_dino <= r_y_dino;
    

    end RTL;