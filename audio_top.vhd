library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity audio_top is
    port (
        --inputs
        i_clk50             :   in      STD_LOGIC;
        i_reset             :   in      STD_LOGIC;
        i_jump_sound_En     :   in      STD_LOGIC;
        i_crawl_sound_En    :   in      STD_LOGIC;
        i_dead_sound_En     :   in      STD_LOGIC;
        i_start_sound_En    :   in      STD_LOGIC;
        --outputs
        o_MCLK          :   out     STD_LOGIC;
        o_LRCLK         :   out     STD_LOGIC;
        o_BCLK          :   out     STD_LOGIC;
        o_DATA          :   out     STD_LOGIC
    );
end audio_top;

architecture RTL of audio_top is
    signal w_LRCLK          : STD_LOGIC  :='0';

    --Sample Signals
	signal r_sample             : unsigned(23 downto 0)  :=(others=>'0');
    signal w_start_sample        : unsigned(23 downto 0)  :=(others=>'0');
	signal w_jump_sample       : unsigned(23 downto 0)  :=(others=>'0');
    signal w_crawl_sample    : unsigned(23 downto 0)  :=(others=>'0');
	signal w_dead_sample    : unsigned(23 downto 0)  :=(others=>'0');
	
    signal w_start_DV : STD_LOGIC :='0';
    signal w_jump_DV : STD_LOGIC :='0';
    signal w_crawl_DV : STD_LOGIC :='0';
    signal w_dead_DV : STD_LOGIC :='0';
	
    begin 
        jump_melody_generator: entity work.melody_gen
        generic map(
            g_SAMPLE_WIDTH => 24,
            g_HALF_PERIOD_TONE => (40, 34, 30, 27),
            g_TONE_LIMIT => 4,
            g_DURATION_LIMIT => 960 --3840 --80ms
        )
        port map(
            i_clk => i_clk50,
            i_en => i_jump_sound_en,
            i_LRCLK => w_LRCLK,
            o_sample => w_jump_sample,
            o_sample_DV => w_jump_DV
        );

        crawl_melody_generator: entity work.melody_gen
        generic map(
            g_SAMPLE_WIDTH => 24,
            g_HALF_PERIOD_TONE => (27, 30, 34, 40, 48),
            g_TONE_LIMIT => 5,
            g_DURATION_LIMIT => 960 --3840 --80ms
        )
        port map(
            i_clk => i_clk50,
            i_en => i_crawl_sound_en,
            i_LRCLK => w_LRCLK,
            o_sample => w_crawl_sample,
            o_sample_DV => w_crawl_DV
        );

        start_melody_generator: entity work.melody_gen
        generic map(
            g_SAMPLE_WIDTH => 24,
            g_HALF_PERIOD_TONE => (27, 27),
            g_TONE_LIMIT => 1,
            g_DURATION_LIMIT => 3000 --6000 --250ms
        )
        port map(
            i_clk => i_clk50,
            i_en => i_start_sound_en,
            i_LRCLK => w_LRCLK,
            o_sample => w_start_sample,
            o_sample_DV => w_start_DV
        );

        collision_melody_generator: entity work.melody_gen
        generic map(
            g_SAMPLE_WIDTH => 24,
            g_HALF_PERIOD_TONE => (120, 80, 60, 48, 40, 34, 30, 27, 24, 22, 20),
            g_TONE_LIMIT => 11,
            g_DURATION_LIMIT => 7200 --150ms
        )
        port map(
            i_clk => i_clk50,
            i_en => i_dead_sound_en,
            i_LRCLK => w_LRCLK,
            o_sample => w_dead_sample,
            o_sample_DV => w_dead_DV
        );

		  
        i2s_transmitter: entity work.i2s_tx
        generic map(
            g_SAMPLE_WIDTH => 24,
            g_HALF_PERIOD_MCLK => 2,  --12.5MHz 
            g_HALF_PERIOD_BCLK => 8   --3.1MHz
        )
        port map(
            i_clk => i_clk50,
            i_reset => i_reset,
            i_sample => r_sample,
            o_BCLK => o_BCLK,
            o_LRCLK => w_LRCLK,
            o_MCLK => o_MCLK,
            o_DATA => o_DATA
        );

        r_sample <= w_start_sample when w_start_DV = '1' else
                    w_jump_sample when w_jump_DV = '1' else
                    w_crawl_sample when w_crawl_DV = '1' else
                    w_dead_sample when w_dead_DV = '1' else
					(others=>'0');

        o_LRCLK <= w_LRCLK;

    end RTL;