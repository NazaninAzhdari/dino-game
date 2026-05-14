library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity obstacle_top is
    port (
        i_clk               :   in      STD_LOGIC;
        i_reset             :   in      STD_LOGIC;
        i_x                 :   in      unsigned(pc_GAME_BITS - 1 downto 0);
        i_y                 :   in      unsigned(pc_GAME_BITS - 1 downto 0);
        i_wing1_DV          :   in      STD_LOGIC;
        i_wing2_DV          :   in      STD_LOGIC;
        i_run_en            :   in      STD_LOGIC;
        o_draw_obstacle     :   out     STD_LOGIC;
        o_obstacle_height   :   out     integer;
        o_obstacle_width    :   out     integer;
        o_x_obstacle        :   out     signed(pc_GAME_BITS downto 0);  --one bit more, BCS its signed
        o_y_obstacle        :   out     integer
    );
end obstacle_top;

architecture RTL of obstacle_top is
                                       --dont forget to determine the range of integers!!!!!!!!!!!!
    --Drawing signals
    signal r_big_cactus     :   STD_LOGIC   :='0';
    signal r_2_big_cactus   :   STD_LOGIC   :='0';
    signal r_small_cactus   :   STD_LOGIC   :='0';
    signal r_2_small_cactus :   STD_LOGIC   :='0';
    signal r_top_bat        :   STD_LOGIC   :='0';
    signal r_middle_bat     :   STD_LOGIC   :='0';
    signal r_buttom_bat     :   STD_LOGIC   :='0';

    --cordinate of the pixel
    signal r_x        : integer range 0 to pc_GAME_WIDTH  -1  :=0;
    signal r_y        : integer range 0 to pc_GAME_HEIGHT -1  :=0;
    
    --regarding obstacle
    signal r_x_obstacle     :  signed(pc_GAME_BITS downto 0)  :=(others=>'0');
    signal r_obstacle_DV    :  STD_LOGIC                      :='0';
    signal r_obstacle_ID    :  unsigned(2 downto 0)           :=(others=>'0');
    signal r_obstacle_width :  integer range 8 to 33          :=8;
    signal w_lfsr           :  unsigned(2 downto 0)           :=(others=>'0');
     
    begin
        ------------------------------------
        --Generate random numbers with LFSR
        ------------------------------------
        gen_random_3_bit: entity work.LFSR3
        port map(
        i_clk => i_clk,
        i_reset=> i_reset
        o_lfsr=> w_lfsr
        );

        ----------------------------------------------------------
        --Determine the obstacle-ID randomly by LFSR
        --when obstacle_DV is high? when obstacle is in off-screen 
        -----------------------------------------------------------
        process(i_clk) is
        begin
            if rising_edge(i_clk) then
                if r_obstacle_DV = '1' then
                    r_obstacle_ID <= w_lfsr(2 downto 0);
                end if;
            end if;
        end process;

        ------------------------------------------------------------
        --Based on Obstacle-ID draw an Obstacle
        ------------------------------------------------------------
        o_draw_obstacle <=  r_small_cactus when r_obstacle_ID = "000" else
                            r_big_cactus when r_obstacle_ID = "001" else
                            r_2_small_cactus when r_obstacle_ID = "010" else
                            r_2_big_cactus when r_obstacle_ID = "011" else
                            r_top_bat when r_obstacle_ID = "100" else
                            r_middle_bat when r_obstacle_ID = "101" else
                            r_buttom_bat;

        --------------------------------------------------------------
        --Based on Obstacle_ID send out the obstacle's spicification
        --------------------------------------------------------------
        o_obstacle_width <= r_obstacle_width;
        r_obstacle_width <= pc_SMALL_CACTUS_WIDTH when r_obstacle_ID = "000" else
                            pc_BIG_CACTUS_WIDTH when r_obstacle_ID = "001" else
                            pc_2_SMALL_CACTUS_WIDTH when r_obstacle_ID = "010" else
                            pc_2_BIG_CACTUS_WIDTH when r_obstacle_ID = "011" else
                            pc_BAT_WIDTH;


        o_obstacle_height <= pc_SMALL_CACTUS_HEIGHT when r_obstacle_ID = "000" or r_obstacle_ID = "010" else
                            pc_BIG_CACTUS_HEIGHT when r_obstacle_ID = "001" or r_obstacle_ID = "011" else
                            pc_BAT_HEIGHT;

        o_y_obstacle <= pc_Y_SMALL_CACTUS when r_obstacle_ID = "000" or r_obstacle_ID = "010" else --The top-left y cordinate of the obstacle
                        pc_Y_BIG_CACTUS when r_obstacle_ID = "001" or r_obstacle_ID = "011" else
                        pc_Y_TOP_BAT when r_obstacle_ID = "100" else
                        pc_Y_MIDDLE_BAT when r_obstacle_ID = "101" else
                        pc_Y_BUTTOM_BAT; 


        ---------------------------------------
        --Component decleration - Drawing Bats
        ---------------------------------------
        drawing_bats: entity work.draw_bat
        port map (
            i_x=> i_x,
            i_y=> i_y,
            i_x_bat=> r_x_obstacle,
            i_wing1_DV=> i_wing1_DV,
            i_wing2_DV=> i_wing2_DV,
            o_draw_top_bat => r_top_bat,
            o_draw_middle_bat => r_middle_bat,
            o_draw_buttom_bat => r_buttom_bat
        );

        -------------------------------------------
        --Component Decleration - Drawing Cactuses
        -------------------------------------------
        drawing_cactuses: entity work.draw_cactus
        port map(
            i_clk=> i_clk,
            i_x => i_x,
            i_y => i_y,
            i_x_cactus => r_x_obstacle,
            o_draw_small_cactus => r_small_cactus,
            o_draw_sbig_cactus => r_big_cactus,
            o_draw_2_small_cactus=> r_2_small_cactus,
            o_draw_2_big_cactus=> r_2_big_cactus
        );

        -----------------------------------------------------------------
        -- Component Decleration - Determining the Movement of Obstacles
        -----------------------------------------------------------------
        movement_of_obstacles: entity work.obstacle_movement
        generic map(
            g_X_INITIAL=> 200  --off screen
        )
        port map(
            i_clk=> i_clk,
            i_reset=> i_reset,
            i_run_en=> i_run_en,
            i_obstacle_width => r_obstacle_width,
            o_obstacle_DV => r_obstacle_DV,
            o_x_obstacle => r_x_obstacle
        );

        o_x_obstacle <= r_x_obstacle;


    end RTL;

