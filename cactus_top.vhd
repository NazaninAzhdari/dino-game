library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;


entity cactus_top is
    port (
        i_clk25     :   in      STD_LOGIC;
        i_reset     :   in      STD_LOGIC;
        i_run_en      :   in      STD_LOGIC;
        i_x     :   in      unsigned(pc_GAME_BITS -1 downto 0);
        i_y     :   in      unsigned(pc_GAME_BITS -1 downto 0);
        o_draw_cactus1      :   out     STD_LOGIC
       
    );
end cactus_top;

architecture RTL of cactus_top is
    signal w_lfsr : unsigned(2 downto 0)  :=(others=>'0');
    signal w_x_cactus1 : signed(pc_GAME_BITS  downto 0);
    signal w_cactus_width : integer  :=0;
    signal w_cactus1_DV : STD_LOGIC :='0';
    

    begin
        ----------------------------------
        --LFSR3
        ------------------------------------
        random_num: entity work.LFSR3
        port map(
            i_clk => i_clk25,
            i_reset=> i_reset,
            o_lfsr=> w_lfsr
        );

        -----------------------------------
        --Drawing the cactus 1
        -------------------------------------
        draw_cactus1: entity work.draw_cactus
        port map(
            i_clk => i_clk25,
            i_x_div_4 => i_x,
            i_y_div_4 => i_y,
            i_lfsr => w_lfsr,
            i_x_cactus => w_x_cactus1,
            i_cactus_DV => w_cactus1_DV,
            o_cactus_heght=> open,
            o_cactus_width => w_cactus_width,
            o_draw_cactus=> o_draw_cactus1
        );


        ----------------------------------
        --movement cactus 1
        ----------------------------------
        movement_cactus1: entity work.cactus_move
        generic map(
            g_X_INITIAL=> 165
        )
        port map (
            i_clk=> i_clk25,
            i_reset=> i_reset,
            i_run_en=> i_run_en,
            o_cactus_DV=> w_cactus1_DV,
            o_x_cactus=> w_x_cactus1,
            i_cactus_width => w_cactus_width
        );





    end RTL;