library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity bat_move is
    generic (
        g_X_INITIAL     :   integer     :=500
    );
    port (
        i_clk   :   in      STD_LOGIC;  --25
        i_reset :   in      STD_LOGIC;
        i_run_en:   in      STD_LOGIC;
        o_x_bat :   out     signed(pc_GAME_BITS+1 downto 0)
    );
end bat_move;

architecture RTL of bat_move is
    signal  r_bat_counter   :   integer range 0 to pc_BAT_SPEED :=0;
    signal  r_x_bat         :   integer range (- pc_BAT_WIDTH) to 500  :=g_X_INITIAL;
    begin
        process(i_clk, i_reset) is
            begin
                if i_reset = '1' then
                    r_bat_counter <= 0;
                    r_x_bat <= g_X_INITIAL;

                elsif rising_edge(i_clk) then
                    if i_run_en = '1' then

                        if r_bat_counter < pc_BAT_SPEED then
                            r_bat_counter <= r_bat_counter + 1;
                        else
                            r_bat_counter <= 0;
                            r_x_bat <= r_x_bat -1;
                        end if;

                        if r_x_bat <= (- pc_BAT_WIDTH) then
                            r_x_bat <= 500;
                        end if;

                    end if;
                end if;
            end process;

            o_x_bat <= to_signed(r_x_bat, o_x_bat'length);


    end RTL;