library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dino_SM is
    port (

    );
end dino_SM;

architecture RTL of dino_SM is
    type state_machine is (IDLE, START_GAME, RUN, COLLIDE, GAME_OVER);
    signal r_SM     :   state_machine   :=IDLE;

    begin
        process(i_clk, i_reset) is
            begin
                if i_reset = '0' and r_reset = '1' then
                    --reset 

                elsif rising_edge(i_clk) then 
                    case r_SM is
                        when IDLE =>
                            --draw dino with nornal head and normal foot
                            

                            --if start button pressed
                            --r_SM <= START_GAME

                        when START_GAME =>
                            --normal head, normal foot

                            --wait for some second and then goes to jumps
                            r_SM <= JUMP;
                        
                        when jump =>
                            --norml head, normal foot

                            --when jumps end
                            --r_SM <= run

                            --if while jumpting collide with something
                            --r_SM <= collide

                        when RUN =>
                            --normal head, changable foots

                            --if button pressed
                            --r_SM <= jump

                            --if while running collide with something
                            --r_SM <= collide
                            
                            if r_waiting_counter < pc_WAITING_LIMIT then
                                r_waiting_counter + 1;
                            else
                                r_waiting_counter <= 0;

                                if r_run1_DV = '1' and r_run2_DV = '0' then
                                    r_run1_DV <= '0';
                                    r_run2_DV <= '1';
                                elsif r_run1_DV = '0' and r_run2_DV = '1' then
                                    r_run1_DV <= '1';
                                    r_run2_DV <= '0';
                                end if;
                            end if;

                            if i_swith = '1' then
                                r_SM <= JUMP;
                            end if;
                        
                        when collide =>
                            --normal foot, death head
                            
                            --if start button pressed
                            --r_SM <= STAR GAME

                        when GAME_OVER =>


            end process;

    end RTL;