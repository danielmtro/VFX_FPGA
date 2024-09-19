	camera_to_vga u0 (
		.reset_reset_n               (<connected-to-reset_reset_n>),               //     reset.reset_n
		.clk_clk                     (<connected-to-clk_clk>),                     //       clk.clk
		.rdaddress_writebyteenable_n (<connected-to-rdaddress_writebyteenable_n>), // rdaddress.writebyteenable_n
		.data_in_beginbursttransfer  (<connected-to-data_in_beginbursttransfer>),  //   data_in.beginbursttransfer
		.vga_CLK                     (<connected-to-vga_CLK>),                     //       vga.CLK
		.vga_HS                      (<connected-to-vga_HS>),                      //          .HS
		.vga_VS                      (<connected-to-vga_VS>),                      //          .VS
		.vga_BLANK                   (<connected-to-vga_BLANK>),                   //          .BLANK
		.vga_SYNC                    (<connected-to-vga_SYNC>),                    //          .SYNC
		.vga_R                       (<connected-to-vga_R>),                       //          .R
		.vga_G                       (<connected-to-vga_G>),                       //          .G
		.vga_B                       (<connected-to-vga_B>)                        //          .B
	);

