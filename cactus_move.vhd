library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;


entity cactus_move is
    generic (
        g_X_INITIAL     :   integer   :=161
    );
    port (
        i_clk       :   in      STD_LOGIC;
        i_reset     :   in      STD_LOGIC;
        i_run_en    :   in      STD_LOGIC;
        o_cactus_DV :   out     STD_LOGIC;
        o_x_cactus  :   out     signed(pc_GAME_BITS  downto 0); --one bit more, bcs its singed
        i_cactus_width : in     integer

    );
end cactus_move;

architecture RTL of cactus_move is
    signal  r_x_cactus      :  integer range -16 to g_X_INITIAL  :=g_X_INITIAL;
    signal  r_move_counter          :  integer range 0 to pc_CACTUS_SPEED       :=0;
    --signal  r_speed_counter         :  integer range 0 to pc_SPEED       :=0;
    --signal  changable_speed         : integer                            :=pc_SPEED;

    begin
        process(i_clk, i_reset) is
            begin
                if i_reset = '1' then
                    r_x_cactus <= g_X_INITIAL;
                    --changable_speed <= pc_SPEED;
                    r_move_counter <= 0;
                    --r_speed_counter <= 0;

                elsif rising_edge(i_clk) then
                    if i_run_en = '1' then

                        if r_move_counter < pc_CACTUS_SPEED then
                            r_move_counter <= r_move_counter + 1;
                        else
                            r_move_counter <= 0;

                            r_x_cactus <=  r_x_cactus -1;

                            if i_cactus_width = 16 and r_x_cactus = -16 then
                                r_x_cactus <= 161;  --off screen
                            elsif i_cactus_width = 32 and r_x_cactus = -32 then
                                r_x_cactus <= 161;
                            end if;
                        end if;

                    end if;
                end if;
            end process;

        o_x_cactus <= to_signed(r_x_cactus, o_x_cactus'length);
        o_cactus_DV <= '1' when r_x_cactus = 161 else '0';
        



    end RTL;