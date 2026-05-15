library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity dino_top is
    port (
        i_clk               :   in      STD_LOGIC;  --50MHz
        i_reset             :   in      STD_LOGIC;
        i_start             :   in      STD_LOGIC;
        i_jump_button_L     :   in      STD_LOGIC;
        i_crawl_button_L    :   in      STD_LOGIC;

        --hdmi interface
        o_hdmi_clk          :   out     STD_LOGIC;
        o_hdmi_HS           :   out     STD_LOGIC;
        o_hdmi_VS           :   out     STD_LOGIC;
        o_hdmi_DE           :   out     STD_LOGIC;
        o_hdmi_data_bus     :   out     unsigned(23 downto 0)
    );
end dino_top;

architecture RTL of dino_top is
    signal r_clk25      :   STD_LOGIC   :='0';
    signal r_reset      :   STD_LOGIC   :='0';
    signal r_start      :   STD_LOGIC   :='0';
	signal w_reset_game :   STD_LOGIC   :='0';

    signal w_stand_en   :   STD_LOGIC   :='0';
    signal w_run_en     :   STD_LOGIC   :='0';
    signal w_dead_en    :   STD_LOGIC   :='0';
    signal w_jump_en    :   STD_LOGIC   :='0';
	signal w_crawl_en   :   STD_LOGIC   :='0';

    signal w_x          :   unsigned(pc_VGA_BITS -1 downto 0)    :=(others=>'0');
    signal w_y          :   unsigned(pc_VGA_BITS -1 downto 0)    :=(others=>'0');
    signal r_x          :   unsigned(pc_GAME_BITS -1 downto 0)   :=(others=>'0');  --divided by 4
    signal r_y          :   unsigned(pc_GAME_BITS -1 downto 0)   :=(others=>'0');  --divided by 4

    signal w_DE           :   STD_LOGIC    :='0';
    signal w_draw_dino    :   STD_LOGIC    :='0';
    signal w_draw_obstacle:   STD_LOGIC    :='0';
    signal w_y_dino       :   unsigned(pc_GAME_BITS -1 downto 0) :=(others=>'0');
	 
	signal w_x_obstacle  :  signed(pc_GAME_BITS downto 0)  :=(others=>'0');
	signal	  w_y_obstacle  :   integer;
	signal	  w_obstacle_width  :   integer;
    signal	  w_obstacle_height  :   integer;


    begin
        ---------------------------------------
        --Dividing the Frequency of the Clock
        ---------------------------------------
        dividing_frequency : entity work.freq_divider
        generic map(
            g_CLK_CYCLES_FOR_HALF_PERIOD=> 1
        )
        port map(
            i_clk=> i_clk,    --50MHz
            o_clk=> r_clk25   --25MHz
        );


        ---------------------------------------------
        --Debouncing the Buttons
        ---------------------------------------------
        debouncing_reset: entity work.debounce_filter
        generic map(
            g_DEBOUNCE_LIMIT=> pc_DEBOUNCE_LIMIT
        )
        port map(
            i_clk=> i_clk,   --50MHz
            i_bouncy=> i_reset,
            o_debounced=> r_reset
        );

        debouncing_start: entity work.debounce_filter
        generic map(
            g_DEBOUNCE_LIMIT=> pc_DEBOUNCE_LIMIT
        )
        port map(
            i_clk=> i_clk,   --50MHz
            i_bouncy=> i_start,
            o_debounced=> r_start
        );

        -----------------------------------------
        --VGA synchronizzing
        -----------------------------------------
        synchronizing_VGA : entity work.HVsync
        port map(
            i_clk25=> r_clk25,
            i_reset=> r_reset,
            o_x =>w_x,
            o_y=> w_y,
            o_HS=> o_hdmi_HS,
            o_VS=> o_hdmi_VS,
            o_DE=> w_DE
        );

        r_x <= w_x(w_x'left downto 2);
        r_y <= w_y(w_y'left downto 2);

        ------------------------------------------
        --Dino State Machine 
        ------------------------------------------
        dino_control: entity work.dino_SM
        port map(
            i_clk=> r_clk25,      --25MHz 
            i_reset=> r_reset,
            i_start=> r_start,
            i_jump_button_L=> i_jump_button_L,
            i_crawl_button_L=> i_crawl_button_L,
            o_stand_en=> w_stand_en,
            o_dead_en=> w_dead_en,
            o_run_en=> w_run_en,
            o_jump_en=> w_jump_en,
            o_crawl_en=> w_crawl_en,
            o_reset_game => w_reset_game,

            i_x_obstacle => w_x_obstacle,
            i_y_obstacle => w_y_obstacle,
            i_obstacle_width => w_obstacle_width,
            i_obstacle_height => w_obstacle_height,
            i_y_dino => w_y_dino
        );


        -----------------------------------------
        --Dino jump function
        -----------------------------------------
        jumping_logic : entity work.dino_jump
        port map(
            i_clk=> r_clk25,  --25MHz
            i_reset => w_reset_game,
            i_jump_en => w_jump_en,
            i_run_en => w_run_en,
            o_y_dino=> w_y_dino
        );

        ---------------------------------------
        --draw_dino
        ---------------------------------------
        draw_dino: entity work.draw_dino
        port map(
            i_clk => r_clk25,
            i_reset => w_reset_game,
            i_x=> r_x,
            i_y=> r_y,
            i_y_dino => w_y_dino,
            i_stand_en=> w_stand_en,
            i_run_en => w_run_en,
            i_dead_en=> w_dead_en,
            i_jump_en => w_jump_en,
            i_crawl_en => w_crawl_en,
            o_draw_dino => w_draw_dino
        );


        ----------------------------------------------
        --Obstacle management - Drawing and Movement
        ----------------------------------------------
        mange_obstacle_drawing_and_movement: entity work.obstacle_top
        port map(
            i_clk=> r_clk25,
            i_reset=> w_reset_game,
            i_run_en=> w_run_en,
            i_x=> r_x,
            i_y=> r_y,
            o_draw_obstacle=> w_draw_obstacle,
            o_obstacle_height=> w_obstacle_height,
            o_obstacle_width=> w_obstacle_width,
            o_x_obstacle=> w_x_obstacle,
            o_y_obstacle=> w_y_obstacle
        );


        ---------------------------------------------
        --Painting the game + HDMI ports connection
        ---------------------------------------------
        o_hdmi_clk <= r_clk25;
        o_hdmi_de <= w_de;
        o_hdmi_data_bus <= pc_GRAY_COLOR_CODE when ((w_draw_dino = '1' or w_draw_obstacle = '1' or w_y = 415 ) and w_de = '1') else
        (others=>'1') when w_de = '1' else
        (others=>'0');


    end RTL;