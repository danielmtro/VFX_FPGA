	component camera_to_vga is
		port (
			reset_reset_n               : in  std_logic                     := 'X';             -- reset_n
			clk_clk                     : in  std_logic                     := 'X';             -- clk
			rdaddress_writebyteenable_n : out std_logic_vector(16 downto 0);                    -- writebyteenable_n
			data_in_beginbursttransfer  : in  std_logic_vector(11 downto 0) := (others => 'X'); -- beginbursttransfer
			vga_CLK                     : out std_logic;                                        -- CLK
			vga_HS                      : out std_logic;                                        -- HS
			vga_VS                      : out std_logic;                                        -- VS
			vga_BLANK                   : out std_logic;                                        -- BLANK
			vga_SYNC                    : out std_logic;                                        -- SYNC
			vga_R                       : out std_logic_vector(7 downto 0);                     -- R
			vga_G                       : out std_logic_vector(7 downto 0);                     -- G
			vga_B                       : out std_logic_vector(7 downto 0)                      -- B
		);
	end component camera_to_vga;

	u0 : component camera_to_vga
		port map (
			reset_reset_n               => CONNECTED_TO_reset_reset_n,               --     reset.reset_n
			clk_clk                     => CONNECTED_TO_clk_clk,                     --       clk.clk
			rdaddress_writebyteenable_n => CONNECTED_TO_rdaddress_writebyteenable_n, -- rdaddress.writebyteenable_n
			data_in_beginbursttransfer  => CONNECTED_TO_data_in_beginbursttransfer,  --   data_in.beginbursttransfer
			vga_CLK                     => CONNECTED_TO_vga_CLK,                     --       vga.CLK
			vga_HS                      => CONNECTED_TO_vga_HS,                      --          .HS
			vga_VS                      => CONNECTED_TO_vga_VS,                      --          .VS
			vga_BLANK                   => CONNECTED_TO_vga_BLANK,                   --          .BLANK
			vga_SYNC                    => CONNECTED_TO_vga_SYNC,                    --          .SYNC
			vga_R                       => CONNECTED_TO_vga_R,                       --          .R
			vga_G                       => CONNECTED_TO_vga_G,                       --          .G
			vga_B                       => CONNECTED_TO_vga_B                        --          .B
		);

