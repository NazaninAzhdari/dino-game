library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dino_top is
    port (
        i_clk       :   in      STD_LOGIC;
        i_reset     :   in      STD_LOGIC;
        i_start     :   in      STD_LOGIC;
        i_button_L    :   in      STD_LOGIC;

        --hdmi_interface
        o_hdmi_clk  :   out     STD_LOGIC;
        o_hdmi_HS   :   out     STD_LOGIC;
        o_hdmi_VS   :   out     STD_LOGIC;
        o_hdmi_DE   :   out     STD_LOGIC;
        o_hdmi_data_bus: out    unsigned(23 downto 0)
    );
end dino_top;

architecture RTL of dino_top is
    signal r_clk25  :   STD_LOGIC   :='0';
    signal r_reset  :   STD_LOGIC   :='0';
    signal r_start  :   STD_LOGIC   :='0';

    signal w_stand_en :   STD_LOGIC   :='0';
    signal w_run1_en  :   STD_LOGIC   :='0';
    signal w_run2_en  :   STD_LOGIC   :='0';
    signal w_dead_en  :   STD_LOGIC   :='0';
    signal w_jump_en  :   STD_LOGIC   :='0';

    signal w_x         :   unsigned(pc_VGA_BITS -1 downto 0)   :=(others=>'0');
    signal w_y         :   unsigned(pc_VGA_BITS -1 downto 0)   :=(others=>'0');
    signal r_DE        :   STD_LOGIC    :='0';

    signal r_x         :   unsigned(pc_GAME_BITS -1 downto 0)   :=(others=>'0');  --divided by 4
    signal r_y         :   unsigned(pc_GAME_BITS -1 downto 0)   :=(others=>'0');  --divided by 4
    signal w_y_dino         :   unsigned(pc_GAME_BITS -1 downto 0)   :=(others=>'0');

    signal r_draw_dino        :   STD_LOGIC    :='0';

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
    port (
        i_clk25=> r_clk25,
        i_reset=> r_reset,
        o_x =>w_x,
        o_y=> w_y,
        o_HS=> o_HS,
        o_VS=> o_VS,
        o_DE=> r_DE
    );

    r_x <= w_x(w_x'left downto 2);
    r_y <= w_y(w_y'left downto 2);

    ------------------------------------------
    --Dino State Machine 
    ------------------------------------------
    dino_control: entity work.dino_SM
    port (
        i_clk=> r_clk25,      --25MHz 
        i_reset=> r_reset,
        i_start=> r_start,
        i_button_L=> i_button_L,
        o_stand_dino=> w_stand_en,
        o_runner1_dino=> w_run1_en,
        o_runner2_dino=> w_run2_en,
        o_dead_dino=> w_dead_en,
        o_jump_en=> w_jump_en
    );

    -----------------------------------------
    --Dino jump function
    -----------------------------------------
    jumping_logic : entity work.dino_jump
    port map(
        i_clk=> r_clk25,  --25MHz
        i_reset => r_reset,
        i_jump_en => w_jump_en,
        o_y_dino=> w_y_dino
    );


    ---------------------------------------
    --draw_dino
    ---------------------------------------
    draw_dino: entity work.draw_dino
    port map(
        i_x=> r_x,
        i_y=> r_y,
        i_y_dino => w_y_dino,
        i_stand_en=> w_stand_en,
        i_run1_en => w_run1_en,
        i_run2_en=> w_run2_en
        i_dead_en=> w_run3_en
        o_draw_dino => r_draw_dino
    );

    o_hdmi_clk <= r_clk25;
    o_hdmi_de <= r_de;
    o_data_bus <= (others=>'1') when r_draw_dino = '1' and r_de = '1' else '0';

    end RTL;