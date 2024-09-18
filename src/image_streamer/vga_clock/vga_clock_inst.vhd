	component vga_clock is
		port (
			clk_clk            : in  std_logic := 'X'; -- clk
			reset_reset_n      : in  std_logic := 'X'; -- reset_n
			vga_clk_clk        : out std_logic;        -- clk
			reset_source_reset : out std_logic         -- reset
		);
	end component vga_clock;

	u0 : component vga_clock
		port map (
			clk_clk            => CONNECTED_TO_clk_clk,            --          clk.clk
			reset_reset_n      => CONNECTED_TO_reset_reset_n,      --        reset.reset_n
			vga_clk_clk        => CONNECTED_TO_vga_clk_clk,        --      vga_clk.clk
			reset_source_reset => CONNECTED_TO_reset_source_reset  -- reset_source.reset
		);

