	component scaler is
		port (
			clk_clk               : in  std_logic                    := 'X';             -- clk
			filter_num_filter_num : in  std_logic_vector(1 downto 0) := (others => 'X'); -- filter_num
			freq_flag_freq_flag   : in  std_logic_vector(1 downto 0) := (others => 'X'); -- freq_flag
			reset_reset_n         : in  std_logic                    := 'X';             -- reset_n
			vga_CLK               : out std_logic;                                       -- CLK
			vga_HS                : out std_logic;                                       -- HS
			vga_VS                : out std_logic;                                       -- VS
			vga_BLANK             : out std_logic;                                       -- BLANK
			vga_SYNC              : out std_logic;                                       -- SYNC
			vga_R                 : out std_logic_vector(7 downto 0);                    -- R
			vga_G                 : out std_logic_vector(7 downto 0);                    -- G
			vga_B                 : out std_logic_vector(7 downto 0)                     -- B
		);
	end component scaler;

	u0 : component scaler
		port map (
			clk_clk               => CONNECTED_TO_clk_clk,               --        clk.clk
			filter_num_filter_num => CONNECTED_TO_filter_num_filter_num, -- filter_num.filter_num
			freq_flag_freq_flag   => CONNECTED_TO_freq_flag_freq_flag,   --  freq_flag.freq_flag
			reset_reset_n         => CONNECTED_TO_reset_reset_n,         --      reset.reset_n
			vga_CLK               => CONNECTED_TO_vga_CLK,               --        vga.CLK
			vga_HS                => CONNECTED_TO_vga_HS,                --           .HS
			vga_VS                => CONNECTED_TO_vga_VS,                --           .VS
			vga_BLANK             => CONNECTED_TO_vga_BLANK,             --           .BLANK
			vga_SYNC              => CONNECTED_TO_vga_SYNC,              --           .SYNC
			vga_R                 => CONNECTED_TO_vga_R,                 --           .R
			vga_G                 => CONNECTED_TO_vga_G,                 --           .G
			vga_B                 => CONNECTED_TO_vga_B                  --           .B
		);

