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
        o_hdmi_data_bus     :   out     unsigned(23 downto 0);

        --audio interface
        o_MCLK          :   out     STD_LOGIC;
        o_LRCLK         :   out     STD_LOGIC;
        o_BCLK          :   out     STD_LOGIC;
        o_DATA          :   out     STD_LOGIC;

        --7 segment interface
        o_7seg1             :   out     unsigned(6 downto 0);
        o_7seg2             :   out     unsigned(6 downto 0);
        o_7seg3             :   out     unsigned(6 downto 0);
        o_7seg4             :   out     unsigned(6 downto 0)
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

    signal w_DE             :   STD_LOGIC    :='0';
    signal w_draw_dino      :   STD_LOGIC    :='0';
    signal w_draw_obstacle  :   STD_LOGIC    :='0';
    signal w_draw_cloud     :   STD_LOGIC    :='0';
    signal w_draw_start     :   STD_LOGIC    :='0';
    signal w_draw_gameOver  :   STD_LOGIC    :='0';

    signal w_y_dino         :   unsigned(pc_GAME_BITS -1 downto 0) :=(others=>'0');
	signal w_x_obstacle     :   signed(pc_GAME_BITS downto 0)      :=(others=>'0');
	signal w_y_obstacle     :   integer;
	signal w_obstacle_width :   integer;
    signal w_obstacle_height:   integer;

    signal w_score_binary : unsigned(15 downto 0)  :=(others=>'0');
    signal r_score_binary : unsigned(15 downto 0)  :=(others=>'0');

    signal r_7seg1, r_7seg2, r_7seg3, r_7seg4     :  unsigned(6 downto 0) :=(others=>'0');
    signal r_double_dabble_en   :   STD_LOGIC           :='0';
    signal w_7seg_en            :  STD_LOGIC            :='0';
    signal w_score_BCD          :  unsigned(15 downto 0) :=(others=>'0');

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
        --Audio Interface
        -----------------------------------------
        generating_sound: entity work.audio_top
        port map(
            i_clk50 => i_clk,
            i_reset => r_reset,
            i_jump_sound_En => w_jump_en,
            i_crawl_sound_En => w_crawl_en,
            i_dead_sound_En => w_dead_en,
            i_start_sound_En => w_run_en,
            o_MCLK => o_MCLK,
            o_LRCLK => o_LRCLK,
            o_BCLK => o_BCLK,
            o_DATA => o_DATA
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

        ------------------------------------------------
        --Clouds: movement and drawing
        ------------------------------------------------
        clouds: entity work.cloud_top
        port map(
            i_clk=> i_clk,
            i_reset=> w_reset_game,
            i_run_en=> w_run_en,
            i_x=> r_x,
            i_y=> r_y,
            o_draw_cloud=> w_draw_cloud
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
            o_y_obstacle=> w_y_obstacle,
            o_score => w_score_binary
        );

        -------------------------------------------------------------------------------
        --Generating enable signal for double-dabble
        --enable goes high if the score has changed, meaning that we have a new score.
        -------------------------------------------------------------------------------
        process(r_clk25) is
            begin
                if rising_edge(r_clk25) then
                    r_score_binary <= w_score_binary;
                    if w_score_binary /= r_score_binary then
                        r_double_dabble_en <= '1';
                    else
                        r_double_dabble_en <= '0';
                    end if;
                end if;
            end process;

        -------------------------------------------------------------------
        --Convert the Binary Score to BCD using double dabble algorithem
        -------------------------------------------------------------------
        convert_binary_to_BCD: entity work.double_dabble
        generic map(
            g_BINARY_BIT_LIMIT=> 16,    --Maximum bit to represent 9999
            g_DECIMAL_DIGIT_LIMIT=> 4  --Maximum digit to represent 9999
        )
        port map(
            i_clk=> r_clk25,
            i_en=> r_double_dabble_en,
            i_binary=> r_score_binary,
            o_BCD_DV=> w_7seg_en,
            o_BCD=> w_score_BCD
        );

        --------------------------------
        --Seven Segments
        --------------------------------
        seven_segment_1: entity work.SevenSeg_display
        port map(
            i_clk=> r_clk25,
            i_BCD => w_score_BCD(3 downto 0),
            i_en=> w_7seg_en,
            o_7seg => r_7seg1
        );

        seven_segment_2: entity work.SevenSeg_display
        port map(
            i_clk=> r_clk25,
            i_BCD => w_score_BCD(7 downto 4),
            i_en=> w_7seg_en,
            o_7seg => r_7seg2 
        );

        seven_segment_3: entity work.SevenSeg_display
        port map(
            i_clk=> r_clk25,
            i_BCD => w_score_BCD(11 downto 8),
            i_en=> w_7seg_en,
            o_7seg => r_7seg3
        );

        seven_segment_4: entity work.SevenSeg_display
        port map(
            i_clk=> r_clk25,
            i_BCD => w_score_BCD(15 downto 12),
            i_en=> w_7seg_en,
            o_7seg => r_7seg4 
        );

        o_7seg1 <= not r_7seg1;
        o_7seg2 <= not r_7seg2;
        o_7seg3 <= not r_7seg3;
        o_7seg4 <= not r_7seg4;

        ----------------------------------------------
        --Drawing "Dino Game" text in the start frame
        ----------------------------------------------
        draw_start_frame: entity work.draw_start
        port map(
            i_x => r_x,
            i_y => r_y,
            o_draw_start => w_draw_start
        );

        ----------------------------------------------
        --Drawing "Game Over" text in the end frame
        ----------------------------------------------
        draw_game_over_frame: entity work.draw_gameOver
        port map(
            i_x => r_x,
            i_y => r_y,
            o_draw_gameOver_txt => w_draw_gameOver
        );

        ---------------------------------------------
        --Painting the game + HDMI ports connection
        ---------------------------------------------
        o_hdmi_clk <= r_clk25;
        o_hdmi_de <= w_de;
        o_hdmi_data_bus <= pc_DINO_COLOR_CODE when (w_draw_dino = '1' and w_de = '1')  or (w_draw_start = '1' and w_stand_en = '1' ) or ( w_draw_gameOver = '1' and w_dead_en = '1')else
                        pc_OBSTACLE_COLOR_CODE when ((w_draw_obstacle = '1' or  w_y = 415) and w_de = '1' ) else
                        pc_CLOUD_COLOR_CODE when (w_draw_cloud = '1' and w_de = '1') else  
                        pc_BACK_COLOR_CODE when w_de = '1' else
                        (others=>'0');

    end RTL;