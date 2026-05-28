library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.dino_pack.ALL;

entity melody_gen is
    generic (
        g_SAMPLE_WIDTH      :   integer          :=24;
        g_HALF_PERIOD_TONE  :   t_tone_array     :=(24, 34, 48, 96);
        g_TONE_LIMIT        :   integer          :=4;
        g_DURATION_LIMIT    :   integer          :=12000
    );
    port (
        i_clk       :   in      STD_LOGIC;
        i_en        :   in      STD_LOGIC;
        i_LRCLK     :   in      STD_LOGIC;
        o_sample    :   out     unsigned(g_sample_width-1 downto 0);
        o_sample_DV :   out     STD_LOGIC
    );
end melody_gen;

architecture RTL of melody_gen is
    constant AMP_POS            : signed(g_SAMPLE_WIDTH-1 downto 0) := to_signed( 4000000, g_SAMPLE_WIDTH);
    constant AMP_NEG            : signed(g_SAMPLE_WIDTH-1 downto 0) := to_signed(-4000000, g_SAMPLE_WIDTH);

    signal r_LRCLK              : STD_LOGIC                           := '0';
    signal r_freq_counter       : integer                             := 0;
    signal r_level              : STD_LOGIC                           := '0';
    signal r_sample             : signed(g_SAMPLE_WIDTH-1 downto 0)   := (others => '0');
    signal r_duration_counter   : integer range 0 to g_DURATION_LIMIT := 0;
    signal tone_indx            : integer range 0 to g_TONE_LIMIT-1   :=0;
    signal r_en : STD_LOGIC  :='0';
    signal w_en : STD_LOGIC  :='0';

    begin
        process(i_clk) is
            begin
                if rising_edge(i_clk) then
                    r_LRCLK <= i_LRCLK;
                    r_en <= i_en;
                    if i_en = '1' and r_en = '0' then
                        w_en <= '1';
                    end if;

                    if i_LRCLK = '1' and r_LRCLK = '0' then --rising-edge of LRCLK
                        if w_en = '1' then
                            o_sample_DV <= '1';

                            if r_freq_counter < g_HALF_PERIOD_TONE(tone_indx)-1 then
                                r_freq_counter <= r_freq_counter + 1;
                            else
                                r_freq_counter <= 0;
                                r_level <= not r_level;
                            end if;


                            if r_duration_counter < g_DURATION_LIMIT then
                                r_duration_counter <= r_duration_counter + 1;
                            else
                                r_duration_counter <= 0;
                                
                                if tone_indx = g_TONE_LIMIT-1 then
                                    w_en <= '0';
                                    o_sample_DV <= '0';
                                else
                                    tone_indx <= tone_indx + 1;
                                end if;
                            end if;


                            if r_level = '1' then
                                r_sample <= AMP_POS;
                            else
                                r_sample <= AMP_NEG;
                            end if;
                        else
                            r_sample <= (others=>'0');
                            r_freq_counter <= 0;
                            r_duration_counter <= 0;
                            tone_indx <= 0;
                            r_level <='0';
                            o_sample_DV <= '0';
                        end if;
                    end if;
                end if;

            end process;

            o_sample <= unsigned(STD_LOGIC_VECTOR(r_sample));
    end RTL;
