	component scaling is
		port (
			sauce_ready         : in  std_logic                     := 'X';             -- ready
			sauce_startofpacket : out std_logic;                                        -- startofpacket
			sauce_endofpacket   : out std_logic;                                        -- endofpacket
			sauce_valid         : out std_logic;                                        -- valid
			sauce_data          : out std_logic_vector(11 downto 0);                    -- data
			sauce_channel       : out std_logic_vector(1 downto 0);                     -- channel
			sink_startofpacket  : in  std_logic                     := 'X';             -- startofpacket
			sink_endofpacket    : in  std_logic                     := 'X';             -- endofpacket
			sink_valid          : in  std_logic                     := 'X';             -- valid
			sink_ready          : out std_logic;                                        -- ready
			sink_data           : in  std_logic_vector(11 downto 0) := (others => 'X'); -- data
			reset_reset         : in  std_logic                     := 'X';             -- reset
			clk_clk             : in  std_logic                     := 'X'              -- clk
		);
	end component scaling;

	u0 : component scaling
		port map (
			sauce_ready         => CONNECTED_TO_sauce_ready,         -- sauce.ready
			sauce_startofpacket => CONNECTED_TO_sauce_startofpacket, --      .startofpacket
			sauce_endofpacket   => CONNECTED_TO_sauce_endofpacket,   --      .endofpacket
			sauce_valid         => CONNECTED_TO_sauce_valid,         --      .valid
			sauce_data          => CONNECTED_TO_sauce_data,          --      .data
			sauce_channel       => CONNECTED_TO_sauce_channel,       --      .channel
			sink_startofpacket  => CONNECTED_TO_sink_startofpacket,  --  sink.startofpacket
			sink_endofpacket    => CONNECTED_TO_sink_endofpacket,    --      .endofpacket
			sink_valid          => CONNECTED_TO_sink_valid,          --      .valid
			sink_ready          => CONNECTED_TO_sink_ready,          --      .ready
			sink_data           => CONNECTED_TO_sink_data,           --      .data
			reset_reset         => CONNECTED_TO_reset_reset,         -- reset.reset
			clk_clk             => CONNECTED_TO_clk_clk              --   clk.clk
		);

